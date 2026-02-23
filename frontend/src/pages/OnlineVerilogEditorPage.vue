<template>
  <section class="page">
    <!-- ─── Header ─── -->
    <header class="card top">
      <div class="top__brand">
        <span class="brand-icon">💻</span>
        <div>
          <h1 class="h1">在线 Verilog 编辑器</h1>
          <p class="sub">硬件描述语言在线编译与仿真</p>
        </div>
      </div>

      <div class="top__right">
        <div class="toolbar">
          <!-- 关卡选择 -->
          <label class="pill">
            <span class="pill__label">关卡</span>
            <select v-model="levelCode" class="pill__input">
              <option value="" disabled>-- 选择关卡 --</option>
              <option v-for="lv in levels" :key="lv.code" :value="lv.code">
                {{ lv.code }} — {{ lv.title }}
              </option>
            </select>
          </label>
          <button class="btn-ghost btn-sm" @click="refreshLevels" :disabled="busy">↺ 刷新</button>
        </div>
      </div>
    </header>

    <!-- ─── Body Grid ─── -->
    <div class="body-grid">
      <!-- ─── Left Column: Editor ─── -->
      <main class="main-col">
        <div class="card editor-card">
          <div class="panel-head">
            <div class="panel-head__left">
              <span class="panel-title">SystemVerilog 编辑器</span>
              <span v-if="status" class="status-chip">{{ status }}</span>
            </div>
            <div class="spacer" />
            <div class="editor-acts">
              <button class="btn-ghost btn-sm" @click="resetToLevelSkeleton" :disabled="busy || !levelInfo">
                重置代码
              </button>
              <button class="btn-ghost btn-sm" @click="copyJson" :disabled="busy || !circuitObj">
                复制 JSON
              </button>
              <button class="btn-primary btn-sm" @click="renderFromSv" :disabled="busy || !levelInfo">
                <span v-if="busy" class="spin-small"></span>
                {{ busy ? '编译中...' : '编译 & 渲染' }}
              </button>
            </div>
          </div>
          
          <div ref="cmEl" class="code-wrap" spellcheck="false"></div>
        </div>
      </main>

      <!-- ─── Right Column: Info, Preview, Judge ─── -->
      <aside class="side-col">
        
        <!-- Level Info Card -->
        <div class="card info-card">
          <div class="panel-head">
            <span class="panel-title">关卡信息</span>
          </div>
          <div v-if="levelInfo" class="info-grid">
            <div class="info-row">
              <span class="info-label">标题</span>
              <span class="info-val">{{ levelInfo.title || '-' }}</span>
            </div>
            <div class="info-row">
              <span class="info-label">描述</span>
              <span class="info-val">{{ levelInfo.description || '-' }}</span>
            </div>
            <div class="info-row">
              <span class="info-label">允许器件</span>
              <div class="chip-group">
                <span class="type-chip" v-for="comp in (levelInfo.allowedComponents || [])" :key="comp">{{ comp }}</span>
                <span v-if="!(levelInfo.allowedComponents?.length)" class="muted">-</span>
              </div>
            </div>
            <div class="info-row">
              <span class="info-label">固定端口</span>
              <div class="chip-group">
                <span class="type-chip type-chip--accent" v-for="id in fixedDeviceIds" :key="id">{{ id }}</span>
                <span v-if="!fixedDeviceIds.length" class="muted">-</span>
              </div>
            </div>
          </div>
          <div v-else class="empty-state small">
            <div class="empty-state__msg">请先在顶部选择一个关卡</div>
          </div>
        </div>

        <!-- Preview Card -->
        <div class="card preview-card">
          <div class="panel-head">
            <span class="panel-title">电路预览</span>
          </div>
          <div class="paperWrap">
            <div ref="paperEl" class="paper"></div>
          </div>
        </div>

        <!-- Judge Card -->
        <div class="card judge-card">
          <div class="panel-head">
            <span class="panel-title">评测结果</span>
            <div class="spacer" />
            <button class="btn-ghost btn-sm" @click="fetchPassStatus" :disabled="busy || !levelInfo">查看通过状态</button>
            <button class="btn-submit btn-sm" @click="judge" :disabled="busy || !levelInfo">运行评测</button>
          </div>

          <div v-if="judgeResult" class="res-banner" :class="judgeResult.passed ? 'ok' : 'bad'">
            <span class="res-banner__ico">{{ judgeResult.passed ? '🎉' : '💡' }}</span>
            <div>
              <div class="res-banner__title">{{ judgeResult.passed ? '评测通过 (PASSED)' : '评测失败 (FAILED)' }}</div>
              <div class="res-banner__sub">{{ judgeResult.message }}</div>
            </div>
          </div>
          <div v-else class="empty-state small" style="padding: 20px;">
            <div class="empty-state__sub muted">暂无评测结果，点击右上角运行评测。</div>
          </div>

          <!-- Failure Details -->
          <div v-if="judgeResult?.failure" class="failure-grid mt-3">
            <div class="expl">
              <div class="expl__title">错误位置 (Where)</div>
              <pre class="sol__pre">testCaseOrderIndex: {{ judgeResult.failure.testCaseOrderIndex }}&#10;stepIndex: {{ judgeResult.failure.stepIndex }}</pre>
            </div>
            <div class="expl">
              <div class="expl__title">输入 (Inputs)</div>
              <pre class="sol__pre">{{ pretty(judgeResult.failure.inputs) }}</pre>
            </div>
            <div class="expl">
              <div class="expl__title">预期输出 (Expected)</div>
              <pre class="sol__pre">{{ pretty(judgeResult.failure.expected) }}</pre>
            </div>
            <div class="expl">
              <div class="expl__title">实际输出 (Actual)</div>
              <pre class="sol__pre">{{ pretty(judgeResult.failure.actual) }}</pre>
            </div>
          </div>

          <!-- Pass Record -->
          <div v-if="judgeResult?.passRecord" class="expl mt-3">
            <div class="expl__title">通过记录 (Pass Record)</div>
            <pre class="sol__pre">{{ pretty(judgeResult.passRecord) }}</pre>
          </div>
        </div>

      </aside>
    </div>
  </section>
