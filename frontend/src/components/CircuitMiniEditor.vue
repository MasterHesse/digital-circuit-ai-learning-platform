<template>
  <div class="page">
    <header class="bar">
      <div class="left">
        <label>
          Name
          <input v-model="name" class="input" placeholder="and-demo" />
        </label>

        <label>
          Load by id
          <input v-model="loadId" class="input" placeholder="UUID..." />
        </label>

        <div class="btns">
          <button class="btn" @click="renderPreview">Render</button>
          <button class="btn" @click="stopPreview">Stop</button>
          <button class="btn" @click="formatJson">Format JSON</button>
          <button class="btn primary" @click="save">Save (POST)</button>
          <button class="btn" @click="loadById">Load (GET)</button>
        </div>

        <div v-if="status" class="status">{{ status }}</div>
      </div>

      <div class="right">
        <div class="kv">
          <div>Last saved id:</div>
          <code>{{ lastSavedId || '-' }}</code>
        </div>
      </div>
    </header>

    <main class="main">
      <section class="editor">
        <div class="title">Circuit JSON (DigitalJS format)</div>
        <textarea v-model="circuitJsonText" class="textarea"></textarea>
      </section>

      <section class="preview">
        <div class="title">Preview</div>
        <div ref="paperEl" class="paper"></div>
      </section>
    </main>
  </div>
</template>

<script setup>
import { onBeforeUnmount, onMounted, ref } from 'vue'

/** DigitalJS bundle 会挂到 window.digitaljs（全局） */
const getDigitaljs = () => window.digitaljs
const get$ = () => window.$ // README 示例用 $('#paper')，bundle 通常会带 $

// state
const name = ref('and-demo')
const loadId = ref('')
const lastSavedId = ref('')
const status = ref('')

const circuitJsonText = ref(JSON.stringify({
  devices: {
    A: { type: 'Button', label: 'A' },
    B: { type: 'Button', label: 'B' },
    G1: { type: 'And', label: 'AND1', bits: 1, inputs: 2 },
    Y: { type: 'Lamp', label: 'Y' }
  },
  connectors: [
    { from: { id: 'A', port: 'out' }, to: { id: 'G1', port: 'in1' } },
    { from: { id: 'B', port: 'out' }, to: { id: 'G1', port: 'in2' } },
    { from: { id: 'G1', port: 'out' }, to: { id: 'Y', port: 'in' } }
  ],
  subcircuits: {}
}, null, 2))

// dom
const paperEl = ref(null)

// digitaljs objects
let djCircuit = null

function stopPreview() {
  try {
    if (djCircuit?.stop) djCircuit.stop()
  } catch (_) {
    // ignore
  }
  djCircuit = null
  if (paperEl.value) paperEl.value.innerHTML = ''
}

function renderPreview() {
  status.value = ''
  stopPreview()

  const digitaljs = getDigitaljs()
  if (!digitaljs) {
    status.value = 'digitaljs not found. Did you add <script src="https://tilk.github.io/digitaljs/main.js"> ?'
    return
  }

  let circuitObj
  try {
    circuitObj = JSON.parse(circuitJsonText.value)
  } catch (e) {
    status.value = 'JSON parse error: ' + e?.message
    return
  }

  try {
    djCircuit = new digitaljs.Circuit(circuitObj)
    const $ = get$()
    // README 的用法是 displayOn($('#paper')) ([github.com](https://github.com/tilk/digitaljs))
    // 这里用 ref 的 div 作为容器
    if ($) {
      djCircuit.displayOn($(paperEl.value))
    } else {
      // 兜底：某些 bundle 情况 $ 不存在
      // 这时你需要自己额外引入 jQuery，或改为 npm 方式引入依赖
      throw new Error('jQuery $ not found (DigitalJS displayOn expects a jQuery element)')
    }
    if (djCircuit.start) djCircuit.start()
    status.value = 'Rendered.'
  } catch (e) {
    status.value = 'Render error: ' + e?.message
    stopPreview()
  }
}

