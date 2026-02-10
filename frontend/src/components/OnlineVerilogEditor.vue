<template>
  <div class="page">
    <header class="bar">
      <div class="left">
        <label>
          Level
          <select v-model="levelCode" class="input">
            <option value="" disabled>-- select level --</option>
            <option v-for="lv in levels" :key="lv.code" :value="lv.code">
              {{ lv.code }} — {{ lv.title }}
            </option>
          </select>
        </label>

        <button className="btn" @click="refreshLevels" :disabled="busy">Refresh levels</button>

        <div class="userBox">
          <div class="userRow">
            <label class="grow">
              Current user
              <select v-model="selectedUserId" class="input">
                <option value="" disabled>-- select user --</option>
                <option v-for="u in users" :key="u.userId" :value="u.userId">
                  {{ u.name }} ({{ u.userId }})
                </option>
              </select>
            </label>

            <button class="btn" @click="refreshUsers" :disabled="busy">Refresh users</button>
          </div>

          <details class="details">
            <summary>Create user</summary>
            <div class="createUserGrid">
              <label>
                userId (optional)
                <input v-model="newUserId" class="input" placeholder="leave blank to auto-generate" />
              </label>
              <label>
                name
                <input v-model="newUserName" class="input" placeholder="hesse" />
              </label>
              <div class="createActions">
                <button class="btn primary" @click="createUser" :disabled="busy">Create</button>
                <button class="btn" @click="resetNewUser" :disabled="busy">Reset</button>
              </div>
            </div>
            <div v-if="userStatus" class="subStatus">{{ userStatus }}</div>
          </details>
        </div>

        <div class="btns">
          <button class="btn primary" @click="renderFromSv" :disabled="busy || !levelInfo">
            {{ busy ? 'Working...' : 'Render' }}
          </button>
          <button class="btn" @click="resetToLevelSkeleton" :disabled="busy || !levelInfo">
            Reset
          </button>
          <button class="btn" @click="copyJson" :disabled="busy || !circuitObj">CopyJson</button>

          <button class="btn primary" @click="judge" :disabled="busy || !levelInfo">Run / Judge</button>
          <button class="btn" @click="fetchPassStatus" :disabled="busy || !levelInfo">Pass status</button>
        </div>

        <div v-if="status" class="status">{{ status }}</div>
      </div>

      <div class="right">
        <div class="kv">
          <div>Level title:</div>
          <code>{{ levelInfo?.title || '-' }}</code>
        </div>

        <div class="kv">
          <div>Description:</div>
          <code>{{ levelInfo?.description || '-' }}</code>
        </div>

        <div class="kv">
          <div>Allowed comps:</div>
          <code>{{ (levelInfo?.allowedComponents || []).join(', ') || '-' }}</code>
        </div>

        <div class="kv">
          <div>Fixed ids:</div>
          <code>{{ fixedDeviceIds.join(', ') || '-' }}</code>
        </div>
      </div>
    </header>

    <main class="main">
      <section class="editor">
        <div class="title">SystemVerilog</div>
        <div ref="cmEl" class="code" spellcheck="false"></div>

        <details class="details">
          <summary>Advanced: read-only DigitalJS JSON (compiled)</summary>
          <pre class="pre preTall">{{ circuitJsonText }}</pre>
        </details>
      </section>

      <section class="preview">
        <div class="title">Preview</div>
        <div class="paperWrap">
          <div ref="paperEl" class="paper"></div>
        </div>
      </section>
    </main>

    <section class="bottom">
      <details class="details" open>
        <summary>Judge result</summary>

        <div v-if="judgeResult" class="judgeBox">
          <div class="judgeLine">
            <span class="badge" :class="judgeResult.passed ? 'ok' : 'bad'">
              {{ judgeResult.passed ? 'PASSED' : 'FAILED' }}
            </span>
            <span class="judgeMsg">{{ judgeResult.message }}</span>
          </div>

          <div v-if="judgeResult.failure" class="failureGrid">
            <div>
              <div class="miniTitle">Where</div>
              <pre class="pre">{{
`testCaseOrderIndex: ${judgeResult.failure.testCaseOrderIndex}
stepIndex: ${judgeResult.failure.stepIndex}`
              }}</pre>
            </div>

            <div>
              <div class="miniTitle">Inputs</div>
              <pre class="pre">{{ pretty(judgeResult.failure.inputs) }}</pre>
            </div>

            <div>
              <div class="miniTitle">Expected</div>
              <pre class="pre">{{ pretty(judgeResult.failure.expected) }}</pre>
            </div>

            <div>
              <div class="miniTitle">Actual</div>
              <pre class="pre">{{ pretty(judgeResult.failure.actual) }}</pre>
            </div>
          </div>

          <div v-if="judgeResult.passRecord" class="passBox">
            <div class="miniTitle">Pass record</div>
            <pre class="pre">{{ pretty(judgeResult.passRecord) }}</pre>
          </div>
        </div>

        <div v-else class="muted">No judge run yet.</div>
      </details>
    </section>
  </div>