</template>

<script setup>
import { computed, onBeforeUnmount, onMounted, ref, watch } from 'vue'
import { EditorState } from '@codemirror/state'
import { EditorView, keymap, lineNumbers, highlightActiveLineGutter } from '@codemirror/view'
import { defaultKeymap, history, historyKeymap, indentWithTab } from '@codemirror/commands'
import { StreamLanguage } from '@codemirror/language'
import { verilog } from '@codemirror/legacy-modes/mode/verilog'
import { lineBuffered } from '@yowasp/runtime/util'
import { api } from '../lib/api.ts'

/** DigitalJS bundle 会挂到 window.digitaljs（全局） */
const getDigitaljs = () => window.digitaljs
const get$ = () => window.$

// -------------------- local persistence --------------------
const LS = {
  levelCode: 'diglearn.levelCode',
  svCode: 'diglearn.svCode',
}

function lsGet(key) {
  try { return localStorage.getItem(key) } catch (_) { return null }
}
function lsSet(key, val) {
  try { localStorage.setItem(key, val) } catch (_) {}
}
function lsRemove(key) {
  try { localStorage.removeItem(key) } catch (_) {}
}

// -------------------- state --------------------
const busy = ref(false)
const status = ref('')

const levels = ref([]) // [{ code, title }]
const levelCode = ref(lsGet(LS.levelCode) || '')
const levelInfo = ref(null)

const judgeResult = ref(null)

const cmEl = ref(null)
let cmView = null
let cmSettingDoc = false

function cmSetDoc(text) {
  if (!cmView) return
  const next = String(text ?? '')
  const cur = cmView.state.doc.toString()
  if (cur === next) return

  cmSettingDoc = true
  cmView.dispatch({ changes: { from: 0, to: cur.length, insert: next } })
  cmSettingDoc = false
}