function formatJson() {
  try {
    const obj = JSON.parse(circuitJsonText.value)
    circuitJsonText.value = JSON.stringify(obj, null, 2)
    status.value = 'Formatted.'
  } catch (e) {
    status.value = 'JSON parse error: ' + e?.message
  }
}

async function save() {
  status.value = ''
  let circuitObj
  try {
    circuitObj = JSON.parse(circuitJsonText.value)
  } catch (e) {
    status.value = 'JSON parse error: ' + e?.message
    return
  }

  const resp = await fetch('/api/circuits', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
    body: JSON.stringify({
      name: name.value,
      circuit: circuitObj,
    }),
  })

  if (!resp.ok) {
    const text = await resp.text().catch(() => '')
    status.value = `Save failed: HTTP ${resp.status} ${text}`
    return
  }

  const data = await resp.json().catch(() => null)
  // 你后端 CircuitResponse 里大概率会有 id；这里做个兼容读取
  const id = data?.id || data?.circuitId || data?.uuid || ''
  if (id) lastSavedId.value = id
  status.value = 'Saved.'
}

async function loadById() {
  status.value = ''
  const id = (loadId.value || '').trim()
  if (!id) {
    status.value = 'Please input id.'
    return
  }

  const resp = await fetch(`/api/circuits/${encodeURIComponent(id)}`, {
    headers: { 'Accept': 'application/json' },
  })

  if (!resp.ok) {
    const text = await resp.text().catch(() => '')
    status.value = `Load failed: HTTP ${resp.status} ${text}`
    return
  }

  const data = await resp.json()
  // 期望 data.circuit 是 DigitalJS 的 circuit JSON
  if (!data?.circuit) {
    status.value = 'Load ok but response has no "circuit" field.'
    return
  }

  circuitJsonText.value = JSON.stringify(data.circuit, null, 2)
  name.value = data?.name ?? name.value
  status.value = 'Loaded.'
  renderPreview()
}

onMounted(() => {
  // 首屏渲染一次
  renderPreview()
})

onBeforeUnmount(() => {
  stopPreview()
})
</script>

<style scoped>
.page { min-height: 100vh; display: flex; flex-direction: column; font-family: ui-sans-serif, system-ui, -apple-system; }
.bar { display: flex; gap: 16px; padding: 12px; border-bottom: 1px solid #e5e7eb; align-items: flex-start; }
.left { flex: 1; display: flex; gap: 12px; flex-wrap: wrap; align-items: end; }
.right { min-width: 240px; }
.input { display: block; width: 280px; padding: 8px; border: 1px solid #d1d5db; border-radius: 6px; }
.btns { display: flex; gap: 8px; flex-wrap: wrap; }
.btn { padding: 8px 10px; border: 1px solid #d1d5db; border-radius: 6px; background: #fff; cursor: pointer; }
.btn.primary { background: #111827; color: #fff; border-color: #111827; }
.status { width: 100%; color: #374151; padding-top: 4px; }
.main { flex: 1; display: grid; grid-template-columns: 1fr 1fr; gap: 12px; padding: 12px; }
.editor, .preview { display: flex; flex-direction: column; min-height: 0; }
.title { font-weight: 600; margin-bottom: 8px; }
.textarea { flex: 1; width: 100%; resize: none; padding: 10px; border: 1px solid #d1d5db; border-radius: 8px; font-family: ui-monospace, SFMono-Regular, Menlo, monospace; font-size: 13px; line-height: 1.4; }
.paper { flex: 1; border: 1px solid #d1d5db; border-radius: 8px; overflow: auto; background: #fafafa; min-height: 480px; }
.kv { display: grid; grid-template-columns: 120px 1fr; gap: 8px; align-items: center; }
code { background: #f3f4f6; padding: 2px 6px; border-radius: 6px; }
@media (max-width: 900px) {
  .main { grid-template-columns: 1fr; }
  .right { min-width: auto; }
  .input { width: 100%; }
}
</style>