</template>

<script setup>
import { computed, onBeforeUnmount, onMounted, ref, watch } from 'vue'
import { EditorState } from '@codemirror/state'
import { EditorView, keymap, lineNumbers, highlightActiveLineGutter } from '@codemirror/view'
import { defaultKeymap, history, historyKeymap, indentWithTab } from '@codemirror/commands'
import { StreamLanguage } from '@codemirror/language'
import { verilog } from '@codemirror/legacy-modes/mode/verilog'
import { lineBuffered } from '@yowasp/runtime/util'

/** DigitalJS bundle 会挂到 window.digitaljs（全局） */
const getDigitaljs = () => window.digitaljs
const get$ = () => window.$

// -------------------- local persistence --------------------
const LS = {
  selectedUserId: 'diglearn.selectedUserId',
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

const users = ref([]) // [{ userId, name }]
const selectedUserId = ref(lsGet(LS.selectedUserId) || '')
const newUserId = ref('')
const newUserName = ref('')
const userStatus = ref('')

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
      EditorView.theme({
        '&': { height: '520px', width: '100%' },
        '.cm-scroller': { overflow: 'auto' },
        '.cm-content': { fontFamily: 'ui-monospace, SFMono-Regular, Menlo, monospace', fontSize: '12px' },
      }),
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

watch(selectedUserId, (v) => {
  const s = (v || '').trim()
  if (s) lsSet(LS.selectedUserId, s); else lsRemove(LS.selectedUserId)
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

/**
 * 统一端口命名到 UI/Preview 习惯（复用你 MiniEditor 的逻辑）
 * - from.port: out1 -> out
 * - to.port: 对“单输入语义”的器件，把 in1 -> in
 * - 若某器件明确 inputs>1 且出现 in，则修为 in1（避免歧义）
 */
function normalizePortsForUiAndPreviewInPlace(circuit) {
  const devices = circuit?.devices || {}

  // declared inputs
  const declaredInputs = new Map()
  for (const [id, dev] of Object.entries(devices)) {
    const n = Number(dev?.inputs)
    if (Number.isFinite(n) && n > 1) declaredInputs.set(id, n)
  }

  // any in2+ used?
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

// fixed devices (from levelInfo.devices)
const fixedDeviceIds = computed(() => Object.keys(levelInfo.value?.devices || {}).sort())

function setStatus(msg) { status.value = msg || '' }
function pretty(x) { try { return JSON.stringify(x ?? null, null, 2) } catch (_) { return String(x) } }

function requireSelectedUserId() {
  const id = (selectedUserId.value || '').trim()
  if (!id) throw new Error('Please select a user (userId) first.')
  return id
}

// -------------------- levels --------------------
async function refreshLevels() {
  const resp = await fetch('/api/levels', { headers: { 'Accept': 'application/json' } })
  if (!resp.ok) {
    const text = await resp.text().catch(() => '')
    setStatus(`Load levels failed: HTTP ${resp.status} ${text}`)
    levels.value = []
    return
  }
  const data = await resp.json().catch(() => [])
  levels.value = Array.isArray(data) ? data : []

  const cur = (levelCode.value || '').trim()
  const exists = levels.value.some(lv => lv.code === cur)
  if (!exists) levelCode.value = levels.value[0]?.code || ''
}

async function fetchLevelInfo() {
  const code = (levelCode.value || '').trim()
  if (!code) {
    levelInfo.value = null
    return
  }

  const resp = await fetch(`/api/levels/${encodeURIComponent(code)}`, {
    headers: { 'Accept': 'application/json' },
  })
  if (!resp.ok) {
    const text = await resp.text().catch(() => '')
    levelInfo.value = null
    setStatus(`Load level failed: HTTP ${resp.status} ${text}`)
    return
  }

  const data = await resp.json().catch(() => null)
  levelInfo.value = data
}

// 当 level 变化：拉取 levelInfo，并重置 skeleton + 初始预览
watch(levelCode, async () => {
  setStatus('')
  await fetchLevelInfo()
  if (levelInfo.value) {
    resetToLevelSkeleton()
  }
})

// -------------------- users --------------------
async function refreshUsers() {
  userStatus.value = ''
  const resp = await fetch('/api/users', { headers: { 'Accept': 'application/json' } })
  if (!resp.ok) {
    const text = await resp.text().catch(() => '')
    userStatus.value = `Load users failed: HTTP ${resp.status} ${text}`
    users.value = []
    selectedUserId.value = ''
    return
  }
  const data = await resp.json().catch(() => [])
  users.value = Array.isArray(data) ? data : []
  const exists = users.value.some(u => u.userId === selectedUserId.value)
  if (!exists) selectedUserId.value = users.value[0]?.userId || ''
}

async function ensureUserSelected() {
  await refreshUsers()
  if ((selectedUserId.value || '').trim()) return

  if (users.value.length === 0) {
    userStatus.value = 'No user found. Auto-creating a Guest user...'

    const resp = await fetch('/api/users', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', 'Accept': 'application/json' },
      body: JSON.stringify({ userId: null, name: 'Guest' }),
    })
    if (!resp.ok) {
      const text = await resp.text().catch(() => '')
      userStatus.value = `Auto-create Guest failed: HTTP ${resp.status} ${text}`
      return
    }

    await refreshUsers()
    selectedUserId.value = users.value[0]?.userId || ''
    userStatus.value = 'Guest user created.'
  }
}

function resetNewUser() {
  newUserId.value = ''
  newUserName.value = ''
  userStatus.value = ''
}

async function createUser() {
  userStatus.value = ''
  const nm = (newUserName.value || '').trim()
  const uid = (newUserId.value || '').trim()
  if (!nm) { userStatus.value = 'name is required.'; return }

  const resp = await fetch('/api/users', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', 'Accept': 'application/json' },
    body: JSON.stringify({ userId: uid || null, name: nm }),
  })

  if (!resp.ok) {
    const text = await resp.text().catch(() => '')
    userStatus.value = `Create user failed: HTTP ${resp.status} ${text}`
    return
  }

  const created = await resp.json().catch(() => null)
  await refreshUsers()
  if (created?.userId) selectedUserId.value = created.userId
  newUserId.value = ''
  newUserName.value = ''
  userStatus.value = 'User created.'
}

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

  // 保证输出端口排在后面（仅美观）
  const inputs = []
  const outputs = []
  for (const id of ids) {
    const t = String(devs[id]?.type || '').trim()
    if (t === 'Lamp') outputs.push(id)
    else inputs.push(id)
  }

  const ordered = [...inputs, ...outputs]
  const decls = ordered.map((id) => svPortDeclForFixedDevice(id, devs[id]))

  // 端口之间用逗号分隔；最后一个不加逗号
  const portLines = decls.map((s, i) => (i === decls.length - 1 ? s : (s + ',')))

  return `module top (\n${portLines.join('\n')}\n);\n\n    // Start your code here\n\nendmodule\n`
}

function resetToLevelSkeleton() {
  if (!levelInfo.value) return
  judgeResult.value = null

  // 1) SV skeleton
  svCode.value = makeSvSkeletonFromLevel(levelInfo.value)

  // 2) preview initial fixed devices
  circuitObj.value = makeInitialCircuitFromLevelDevices(levelInfo.value)
  renderPreview()

  setStatus('Reset to level skeleton.')
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

  // 捕获 stdout/stderr
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

      throw new Error(`Yosys failed.\n\n${logText}`)
    }
    throw e
  }

  const outJsonText = filesOut?.['out.json']
  if (!outJsonText) {
    const logText = filesOut?.['yosys.log'] || errLines.join('\n') || outLines.join('\n')
    throw new Error(`Yosys did not produce out.json.\n\n${logText || ''}`)
  }

  const yosysJson = JSON.parse(outJsonText)
  const r = await yosys2digitaljs(yosysJson, {})
  const dj = r?.output || r

  // 注意：这里不做 normalize/改名，以免丢失 net/label，影响后续 fixed-port 对齐
  return dj
}