function cmInit() {
  if (!cmEl.value) return

  const state = EditorState.create({
    doc: String(svCode.value ?? ''),
    extensions: [
      lineNumbers(),
      highlightActiveLineGutter(),
      history(),
      keymap.of([indentWithTab, ...defaultKeymap, ...historyKeymap]),
      StreamLanguage.define(verilog),
      EditorView.updateListener.of((v) => {
        if (!v.docChanged) return
        if (cmSettingDoc) return
        svCode.value = v.state.doc.toString()
      }),
      // 适配暗色主题的 CodeMirror 样式
      EditorView.theme({
        '&': { height: '100%', width: '100%', backgroundColor: 'transparent', color: '#e2e8f0' },
        '.cm-gutters': { backgroundColor: 'rgba(255,255,255,0.03)', color: '#64748b', borderRight: '1px solid rgba(255,255,255,0.08)' },
        '.cm-activeLineGutter': { backgroundColor: 'rgba(255,255,255,0.1)', color: '#e2e8f0' },
        '.cm-activeLine': { backgroundColor: 'rgba(255,255,255,0.04)' },
        '.cm-scroller': { overflow: 'auto' },
        '.cm-content': { fontFamily: 'ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace', fontSize: '14px', padding: '10px 0' },
        '.cm-cursor': { borderLeftColor: '#a5a9ff' },
        '&.cm-focused': { outline: 'none' }
      }, { dark: true }),
    ],
  })

  cmView = new EditorView({ state, parent: cmEl.value })
}

function cmDestroy() {
  try { cmView?.destroy() } catch (_) {}
  cmView = null
}

// SV code
const svCode = ref(lsGet(LS.svCode) || '')

watch(levelCode, (v) => {
  const s = (v || '').trim()
  if (s) lsSet(LS.levelCode, s); else lsRemove(LS.levelCode)
})

watch(svCode, (v) => {
  const s = String(v ?? '')
  if (s) lsSet(LS.svCode, s); else lsRemove(LS.svCode)

  if (cmView) cmSetDoc(s)
})

// -------------------- circuit state --------------------
function makeEmptyCircuit() {
  return { devices: {}, connectors: [], subcircuits: {} }
}

function deepClone(x) {
  try { return structuredClone(x) } catch (_) {
    return JSON.parse(JSON.stringify(x ?? null))
  }
}

function normalizeCircuitShapeInPlace(c) {
  if (!c || typeof c !== 'object') return
  if (!c.devices || typeof c.devices !== 'object') c.devices = {}
  if (!Array.isArray(c.connectors)) c.connectors = []
  if (!c.subcircuits || typeof c.subcircuits !== 'object') c.subcircuits = {}
}

function normalizePortsForUiAndPreviewInPlace(circuit) {
  const devices = circuit?.devices || {}

  const declaredInputs = new Map()
  for (const [id, dev] of Object.entries(devices)) {
    const n = Number(dev?.inputs)
    if (Number.isFinite(n) && n > 1) declaredInputs.set(id, n)
  }

  const hasIn2Plus = new Set()
  for (const conn of (circuit?.connectors || [])) {
    const toId = conn?.to?.id
    const toPort = conn?.to?.port
    if (!toId || !toPort) continue
    const m = /^in(\d+)$/.exec(String(toPort))
    if (m) {
      const idx = Number(m[1])
      if (Number.isFinite(idx) && idx >= 2) hasIn2Plus.add(toId)
    }
  }

  for (const conn of (circuit?.connectors || [])) {
    if (conn?.from?.port === 'out1') conn.from.port = 'out'

    const toId = conn?.to?.id
    const toPort = conn?.to?.port
    if (!toId || !toPort) continue

    const nInputs = declaredInputs.get(toId) || null

    if (toPort === 'in1') {
      if (!(nInputs && nInputs > 1) && !hasIn2Plus.has(toId)) {
        conn.to.port = 'in'
      }
    }

    if (toPort === 'in') {
      if (nInputs && nInputs > 1) conn.to.port = 'in1'
      if (hasIn2Plus.has(toId)) conn.to.port = 'in1'
    }
  }
}

const circuitObj = ref(makeEmptyCircuit())
const circuitJsonText = computed(() => {
  try { return JSON.stringify(circuitObj.value ?? null, null, 2) } catch (_) { return String(circuitObj.value) }
})

const fixedDeviceIds = computed(() => Object.keys(levelInfo.value?.devices || {}).sort())

function setStatus(msg) { status.value = msg || '' }
function pretty(x) { try { return JSON.stringify(x ?? null, null, 2) } catch (_) { return String(x) } }

// -------------------- levels --------------------
async function refreshLevels() {
  try {
    const data = await api.get('/api/levels')
    levels.value = Array.isArray(data) ? data : []

    const cur = (levelCode.value || '').trim()
    const exists = levels.value.some(lv => lv.code === cur)
    if (!exists) levelCode.value = levels.value[0]?.code || ''
  } catch (e) {
    setStatus(`加载关卡失败: ${e?.message || String(e)}`)
    levels.value = []
  }
}

async function fetchLevelInfo() {
  const code = (levelCode.value || '').trim()
  if (!code) {
    levelInfo.value = null
    return
  }

  try {
    const data = await api.get(`/api/levels/${encodeURIComponent(code)}`)
    levelInfo.value = data
  } catch (e) {
    levelInfo.value = null
    setStatus(`加载关卡详情失败: ${e?.message || String(e)}`)
  }
}

watch(levelCode, async () => {
  setStatus('')
  await fetchLevelInfo()
  if (levelInfo.value) {
    resetToLevelSkeleton()
  }
})

// -------------------- level -> initial circuit + SV skeleton --------------------
function makeInitialCircuitFromLevelDevices(info) {
  const devs = info?.devices
  const circuit = makeEmptyCircuit()
  if (!devs || typeof devs !== 'object') return circuit

  for (const [id, d] of Object.entries(devs)) {
    if (!d || typeof d !== 'object') continue
    circuit.devices[id] = {
      type: d.type,
      label: d.label,
      x: d.x,
      y: d.y,
    }
  }
  normalizeCircuitShapeInPlace(circuit)
  normalizePortsForUiAndPreviewInPlace(circuit)
  return circuit
}

function svPortDeclForFixedDevice(id, dev) {
  const t = String(dev?.type || '').trim()

  if (t === 'Button') {
    return `    input logic ${id} /* digitaljs: {"type": "button"} */`
  }
  if (t === 'Lamp') {
    return `    output logic ${id} /* digitaljs: {"type": "lamp"} */`
  }

  return `    input logic ${id} /* digitaljs: {"type": "${t || 'input'}"} */`
}

function makeSvSkeletonFromLevel(info) {
  const devs = info?.devices || {}
  const ids = Object.keys(devs)

  if (ids.length === 0) {
    return `module top;\n\n    // Start your code here\n\nendmodule\n`
  }

  const inputs = []
  const outputs = []
  for (const id of ids) {
    const t = String(devs[id]?.type || '').trim()
    if (t === 'Lamp') outputs.push(id)
    else inputs.push(id)
  }

  const ordered = [...inputs, ...outputs]
  const decls = ordered.map((id) => svPortDeclForFixedDevice(id, devs[id]))
  const portLines = decls.map((s, i) => (i === decls.length - 1 ? s : (s + ',')))

  return `module top (\n${portLines.join('\n')}\n);\n\n    // Start your code here\n\nendmodule\n`
}

function resetToLevelSkeleton() {
  if (!levelInfo.value) return
  judgeResult.value = null

  svCode.value = makeSvSkeletonFromLevel(levelInfo.value)
  circuitObj.value = makeInitialCircuitFromLevelDevices(levelInfo.value)
  renderPreview()

  setStatus('已重置为关卡初始代码。')
}

// -------------------- compile: SV -> Yosys JSON -> DigitalJS JSON --------------------
async function compileSvToDigitalJsCircuit(svText) {
  const { runYosys, Exit } = await import('@yowasp/yosys')
  const { yosys2digitaljs } = await import('yosys2digitaljs/core')

  const filesIn = {
    'top.sv': String(svText ?? ''),
  }

  const yosysScript = [
    'read_verilog -sv top.sv',
    'hierarchy -top top',
    'proc; opt; clean',
    'write_json out.json',
  ].join('; ')

  const outLines = []
  const errLines = []
  const stdout = lineBuffered((line) => outLines.push(line))
  const stderr = lineBuffered((line) => errLines.push(line))

  let filesOut
  try {
    filesOut = await runYosys(
      ['-p', yosysScript, '-L', 'yosys.log'],
      filesIn,
      { decodeASCII: true, stdout, stderr }
    )
  } catch (e) {
    if (e instanceof Exit) {
      const logFromFile = e?.files?.['yosys.log']
      const logText =
        (typeof logFromFile === 'string' && logFromFile.trim())
          ? logFromFile
          : (errLines.join('\n') || outLines.join('\n') || '(no yosys output captured)')

      throw new Error(`Yosys 编译失败。\n\n${logText}`)
    }
    throw e
  }

  const outJsonText = filesOut?.['out.json']
  if (!outJsonText) {
    const logText = filesOut?.['yosys.log'] || errLines.join('\n') || outLines.join('\n')
    throw new Error(`Yosys 未生成 out.json。\n\n${logText || ''}`)
  }

  const yosysJson = JSON.parse(outJsonText)
  const r = await yosys2digitaljs(yosysJson, {})
  const dj = r?.output || r

  return dj
}