// -------------------- fixed ports alignment --------------------
function normSig(x) {
  if (x == null) return ''
  let s = String(x).trim()

  // top.A -> A
  s = s.replace(/^top\./, '')

  // \A   -> A（Verilog 转义标识符，常见尾部空格）
  if (s.startsWith('\\')) s = s.slice(1).trim()

  // A[0] -> A（1-bit 端口常见表现）
  s = s.replace(/\[0\]$/, '')

  return s
}

function rekeyDevicesAndConnectorsInPlace(circuit, idMap /* oldId -> newId */) {
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
        id,
        type: d?.type,
        net: d?.net,
        label: d?.label,
        bits: d?.bits,
      }))
      throw new Error(
        `Cannot find compiled device for fixed port "${wantId}".\n` +
        `First devices snapshot (up to 50):\n` +
        JSON.stringify(snapshot, null, 2)
      )
    }
    if (candidates.length > 1) {
      throw new Error(
        `Multiple compiled devices match fixed port "${wantId}": ${candidates.join(', ')}`
      )
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

    // 强制 type/label（用于对齐 judge：Button/Lamp 的 id 必须与 testcases 一致）
    if (d?.type) circuit.devices[id].type = d.type
    if (d?.label != null) circuit.devices[id].label = d.label

    // 强制坐标（兼容 x/y 或 position）
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
      `Compiled circuit is missing fixed ports: ${missing.join(', ')}.\n` +
      `Please keep module top ports named exactly as level.devices ids.`
    )
  }
}