// -------------------- fixed ports alignment --------------------
function normSig(x) {
  if (x == null) return ''
  let s = String(x).trim()
  s = s.replace(/^top\./, '')
  if (s.startsWith('\\')) s = s.slice(1).trim()
  s = s.replace(/\[0\]$/, '')
  return s
}

function rekeyDevicesAndConnectorsInPlace(circuit, idMap) {
  if (!circuit || typeof circuit !== 'object') return
  if (!circuit.devices || typeof circuit.devices !== 'object') return

  const nextDevices = {}
  for (const [oldId, dev] of Object.entries(circuit.devices)) {
    const newId = idMap[oldId] || oldId
    if (nextDevices[newId] && newId !== oldId) {
      throw new Error(`Device id collision when rekeying: ${oldId} -> ${newId}`)
    }
    nextDevices[newId] = dev
  }
  circuit.devices = nextDevices

  for (const conn of (circuit.connectors || [])) {
    const fromId = conn?.from?.id
    const toId = conn?.to?.id
    if (fromId && idMap[fromId]) conn.from.id = idMap[fromId]
    if (toId && idMap[toId]) conn.to.id = idMap[toId]
  }
}

function alignFixedPortDeviceIdsToLevelInPlace(circuit, info) {
  const fixed = info?.devices || {}
  const devices = circuit?.devices || {}

  const alreadyOk = Object.keys(fixed).every((id) => !!devices[id])
  if (alreadyOk) return

  const idMap = {}

  for (const wantId of Object.keys(fixed)) {
    if (devices[wantId]) continue

    const want = normSig(wantId)
    const candidates = []

    for (const [oldId, d] of Object.entries(devices)) {
      const net = normSig(d?.net)
      const label = normSig(d?.label)
      if (net === want || label === want) candidates.push(oldId)
    }

    if (candidates.length === 0) {
      const snapshot = Object.entries(devices).slice(0, 50).map(([id, d]) => ({
        id, type: d?.type, net: d?.net, label: d?.label, bits: d?.bits,
      }))
      throw new Error(
        `无法找到固定端口 "${wantId}" 对应的编译器件。\n` +
        `前50个器件快照:\n` + JSON.stringify(snapshot, null, 2)
      )
    }
    if (candidates.length > 1) {
      throw new Error(`有多个器件匹配固定端口 "${wantId}": ${candidates.join(', ')}`)
    }

    idMap[candidates[0]] = wantId
  }

  rekeyDevicesAndConnectorsInPlace(circuit, idMap)
}

function applyFixedDevicesFromLevelInPlace(circuit, info) {
  const fixed = info?.devices || {}
  const missing = []

  for (const [id, d] of Object.entries(fixed)) {
    if (!circuit.devices?.[id]) {
      missing.push(id)
      continue
    }

    if (d?.type) circuit.devices[id].type = d.type
    if (d?.label != null) circuit.devices[id].label = d.label

    const x = Number(d?.x)
    const y = Number(d?.y)
    if (Number.isFinite(x) && Number.isFinite(y)) {
      if (circuit.devices[id].position && typeof circuit.devices[id].position === 'object') {
        circuit.devices[id].position.x = x
        circuit.devices[id].position.y = y
      } else {
        circuit.devices[id].x = x
        circuit.devices[id].y = y
      }
    }
  }

  if (missing.length) {
    throw new Error(
      `编译后的电路缺少固定端口: ${missing.join(', ')}。\n` +
      `请确保 module top 的端口名与关卡要求完全一致。`
    )
  }
}

async function renderFromSv() {
  setStatus('')
  judgeResult.value = null
  if (!levelInfo.value) { setStatus('请先选择一个关卡。'); return }

  busy.value = true
  try {
    setStatus('正在编译 SV (Yosys WASM) ...')

    const compiled = await compileSvToDigitalJsCircuit(svCode.value)

    alignFixedPortDeviceIdsToLevelInPlace(compiled, levelInfo.value)
    applyFixedDevicesFromLevelInPlace(compiled, levelInfo.value)
    normalizeCircuitShapeInPlace(compiled)
    normalizePortsForUiAndPreviewInPlace(compiled)

    circuitObj.value = compiled
    renderPreview()
    setStatus('编译与渲染完成。')
  } catch (e) {
    setStatus('渲染失败: ' + (e?.message || e))
  } finally {
    busy.value = false
  }
}

// -------------------- DigitalJS preview --------------------
const paperEl = ref(null)
let djCircuit = null
let djDisplay = null

function stopPreview() {
  try { if (djCircuit?.stop) djCircuit.stop() } catch (_) {}
  djCircuit = null
  djDisplay = null
  if (paperEl.value) paperEl.value.innerHTML = ''
}

function renderPreview() {
  stopPreview()

  const digitaljs = getDigitaljs()
  if (!digitaljs) { setStatus('未在 window 上找到 digitaljs'); return }

  const $ = get$()
  if (!$) { setStatus('未在 window 上找到 jQuery $'); return }

  try {
    const previewObj = deepClone(circuitObj.value)
    normalizeCircuitShapeInPlace(previewObj)
    normalizePortsForUiAndPreviewInPlace(previewObj)

    djCircuit = new digitaljs.Circuit(previewObj)
    djDisplay = djCircuit.displayOn($(paperEl.value))
    if (djCircuit.start) djCircuit.start()
  } catch (e) {
    setStatus('预览渲染错误: ' + (e?.message || e))
    stopPreview()
  }
}

// -------------------- clipboard --------------------
async function copyJson() {
  const text = circuitJsonText.value || ''
  if (!text) { setStatus('没有可复制的 JSON。'); return }

  try {
    await navigator.clipboard.writeText(text)
    setStatus('JSON 已复制到剪贴板。')
    return
  } catch (_) {}

  try {
    const ta = document.createElement('textarea')
    ta.value = text
    ta.setAttribute('readonly', 'true')
    ta.style.position = 'fixed'
    ta.style.left = '-9999px'
    ta.style.top = '0'
    document.body.appendChild(ta)
    ta.select()
    document.execCommand('copy')
    document.body.removeChild(ta)
    setStatus('JSON 已复制到剪贴板 (fallback)。')
  } catch (e) {
    setStatus('复制失败: ' + (e?.message || e))
  }
}

// -------------------- judge / pass --------------------
async function judge() {
  setStatus('')
  judgeResult.value = null

  const code = (levelCode.value || '').trim()
  if (!code) { setStatus('请先选择一个关卡。'); return }

  busy.value = true
  try {
    const data = await api.post(`/api/levels/${encodeURIComponent(code)}/judge`, { circuit: circuitObj.value })
    judgeResult.value = data
    setStatus(data?.passed ? '评测: 通过 (PASSED)' : ('评测: 失败 (FAILED) - ' + (data?.message || '')))
  } catch (e) {
    setStatus(`评测失败: ${e?.message || String(e)}`)
  } finally {
    busy.value = false
  }
}

async function fetchPassStatus() {
  setStatus('')

  const code = (levelCode.value || '').trim()
  if (!code) { setStatus('请先选择一个关卡。'); return }

  busy.value = true
  try {
    const data = await api.get(`/api/levels/${encodeURIComponent(code)}/pass`)
    setStatus('已加载通过状态。')
    judgeResult.value = {
      passed: data?.passed ?? false,
      message: data?.passed ? '该关卡已通过。' : '该关卡尚未通过。',
      failure: null,
      passRecord: data?.passRecord ?? null,
    }
  } catch (e) {
    setStatus(`获取状态失败: ${e?.message || String(e)}`)
  } finally {
    busy.value = false
  }
}

// -------------------- lifecycle --------------------
onMounted(async () => {
  cmInit()

  await refreshLevels()
  await fetchLevelInfo()
  if (levelInfo.value) resetToLevelSkeleton()
  else renderPreview()
})

onBeforeUnmount(() => {
  cmDestroy()
  stopPreview()
})
</script>

<style scoped>
/* ─── Base ─── */
.page {
  display: flex;
  flex-direction: column;
  gap: 14px;
  font-size: 14px;
  line-height: 1.5;
  min-height: 100vh;
  background: #0f111a; /* 暗色背景 */
  color: #e2e8f0;
  color-scheme: dark; /* 告诉浏览器使用暗色模式渲染原生控件（如下拉框、滚动条等） */
  font-family: ui-sans-serif, system-ui, -apple-system, sans-serif;
  padding: 14px;
  box-sizing: border-box;
}
p { margin: 0; }