async function renderFromSv() {
  setStatus('')
  judgeResult.value = null
  if (!levelInfo.value) { setStatus('Please select a level first.'); return }

  busy.value = true
  try {
    setStatus('Compiling SV (Yosys WASM) ...')

    const compiled = await compileSvToDigitalJsCircuit(svCode.value)

    // 关键顺序：
    // 1) 先用 net/label 对齐 A/B/Y（此时名字还没被 normalize 逻辑动过）
    alignFixedPortDeviceIdsToLevelInPlace(compiled, levelInfo.value)

    // 2) 再强制固定器件的 type/position
    applyFixedDevicesFromLevelInPlace(compiled, levelInfo.value)

    // 3) 最后再做 UI/Preview 端口归一化
    normalizeCircuitShapeInPlace(compiled)
    normalizePortsForUiAndPreviewInPlace(compiled)

    circuitObj.value = compiled
    renderPreview()
    setStatus('Rendered from SV.')
  } catch (e) {
    setStatus('Render failed: ' + (e?.message || e))
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
  if (!digitaljs) { setStatus('digitaljs not found on window.digitaljs'); return }

  const $ = get$()
  if (!$) { setStatus('jQuery $ not found on window.$'); return }

  try {
    const previewObj = deepClone(circuitObj.value)
    normalizeCircuitShapeInPlace(previewObj)
    normalizePortsForUiAndPreviewInPlace(previewObj)

    djCircuit = new digitaljs.Circuit(previewObj)
    djDisplay = djCircuit.displayOn($(paperEl.value))
    if (djCircuit.start) djCircuit.start()
  } catch (e) {
    setStatus('Preview render error: ' + (e?.message || e))
    stopPreview()
  }
}

// -------------------- clipboard --------------------
async function copyJson() {
  const text = circuitJsonText.value || ''
  if (!text) { setStatus('Nothing to copy.'); return }

  try {
    await navigator.clipboard.writeText(text)
    setStatus('Copied JSON to clipboard.')
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
    setStatus('Copied JSON to clipboard (fallback).')
  } catch (e) {
    setStatus('Copy failed: ' + (e?.message || e))
  }
}

// -------------------- judge / pass --------------------
async function judge() {
  setStatus('')
  judgeResult.value = null

  const code = (levelCode.value || '').trim()
  if (!code) { setStatus('Please select a level.'); return }

  let userId
  try { userId = requireSelectedUserId() } catch (e) { setStatus(e.message); return }

  busy.value = true
  try {
    const resp = await fetch(`/api/levels/${encodeURIComponent(code)}/judge`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-User-Id': userId,
      },
      body: JSON.stringify({ userId, circuit: circuitObj.value }),
    })

    if (!resp.ok) {
      const text = await resp.text().catch(() => '')
      setStatus(`Judge failed: HTTP ${resp.status} ${text}`)
      return
    }

    const data = await resp.json().catch(() => null)
    judgeResult.value = data
    setStatus(data?.passed ? 'Judge: PASSED' : ('Judge: FAILED - ' + (data?.message || '')))
  } finally {
    busy.value = false
  }
}