/* ─── Layout ─── */
.body-grid {
  display: grid;
  grid-template-columns: minmax(0, 1.3fr) minmax(350px, 1fr);
  gap: 14px;
  align-items: start;
  flex: 1;
}
@media (max-width: 1024px) {
  .body-grid { grid-template-columns: 1fr; }
}
.main-col {
  display: flex;
  flex-direction: column;
  gap: 14px;
  height: calc(100vh - 100px);
}
.side-col {
  display: flex;
  flex-direction: column;
  gap: 14px;
  max-height: calc(100vh - 100px);
  overflow-y: auto;
  padding-right: 4px;
}
.side-col::-webkit-scrollbar { width: 6px; }
.side-col::-webkit-scrollbar-track { background: transparent; }
.side-col::-webkit-scrollbar-thumb { background: rgba(255, 255, 255, 0.15); border-radius: 3px; }

/* ─── Card ─── */
.card {
  background: rgba(255, 255, 255, 0.04);
  border: 1px solid rgba(255, 255, 255, 0.08);
  border-radius: 16px;
  padding: 16px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.2);
}

/* ─── Header ─── */
.top {
  display: flex;
  align-items: center;
  gap: 16px;
  flex-wrap: wrap;
  justify-content: space-between;
  padding: 14px 20px;
}
.top__brand {
  display: flex;
  align-items: center;
  gap: 12px;
}
.brand-icon { font-size: 28px; line-height: 1; }
.h1 { margin: 0; font-size: 20px; font-weight: 800; color: #fff; }
.sub { margin: 2px 0 0; opacity: 0.6; font-size: 12px; }
.top__right {
  display: flex;
  align-items: center;
  gap: 14px;
  flex-wrap: wrap;
}

/* ─── Toolbar / Pill ─── */
.toolbar {
  display: flex;
  gap: 8px;
  align-items: center;
  flex-wrap: wrap;
}
.pill {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  padding: 6px 12px;
  border-radius: 999px;
  border: 1px solid rgba(255, 255, 255, 0.12);
  background: rgba(0, 0, 0, 0.2);
}
.pill__label { opacity: 0.65; font-size: 12px; white-space: nowrap; }
.pill__input {
  border: none;
  outline: none;
  background: transparent;
  color: inherit;
  min-width: 140px;
  font-size: 13px;
  cursor: pointer;
}
.pill__input option { background: #1e293b; color: #e2e8f0; }

/* ─── Buttons ─── */
.btn-ghost {
  background: transparent;
  border: 1px solid rgba(255, 255, 255, 0.15);
  border-radius: 10px;
  padding: 7px 12px;
  opacity: 0.85;
  font-size: 13px;
  cursor: pointer;
  transition: all 0.15s;
  color: inherit;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 6px;
}
.btn-ghost:hover:not(:disabled) { background: rgba(255, 255, 255, 0.08); opacity: 1; }
.btn-ghost:disabled { opacity: 0.4; cursor: not-allowed; }

.btn-sm { padding: 5px 10px !important; font-size: 12px !important; border-radius: 8px !important; }

.btn-primary {
  background: rgba(100, 108, 255, 0.18);
  border: 1px solid rgba(100, 108, 255, 0.38);
  color: #b8bcff;
  border-radius: 10px;
  padding: 7px 14px;
  font-size: 13px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.15s;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 6px;
}
.btn-primary:hover:not(:disabled) { background: rgba(100, 108, 255, 0.3); }
.btn-primary:disabled { opacity: 0.5; cursor: not-allowed; filter: grayscale(0.5); }

.btn-submit {
  background: rgba(80, 200, 120, 0.18);
  border: 1px solid rgba(80, 200, 120, 0.4);
  color: #86efac;
  border-radius: 10px;
  padding: 7px 16px;
  font-size: 13px;
  font-weight: 700;
  cursor: pointer;
  transition: all 0.15s;
}
.btn-submit:hover:not(:disabled) { background: rgba(80, 200, 120, 0.3); transform: translateY(-1px); }
.btn-submit:disabled { opacity: 0.4; cursor: not-allowed; }

/* ─── Panel Header ─── */
.panel-head {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 14px;
  flex-wrap: wrap;
}
.panel-head__left { display: flex; align-items: center; gap: 10px; }
.panel-title { font-weight: 800; font-size: 15px; color: #fff; }
.spacer { flex: 1; }
.status-chip {
  font-size: 11px;
  padding: 3px 8px;
  border-radius: 6px;
  background: rgba(255, 255, 255, 0.08);
  color: #cbd5e1;
}
.editor-acts { display: flex; gap: 8px; }

/* ─── Editor Card ─── */
.editor-card {
  flex: 1;
  display: flex;
  flex-direction: column;
  padding: 16px;
  min-height: 0;
}
.code-wrap {
  flex: 1;
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 12px;
  background: rgba(0, 0, 0, 0.25);
  overflow: hidden;
  position: relative;
}
.code-wrap :deep(.cm-editor) { height: 100%; width: 100%; }

/* ─── Info Card ─── */
.info-grid { display: flex; flex-direction: column; gap: 10px; }
.info-row {
  display: grid;
  grid-template-columns: 70px 1fr;
  gap: 12px;
  align-items: baseline;
  font-size: 13px;
}
.info-label { color: #94a3b8; font-weight: 500; }
.info-val { color: #f8fafc; line-height: 1.5; }
.chip-group { display: flex; flex-wrap: wrap; gap: 6px; }

/* ─── Type Chip ─── */
.type-chip {
  display: inline-block;
  font-size: 11px;
  padding: 3px 8px;
  border-radius: 6px;
  border: 1px solid rgba(255, 255, 255, 0.1);
  background: rgba(255, 255, 255, 0.06);
  white-space: nowrap;
  font-weight: 600;
}
.type-chip--accent {
  border-color: rgba(100, 108, 255, 0.35);
  background: rgba(100, 108, 255, 0.15);
  color: #b8bcff;
}

/* ─── Preview Card ─── */
.paperWrap {
  width: 100%;
  height: 300px;
  border: 1px solid rgba(255, 255, 255, 0.15);
  border-radius: 12px;
  /* DigitalJS 默认生成黑色连线，为了清晰可见，这里使用较亮的背景色 */
  background: #f1f5f9; 
  overflow: auto;
  position: relative;
}
.paper { width: 100%; height: 100%; }

/* ─── Judge Card & Result Banner ─── */
.res-banner {
  display: flex;
  align-items: flex-start;
  gap: 12px;
  padding: 14px 16px;
  border-radius: 12px;
  border: 1px solid rgba(255, 255, 255, 0.1);
  background: rgba(255, 255, 255, 0.04);
}
.res-banner.ok  { border-color: rgba(80, 200, 120, 0.38); background: rgba(80, 200, 120, 0.08); }
.res-banner.bad { border-color: rgba(255, 100, 100, 0.38); background: rgba(255, 100, 100, 0.08); }
.res-banner__ico { font-size: 22px; line-height: 1; flex-shrink: 0; }
.res-banner__title { font-weight: 800; font-size: 14px; color: #fff; }
.res-banner__sub { margin-top: 4px; opacity: 0.8; font-size: 13px; line-height: 1.4; white-space: pre-wrap;}

.failure-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 10px;
}
@media (max-width: 600px) {
  .failure-grid { grid-template-columns: 1fr; }
}

/* ─── Explanation / Pre ─── */
.expl {
  padding: 12px;
  border-radius: 10px;
  background: rgba(0, 0, 0, 0.2);
  border: 1px solid rgba(255, 255, 255, 0.06);
}
.expl__title {
  font-weight: 700;
  font-size: 11px;
  color: #94a3b8;
  margin-bottom: 8px;
}
.sol__pre {
  margin: 0;
  font-family: ui-monospace, SFMono-Regular, Menlo, monospace;
  font-size: 12px;
  color: #e2e8f0;
  white-space: pre-wrap;
  word-break: break-all;
  max-height: 200px;
  overflow-y: auto;
}

/* ─── Utilities ─── */
.muted { opacity: 0.6; }
.small { font-size: 12px; }
.mt-2 { margin-top: 8px; }
.mt-3 { margin-top: 12px; }
.empty-state { text-align: center; padding: 30px 10px; opacity: 0.7; }

.spin-small {
  display: inline-block;
  width: 12px; height: 12px;
  border: 2px solid rgba(255,255,255,0.3);
  border-top-color: #fff;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
}
@keyframes spin { to { transform: rotate(360deg); } }
</style>