async function fetchPassStatus() {
  setStatus('')

  const code = (levelCode.value || '').trim()
  if (!code) { setStatus('Please select a level.'); return }

  let userId
  try { userId = requireSelectedUserId() } catch (e) { setStatus(e.message); return }

  busy.value = true
  try {
    const resp = await fetch(`/api/levels/${encodeURIComponent(code)}/pass?userId=${encodeURIComponent(userId)}`, {
      headers: { 'Accept': 'application/json', 'X-User-Id': userId },
    })

    if (!resp.ok) {
      const text = await resp.text().catch(() => '')
      setStatus(`Pass status failed: HTTP ${resp.status} ${text}`)
      return
    }

    const data = await resp.json().catch(() => null)
    setStatus('Pass status loaded.')
    judgeResult.value = {
      passed: data?.passed ?? false,
      message: data?.passed ? 'Already passed.' : 'Not passed yet.',
      failure: null,
      passRecord: data?.passRecord ?? null,
    }
  } finally {
    busy.value = false
  }
}

// -------------------- lifecycle --------------------
onMounted(async () => {
  cmInit()

  await ensureUserSelected()
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
.page {
  --bg: #f6f7fb;
  --surface: #ffffff;
  --surface-2: #f2f5fb;

  --border: #cbd5e1;
  --border-soft: #e2e8f0;

  --text: #0b1220;
  --text-muted: #475569;
  --text-faint: #64748b;

  --primary: #111827;
  --primary-hover: #0b1220;
  --accent: #2563eb;
  --ring: rgba(37, 99, 235, 0.25);

  --radius-sm: 10px;
  --radius: 14px;

  --shadow-sm: 0 1px 2px rgba(2, 6, 23, 0.06);
  --shadow: 0 10px 30px rgba(2, 6, 23, 0.08);

  min-height: 100vh;
  display: flex;
  flex-direction: column;
  font-family: ui-sans-serif, system-ui, -apple-system;
  background: var(--bg);
  color: var(--text);
}

.bar {
  display: flex;
  gap: 16px;
  padding: 12px;
  align-items: flex-start;

  background: var(--surface);
  border-bottom: 1px solid var(--border-soft);
  box-shadow: var(--shadow-sm);
}

.left {
  flex: 1;
  display: flex;
  gap: 12px;
  align-items: end;
  flex-wrap: wrap;
}

.right {
  min-width: 320px;
  display: grid;
  gap: 8px;
}

.input {
  display: block;
  width: 300px;
  padding: 8px 10px;

  border: 1px solid var(--border);
  border-radius: var(--radius-sm);
  background: var(--surface);
  color: var(--text);

  transition: border-color 120ms ease, box-shadow 120ms ease;
}

.input:focus {
  outline: none;
  border-color: var(--accent);
  box-shadow: 0 0 0 3px var(--ring);
}

.btns {
  width: 100%;
  display: grid;
  gap: 8px;
  grid-template-columns: repeat(auto-fit, minmax(170px, 1fr));
  align-items: stretch;
}

.btn {
  padding: 8px 10px;
  border: 1px solid var(--border);
  border-radius: var(--radius-sm);
  background: var(--surface);
  color: var(--text);
  cursor: pointer;

  transition: background-color 120ms ease, border-color 120ms ease, transform 40ms ease;
}

.btn:hover { background: var(--surface-2); }
.btn:active { transform: translateY(1px); }
.btn:disabled { opacity: 0.6; cursor: not-allowed; }

.btn.primary {
  background: var(--primary);
  color: #fff;
  border-color: var(--primary);
}
.btn.primary:hover {
  background: var(--primary-hover);
  border-color: var(--primary-hover);
}

.status {
  width: 100%;
  color: var(--text-muted);
  padding-top: 4px;
  white-space: pre-wrap;
}

.subStatus { margin-top: 8px; color: var(--text-muted); white-space: pre-wrap; }

.userBox {
  width: 100%;
  border: 1px solid var(--border);
  border-radius: var(--radius);
  padding: 10px;

  background: var(--surface-2);
  box-shadow: var(--shadow-sm);
}

.userRow {
  display: flex;
  gap: 8px;
  align-items: end;
  flex-wrap: wrap;
}

.grow { flex: 1; min-width: 280px; }
.details { margin-top: 10px; }

.createUserGrid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 10px;
  padding-top: 10px;
}

.createActions {
  display: flex;
  gap: 8px;
  align-items: end;
  flex-wrap: wrap;
}

.kv {
  display: grid;
  grid-template-columns: 120px 1fr;
  gap: 8px;
  align-items: center;
}

code {
  background: var(--surface-2);
  color: var(--text);
  border: 1px solid var(--border-soft);
  padding: 2px 6px;
  border-radius: var(--radius-sm);
  overflow: hidden;
  text-overflow: ellipsis;
}

.main {
  flex: 1;
  min-height: 0;

  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 12px;
  padding: 12px;

  height: calc(100vh - 72px);
}

.editor,
.preview {
  min-height: 0;
  overflow: hidden;
  display: flex;
  flex-direction: column;
  overflow: auto;
  }

.title { font-weight: 700; margin-bottom: 8px; }

.code {
  flex: 1;

  width: 100%;
  min-height: 500px;
  height: auto;
  
  resize: vertical;
  border: 1px solid var(--border);
  border-radius: var(--radius);
  padding: 10px;

  font-family: ui-monospace, SFMono-Regular, Menlo, monospace;
  font-size: 12px;
  line-height: 1.5;

  background: var(--surface);
  color: var(--text);

  text-align: left
}

/* CodeMirror 内部节点需要 :deep 才能在 scoped 下生效 */
.code :deep(.cm-editor) {
  width: 100%;
  height: 100%;
}

.code :deep(.cm-content),
.code :deep(.cm-line) {
  text-align: left;
}

.paperWrap {
  --paper-h: 600px;

  height: var(--paper-h);
  max-height: var(--paper-h);
  width: 100%;
  max-width: 900px;
  border: 1px solid var(--border-soft);
  border-radius: var(--radius);
  background: var(--surface);
  box-shadow: var(--shadow-sm);

  /* overflow: auto; */
  position: relative;

  height: 0;
}

.paper {
  width: 100%;
  min-height: 520px;
}

.bottom {
  padding: 12px;
  border-top: 1px solid var(--border-soft);
  background: var(--surface);
}

.judgeBox {
  margin-top: 10px;
  border: 1px solid var(--border);
  border-radius: var(--radius);
  padding: 10px;
  background: var(--surface-2);
  box-shadow: var(--shadow-sm);
}

.judgeLine {
  display: flex;
  gap: 10px;
  align-items: center;
  flex-wrap: wrap;
}

.badge {
  display: inline-block;
  padding: 2px 8px;
  border-radius: 999px;
  font-weight: 800;
  font-size: 12px;
  border: 1px solid var(--border);
  background: var(--surface);
}

.badge.ok {
  border-color: #16a34a;
  color: #14532d;
  background: #dcfce7;
}
.badge.bad {
  border-color: #dc2626;
  color: #7f1d1d;
  background: #fee2e2;
}

.failureGrid {
  margin-top: 10px;
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 10px;
}

.miniTitle { font-weight: 700; margin-bottom: 6px; }

.pre {
  margin: 0;
  padding: 10px;
  border-radius: var(--radius);
  border: 1px solid var(--border);
  background: var(--surface);
  color: var(--text);
  overflow: auto;

  font-family: ui-monospace, SFMono-Regular, Menlo, monospace;
  font-size: 12px;
  line-height: 1.4;
}

.preTall { max-height: 420px; }
.muted { color: var(--text-faint); padding-top: 8px; }

/* @media (max-width: 900px) {
  .main { grid-template-columns: 1fr; }
  .right { min-width: auto; }
  .input { width: 100%; }
  .createUserGrid { grid-template-columns: 1fr; }
  .failureGrid { grid-template-columns: 1fr; }
} */
</style>