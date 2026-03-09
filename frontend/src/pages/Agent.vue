<template>
  <div class="agent-page">
    <aside class="sidebar">
      <div class="brand-card">
        <div class="brand">
          <div class="brand-ico">⚡</div>
          <div>
            <div class="brand-name">数字电路 AI 学习平台</div>
            <div class="brand-eng">Digital Circuit Learning</div>
          </div>
        </div>

        <div class="sep" />

        <div class="brand-title">DigLearn AI 助教</div>
        <div class="brand-subtitle">支持多轮对话、学习画像、会话保存</div>
      </div>

      <button class="btn-submit full" type="button" :disabled="loading" @click="createConversation">
        + 新建会话
      </button>

      <section class="panel conversation-panel">
        <div class="panel-header">
          <span>会话列表</span>
          <span class="muted">{{ conversations.length }}</span>
        </div>

        <div v-if="loadingConversations" class="small-tip">正在加载会话…</div>

        <div v-else-if="!conversations.length" class="empty-small">
          暂无会话，点击上方按钮开始。
        </div>

        <div v-else class="conversation-list">
          <div
            v-for="item in conversations"
            :key="item.conversationId"
            class="conversation-row"
            :class="{ active: item.conversationId === activeConversationId }"
          >
            <button
              class="conversation-open"
              type="button"
              :disabled="loading"
              @click="openConversation(item.conversationId)"
            >
              <div class="conversation-title">
                {{ item.title || '未命名会话' }}
              </div>
              <div class="conversation-meta">
                <span class="mono">{{ shortId(item.conversationId) }}</span>
                <span>{{ formatTime(item.updatedAt) }}</span>
              </div>
            </button>

            <button
              class="danger-text-btn"
              type="button"
              :disabled="loading"
              @click="deleteConversation(item.conversationId)"
            >
              删除
            </button>
          </div>
        </div>
      </section>

      <section class="panel quick-panel">
        <div class="panel-header">
          <span>快捷提问</span>
        </div>

        <div class="quick-list">
          <button
            v-for="q in quickPrompts"
            :key="q"
            class="quick-btn"
            type="button"
            :disabled="loading"
            @click="applyQuickPrompt(q)"
          >
            {{ q }}
          </button>
        </div>
      </section>
    </aside>

    <section class="chat-shell">
      <header class="chat-header">
        <div class="chat-header-main">
          <div class="chat-title">
            {{ currentConversationTitle }}
          </div>
          <div class="chat-subtitle">
            <span v-if="activeConversationId" class="mono">ID: {{ shortId(activeConversationId) }}</span>
            <span>场景：{{ sceneLabel(scene) }}</span>
            <span>模型：{{ model }}</span>
            <span v-if="lastProvider">Provider：{{ lastProvider }}</span>
            <span v-if="lastModel">最后响应模型：{{ lastModel }}</span>
          </div>
        </div>
      </header>

      <main ref="messagePane" class="message-pane">
        <div v-if="!messages.length" class="empty-state">
          <div class="empty-badge">AI 助教已就绪</div>
          <div class="empty-title">今天想问点什么？</div>
          <div class="empty-desc">
            你可以提问概念、请求题目讲解、查看推荐原因，或者让助教根据你的学习画像给出建议。
          </div>

          <div class="empty-actions">
            <button
              v-for="q in quickPrompts"
              :key="q"
              class="empty-action-btn"
              type="button"
              :disabled="loading"
              @click="applyQuickPrompt(q)"
            >
              {{ q }}
            </button>
          </div>
        </div>

        <article
          v-for="msg in messages"
          :key="msg.id"
          class="msg"
          :class="[`role-${msg.role}`]"
        >
          <div class="msg-head">
            <div class="msg-head-left">
              <span class="role-badge" :class="[`badge-${msg.role}`]">
                {{ roleLabel(msg.role) }}
              </span>
              <span class="msg-time">{{ formatTime(msg.createdAt) }}</span>
            </div>

            <div class="msg-head-right">
              <span v-if="msg.model" class="mini-badge">{{ msg.model }}</span>
              <span v-if="msg.provider" class="mini-badge">{{ msg.provider }}</span>
              <span v-if="msg.fallback" class="mini-badge warn">fallback</span>
            </div>
          </div>

          <div v-if="msg.role === 'assistant'" class="msg-body assistant-body" v-html="msg.html" />
          <div v-else class="msg-body user-body">{{ msg.content }}</div>

          <div v-if="msg.reasoning" class="sub-block reasoning-block">
            <div class="sub-block-title">思考内容</div>
            <div class="reasoning-content">{{ msg.reasoning }}</div>
          </div>

          <div v-if="msg.usedContexts?.length" class="sub-block">
            <div class="sub-block-title">本轮使用上下文</div>
            <div class="pill-row">
              <span
                v-for="ctx in msg.usedContexts"
                :key="ctx"
                class="pill soft"
                :title="ctx"
              >
                {{ contextLabel(ctx) }}
              </span>
            </div>
          </div>

          <div v-if="msg.sources?.length" class="sub-block">
            <div class="sub-block-title">参考资料</div>
            <div class="source-list">
              <div v-for="src in msg.sources" :key="src.id" class="source-card">
                <div class="source-top">
                  <span class="pill">{{ src.sourceType || 'SOURCE' }}</span>
                  <span class="source-title">{{ src.title || src.sourceId || src.id }}</span>
                </div>
                <div v-if="src.sourceId" class="source-id mono">{{ src.sourceId }}</div>
                <div v-if="src.snippet" class="source-snippet">{{ src.snippet }}</div>
              </div>
            </div>
          </div>

          <div v-if="msg.nextActions?.length" class="sub-block">
            <div class="sub-block-title">你可以继续追问</div>
            <div class="pill-row">
              <button
                v-for="action in msg.nextActions"
                :key="action"
                class="pill-btn"
                type="button"
                :disabled="loading"
                @click="submit(action)"
              >
                {{ action }}
              </button>
            </div>
          </div>

          <div class="msg-actions">
            <button class="text-btn" type="button" @click="copyText(msg.content)">
              复制内容
            </button>
          </div>
        </article>

        <div v-if="loading" class="typing-box">
          <div class="typing-dot" />
          <div class="typing-dot" />
          <div class="typing-dot" />
          <span>助教正在思考中…</span>
        </div>
      </main>

      <footer class="composer">
        <div v-if="error" class="error-box">
          {{ error }}
        </div>

        <div ref="settingsWrap" class="composer-shell">
          <div v-if="settingsOpen" class="settings-pop">
            <div class="settings-pop-header">
              <div class="settings-pop-title">对话调参</div>
              <button class="link" type="button" @click="settingsOpen = false">
                收起
              </button>
            </div>

            <div class="settings-grid">
              <div class="setting-item">
                <label class="setting-label" for="scene">场景</label>
                <select id="scene" v-model="scene" class="select">
                  <option v-for="item in sceneOptions" :key="item.value" :value="item.value">
                    {{ item.label }}
                  </option>
                </select>
              </div>

              <div class="setting-item">
                <label class="setting-label" for="model">模型</label>
                <select id="model" v-model="model" class="select">
                  <option v-for="item in modelOptions" :key="item" :value="item">
                    {{ item }}
                  </option>
                </select>
              </div>
            </div>

            <div class="switch-list">
              <div class="switch-row">
                <div>
                  <div class="switch-title">显示资料来源</div>
                  <div class="switch-desc">后端返回本轮回答所参考的教学资料</div>
                </div>
                <button class="switch" :class="{ on: includeSources }" type="button" @click="includeSources = !includeSources">
                  <span class="switch-dot" />
                </button>
              </div>

              <div class="switch-row">
                <div>
                  <div class="switch-title">启用思考模式</div>
                  <div class="switch-desc">如果当前模型支持 reasoning，则请求更强推理</div>
                </div>
                <button class="switch" :class="{ on: thinking }" type="button" @click="thinking = !thinking">
                  <span class="switch-dot" />
                </button>
              </div>

              <div class="switch-row">
                <div>
                  <div class="switch-title">显示思考内容</div>
                  <div class="switch-desc">将后端返回的 reasoning 展示在消息下方</div>
                </div>
                <button class="switch" :class="{ on: showReasoning }" type="button" @click="showReasoning = !showReasoning">
                  <span class="switch-dot" />
                </button>
              </div>

              <div class="switch-row">
                <div>
                  <div class="switch-title">结合我的学习画像</div>
                  <div class="switch-desc">由后端自动拼接用户基础信息、班级信息、练习画像</div>
                </div>
                <button
                  class="switch"
                  :class="{ on: useProfileContext }"
                  type="button"
                  @click="useProfileContext = !useProfileContext"
                >
                  <span class="switch-dot" />
                </button>
              </div>
            </div>
          </div>

          <div class="composer-toolbar">
            <button class="tool-btn" type="button" @click="settingsOpen = !settingsOpen">
              <span class="tool-icon">⚙</span>
              <span>调参</span>
              <span class="tool-count">{{ enabledFeatureCount }}</span>
            </button>

            <div class="toolbar-tags">
              <span class="toolbar-tag">场景：{{ sceneLabel(scene) }}</span>
              <span class="toolbar-tag">模型：{{ model }}</span>
              <span v-if="useProfileContext" class="toolbar-tag">画像增强</span>
              <span v-if="includeSources" class="toolbar-tag">资料来源</span>
              <span v-if="thinking" class="toolbar-tag">思考模式</span>
            </div>
          </div>

          <textarea
            ref="inputEl"
            v-model="draft"
            class="composer-input"
            rows="5"
            placeholder="请输入你的问题。Enter 发送，Shift+Enter 换行。"
            :disabled="loading"
            @keydown.enter.exact.prevent="submit()"
          />

          <div class="composer-bar">
            <div class="composer-tip">
              <span>Enter 发送</span>
              <span>Shift+Enter 换行</span>
              <span v-if="activeConversationId" class="mono">当前会话：{{ shortId(activeConversationId) }}</span>
            </div>

            <button class="btn-submit send-btn" type="button" :disabled="!canSend" @click="submit()">
              {{ loading ? '发送中…' : '发送' }}
            </button>
          </div>
        </div>
      </footer>
    </section>
  </div>
</template>

<script setup lang="ts">
import { computed, nextTick, onBeforeUnmount, onMounted, ref } from 'vue'
import { ApiError, api } from '../lib/api'

type Scene = 'GENERAL_QA' | 'QUESTION_EXPLAIN' | 'RECOMMENDATION_EXPLAIN'

type ChatSource = {
  id: string
  sourceType: string
  sourceId: string
  title: string
  snippet: string
}

type ChatResponse = {
  conversationId: string
  answer: string
  reasoning: string | null
  model: string
  thinking: boolean
  sources: ChatSource[]
  nextActions: string[]
  fallback: boolean
  provider: string
  usedContexts: string[]
}

type ConversationSummary = {
  conversationId: string
  title: string
  scene: Scene
  createdAt: string
  updatedAt: string
}

type ConversationMessage = {
  messageId: string
  role: 'user' | 'assistant'
  content: string
  reasoning?: string | null
  model?: string | null
  provider?: string | null
  fallback?: boolean
  sources?: ChatSource[]
  usedContexts?: string[]
  createdAt: string
}

type ConversationDetail = {
  conversationId: string
  title: string
  scene: Scene
  createdAt: string
  updatedAt: string
  messages: ConversationMessage[]
}

type UiMessage = {
  id: string
  role: 'user' | 'assistant'
  content: string
  html?: string
  reasoning?: string | null
  model?: string | null
  provider?: string | null
  fallback?: boolean
  sources?: ChatSource[]
  nextActions?: string[]
  usedContexts?: string[]
  conversationId?: string
  createdAt: string
}

const inputEl = ref<HTMLTextAreaElement | null>(null)
const messagePane = ref<HTMLElement | null>(null)
const settingsWrap = ref<HTMLElement | null>(null)

const conversations = ref<ConversationSummary[]>([])
const activeConversationId = ref('')
const messages = ref<UiMessage[]>([])
const draft = ref('')
const error = ref('')
const loading = ref(false)
const loadingConversations = ref(false)

const includeSources = ref(true)
const thinking = ref(false)
const showReasoning = ref(true)
const useProfileContext = ref(true)
const settingsOpen = ref(false)

const scene = ref<Scene>('GENERAL_QA')
const model = ref('qwen-turbo')

const lastProvider = ref('')
const lastModel = ref('')

const modelOptions = ['qwen-turbo', 'qwen-plus', 'qwen-flash']

const sceneOptions: Array<{ value: Scene; label: string }> = [
  { value: 'GENERAL_QA', label: '通用问答' },
  { value: 'QUESTION_EXPLAIN', label: '题目讲解' },
  { value: 'RECOMMENDATION_EXPLAIN', label: '推荐解读' },
]

const quickPrompts = [
  '帮我根据当前学习情况制定今天的学习计划。',
  '解释一下组合逻辑和时序逻辑的核心区别。',
  '我有一道题做错了，请帮我讲解思路，不要直接只给答案。',
]

const currentConversation = computed(() =>
  conversations.value.find((c) => c.conversationId === activeConversationId.value) || null
)

const currentConversationTitle = computed(() => {
  if (currentConversation.value?.title) return currentConversation.value.title
  if (activeConversationId.value) return '当前会话'
  return '新对话'
})

const canSend = computed(() => !loading.value && draft.value.trim().length > 0)

const enabledFeatureCount = computed(() => {
  let n = 0
  if (includeSources.value) n++
  if (thinking.value) n++
  if (showReasoning.value) n++
  if (useProfileContext.value) n++
  return n
})

function uid(prefix = 'id') {
  return `${prefix}_${Date.now()}_${Math.random().toString(36).slice(2, 10)}`
}

function shortId(v: string) {
  if (!v) return ''
  return v.length <= 12 ? v : `${v.slice(0, 8)}…${v.slice(-4)}`
}

function roleLabel(role: 'user' | 'assistant') {
  return role === 'user' ? '你' : '助教'
}

function sceneLabel(v: Scene) {
  return sceneOptions.find((x) => x.value === v)?.label || v
}

function contextLabel(code: string) {
  const m: Record<string, string> = {
    PROFILE_BASIC: '基础画像',
    PROFILE_CLASSROOM: '班级画像',
    PROFILE_PRACTICE: '练习画像',
    HISTORY: '历史对话',
    MATERIAL: '教学资料',
  }
  return m[code] || code
}

function formatTime(value?: string | null) {
  if (!value) return ''
  const d = new Date(value)
  if (Number.isNaN(d.getTime())) return value
  return d.toLocaleString()
}

function normalizeError(err: unknown) {
  if (err instanceof ApiError) return err.message || `${err.status} ${err.statusText}`
  if (err instanceof Error) return err.message
  return '请求失败，请稍后重试'
}

function escapeHtml(input: string) {
  return input
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&#39;')
}

function toHtml(input: string) {
  if (!input) return ''
  let text = input.replace(/\r\n/g, '\n')

  const blockStore: string[] = []

  text = text.replace(/```([\s\S]*?)```/g, (_, code: string) => {
    const token = `@@CODE_BLOCK_${blockStore.length}@@`
    blockStore.push(`<pre><code>${escapeHtml(code.trim())}</code></pre>`)
    return token
  })

  text = escapeHtml(text)
    .replace(/`([^`\n]+)`/g, '<code>$1</code>')
    .replace(/\*\*(.+?)\*\*/g, '<strong>$1</strong>')

  const paragraphs = text
    .split(/\n{2,}/)
    .map((part) => `<p>${part.replace(/\n/g, '<br />')}</p>`)
    .join('')

  let html = paragraphs
  for (let i = 0; i < blockStore.length; i++) {
    const token = `@@CODE_BLOCK_${i}@@`
    html = html.replace(`<p>${token}</p>`, blockStore[i]).replace(token, blockStore[i])
  }

  return html
}

function mapConversationMessage(msg: ConversationMessage, conversationId: string): UiMessage {
  return {
    id: msg.messageId,
    role: msg.role?.toLowerCase() === 'user' ? 'user' : 'assistant',
    content: msg.content || '',
    html: msg.role === 'assistant' ? toHtml(msg.content || '') : undefined,
    reasoning: msg.reasoning ?? null,
    model: msg.model ?? null,
    provider: msg.provider ?? null,
    fallback: !!msg.fallback,
    sources: Array.isArray(msg.sources) ? msg.sources : [],
    usedContexts: Array.isArray(msg.usedContexts) ? msg.usedContexts : [],
    conversationId,
    createdAt: msg.createdAt || new Date().toISOString(),
  }
}

async function scrollToBottom() {
  await nextTick()
  const el = messagePane.value
  if (!el) return
  el.scrollTo({
    top: el.scrollHeight,
    behavior: 'smooth',
  })
}

async function focusInput() {
  await nextTick()
  inputEl.value?.focus()
}

function handleDocumentPointerDown(event: MouseEvent) {
  const target = event.target as Node | null
  if (!settingsOpen.value || !settingsWrap.value || !target) return
  if (!settingsWrap.value.contains(target)) {
    settingsOpen.value = false
  }
}

async function loadConversations(autoOpenFirst = false) {
  loadingConversations.value = true
  try {
    const res = await api.get<ConversationSummary[]>('/api/ai/conversations')
    conversations.value = Array.isArray(res) ? res : []

    if (activeConversationId.value) {
      const exists = conversations.value.some((x) => x.conversationId === activeConversationId.value)
      if (!exists) {
        activeConversationId.value = ''
        messages.value = []
      }
    }

    if (autoOpenFirst && !activeConversationId.value && conversations.value.length > 0) {
      await openConversation(conversations.value[0].conversationId)
    }
  } catch (err) {
    error.value = normalizeError(err)
  } finally {
    loadingConversations.value = false
  }
}

async function createConversation() {
  error.value = ''
  try {
    const created = await api.post<ConversationSummary>('/api/ai/conversations', {
      scene: scene.value,
    })

    activeConversationId.value = created.conversationId
    messages.value = []
    lastProvider.value = ''
    lastModel.value = ''
    await loadConversations(false)
    await focusInput()
  } catch (err) {
    error.value = normalizeError(err)
  }
}

async function openConversation(conversationId: string) {
  error.value = ''
  try {
    const detail = await api.get<ConversationDetail>(`/api/ai/conversations/${conversationId}`)
    activeConversationId.value = detail.conversationId
    scene.value = detail.scene || 'GENERAL_QA'
    messages.value = Array.isArray(detail.messages)
      ? detail.messages.map((msg) => mapConversationMessage(msg, detail.conversationId))
      : []

    await scrollToBottom()
    await focusInput()
  } catch (err) {
    error.value = normalizeError(err)
  }
}

async function deleteConversation(conversationId: string) {
  const ok = window.confirm('确定删除这个会话吗？删除后不可恢复。')
  if (!ok) return

  error.value = ''
  try {
    await api.del<void>(`/api/ai/conversations/${conversationId}`)

    if (activeConversationId.value === conversationId) {
      activeConversationId.value = ''
      messages.value = []
      lastProvider.value = ''
      lastModel.value = ''
    }

    await loadConversations(false)
    await focusInput()
  } catch (err) {
    error.value = normalizeError(err)
  }
}

function applyQuickPrompt(text: string) {
  draft.value = text
  focusInput()
}

async function copyText(text: string) {
  try {
    await navigator.clipboard.writeText(text || '')
  } catch {
    // ignore
  }
}

async function submit(prefilled?: string) {
  const raw = (prefilled ?? draft.value).trim()
  if (!raw || loading.value) return

  error.value = ''

  const userMessage: UiMessage = {
    id: uid('user'),
    role: 'user',
    content: raw,
    createdAt: new Date().toISOString(),
    conversationId: activeConversationId.value || undefined,
  }

  messages.value.push(userMessage)
  if (!prefilled) draft.value = ''
  await scrollToBottom()

  loading.value = true
  try {
    const res = await api.post<ChatResponse>('/api/ai/chat', {
      conversationId: activeConversationId.value || undefined,
      message: raw,
      scene: scene.value,
      includeSources: includeSources.value,
      model: model.value,
      thinking: thinking.value,
      showReasoning: showReasoning.value,
      useProfileContext: useProfileContext.value,
    })

    activeConversationId.value = res.conversationId || activeConversationId.value
    lastProvider.value = res.provider || ''
    lastModel.value = res.model || ''

    const assistantMessage: UiMessage = {
      id: uid('assistant'),
      role: 'assistant',
      content: res.answer || '',
      html: toHtml(res.answer || ''),
      reasoning: res.reasoning ?? null,
      model: res.model || '',
      provider: res.provider || '',
      fallback: !!res.fallback,
      sources: Array.isArray(res.sources) ? res.sources : [],
      nextActions: Array.isArray(res.nextActions) ? res.nextActions : [],
      usedContexts: Array.isArray(res.usedContexts) ? res.usedContexts : [],
      conversationId: res.conversationId,
      createdAt: new Date().toISOString(),
    }

    messages.value.push(assistantMessage)
    await loadConversations(false)
  } catch (err) {
    const msg = normalizeError(err)
    error.value = msg

    messages.value.push({
      id: uid('assistant_error'),
      role: 'assistant',
      content: `请求失败：${msg}`,
      html: toHtml(`请求失败：${msg}`),
      fallback: true,
      provider: 'system',
      model: '',
      sources: [],
      nextActions: [],
      usedContexts: [],
      conversationId: activeConversationId.value || undefined,
      createdAt: new Date().toISOString(),
    })
  } finally {
    loading.value = false
    await scrollToBottom()
    await focusInput()
  }
}

onMounted(async () => {
  document.addEventListener('mousedown', handleDocumentPointerDown)
  await loadConversations(true)
  await focusInput()
})

onBeforeUnmount(() => {
  document.removeEventListener('mousedown', handleDocumentPointerDown)
})
</script>

<style scoped>
.agent-page {
  color-scheme: dark;
  height: 100vh;
  display: grid;
  grid-template-columns: 320px minmax(0, 1fr);
  gap: 16px;
  padding: 16px;
  box-sizing: border-box;
  overflow: hidden;
  background:
    radial-gradient(circle at top left, rgba(100, 108, 255, 0.15) 0%, transparent 28%),
    radial-gradient(circle at bottom right, rgba(100, 108, 255, 0.12) 0%, transparent 24%),
    linear-gradient(180deg, #0b1020 0%, #0f172a 100%);
}

.sidebar,
.chat-shell {
  min-height: 0;
  height: 100%;
}

.sidebar {
  display: flex;
  flex-direction: column;
  gap: 12px;
  overflow: hidden;
}

.brand-card,
.panel,
.chat-shell {
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 20px;
  box-sizing: border-box;
}

.brand-card,
.panel {
  backdrop-filter: blur(14px);
}

.brand-card {
  padding: 22px 20px;
}

.brand {
  display: flex;
  align-items: center;
  gap: 13px;
  margin-bottom: 18px;
}

.brand-ico {
  width: 48px;
  height: 48px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 24px;
  background: rgba(100, 108, 255, 0.18);
  border: 1px solid rgba(100, 108, 255, 0.35);
  border-radius: 14px;
  flex-shrink: 0;
}

.brand-name {
  font-size: 14px;
  font-weight: 800;
  color: rgba(245, 247, 255, 0.98);
}

.brand-eng {
  font-size: 11px;
  opacity: 0.5;
  margin-top: 3px;
  letter-spacing: 0.03em;
  color: rgba(230, 235, 255, 0.88);
}

.sep {
  height: 1px;
  background: rgba(255, 255, 255, 0.07);
  margin-bottom: 16px;
}

.brand-title {
  font-size: 18px;
  font-weight: 800;
  color: rgba(245, 247, 255, 0.98);
}

.brand-subtitle {
  margin-top: 6px;
  font-size: 13px;
  line-height: 1.6;
  color: rgba(226, 232, 240, 0.62);
}

.panel {
  padding: 14px;
}

.conversation-panel {
  flex: 1 1 auto;
  min-height: 0;
  display: flex;
  flex-direction: column;
}

.quick-panel {
  flex: 0 0 auto;
}

.panel-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 8px;
  margin-bottom: 12px;
  font-size: 14px;
  font-weight: 700;
  color: rgba(245, 247, 255, 0.96);
}

.muted {
  color: rgba(226, 232, 240, 0.5);
  font-size: 12px;
}

.full {
  width: 100%;
}

.small-tip,
.empty-small {
  font-size: 13px;
  color: rgba(226, 232, 240, 0.6);
  line-height: 1.5;
}

.conversation-list {
  display: flex;
  flex-direction: column;
  gap: 8px;
  min-height: 0;
  overflow: auto;
  padding-right: 4px;
}

.conversation-row {
  display: grid;
  grid-template-columns: minmax(0, 1fr) auto;
  gap: 8px;
  align-items: stretch;
}

.conversation-open {
  appearance: none;
  width: 100%;
  text-align: left;
  border: 1px solid rgba(255, 255, 255, 0.08);
  background: rgba(0, 0, 0, 0.15);
  border-radius: 14px;
  padding: 10px 12px;
  cursor: pointer;
  color: inherit;
  transition: all 0.18s ease;
}

.conversation-open:hover:not(:disabled) {
  border-color: rgba(100, 108, 255, 0.35);
  background: rgba(100, 108, 255, 0.08);
}

.conversation-row.active .conversation-open {
  border-color: rgba(100, 108, 255, 0.5);
  background: rgba(100, 108, 255, 0.16);
  box-shadow: 0 10px 24px rgba(100, 108, 255, 0.14);
}

.conversation-open:disabled {
  opacity: 0.7;
  cursor: not-allowed;
}

.conversation-title {
  font-size: 14px;
  font-weight: 700;
  color: rgba(245, 247, 255, 0.96);
  line-height: 1.45;
  word-break: break-word;
}

.conversation-meta {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  margin-top: 6px;
  font-size: 12px;
  color: rgba(226, 232, 240, 0.48);
}

.quick-list {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.btn-submit,
.text-btn,
.danger-text-btn,
.quick-btn,
.empty-action-btn,
.pill-btn,
.tool-btn,
.link {
  appearance: none;
  border: none;
  cursor: pointer;
  transition: all 0.18s ease;
  font: inherit;
}

.btn-submit {
  width: 100%;
  background: rgba(100, 108, 255, 0.22);
  border: 1.5px solid rgba(100, 108, 255, 0.45);
  color: #c5c8ff;
  border-radius: 12px;
  padding: 13px;
  font-size: 15px;
  font-weight: 700;
  cursor: pointer;
  letter-spacing: 0.02em;
  transition: background 0.15s, transform 0.1s, box-shadow 0.15s, opacity 0.15s;
}

.btn-submit:hover:not(:disabled) {
  background: rgba(100, 108, 255, 0.35);
  transform: translateY(-1px);
  box-shadow: 0 4px 20px rgba(100, 108, 255, 0.18);
}

.btn-submit:active:not(:disabled) {
  transform: translateY(0);
}

.btn-submit:disabled {
  opacity: 0.28;
  cursor: not-allowed;
}

.danger-text-btn {
  padding: 0 10px;
  border-radius: 10px;
  background: rgba(255, 80, 80, 0.08);
  color: rgba(255, 200, 200, 0.92);
  border: 1px solid rgba(255, 80, 80, 0.16);
  font-size: 12px;
  font-weight: 700;
}

.danger-text-btn:hover:not(:disabled) {
  background: rgba(255, 80, 80, 0.16);
}

.quick-btn,
.empty-action-btn,
.pill-btn {
  padding: 9px 12px;
  border-radius: 999px;
  background: rgba(100, 108, 255, 0.12);
  color: #d7dbff;
  border: 1px solid rgba(100, 108, 255, 0.24);
  font-size: 13px;
  line-height: 1.35;
}

.quick-btn:hover:not(:disabled),
.empty-action-btn:hover:not(:disabled),
.pill-btn:hover:not(:disabled) {
  background: rgba(100, 108, 255, 0.2);
  border-color: rgba(100, 108, 255, 0.36);
}

.chat-shell {
  display: flex;
  flex-direction: column;
  min-height: 0;
  overflow: hidden;
  backdrop-filter: blur(14px);
}

.chat-header {
  padding: 20px 22px 16px;
  border-bottom: 1px solid rgba(255, 255, 255, 0.07);
  background: rgba(255, 255, 255, 0.02);
  flex: 0 0 auto;
}

.chat-title {
  font-size: 21px;
  font-weight: 800;
  color: rgba(245, 247, 255, 0.98);
  line-height: 1.35;
}

.chat-subtitle {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
  margin-top: 8px;
  font-size: 12px;
  color: rgba(226, 232, 240, 0.55);
}

.message-pane {
  flex: 1 1 auto;
  min-height: 0;
  overflow: auto;
  padding: 18px 18px 10px;
  scroll-behavior: smooth;
}

.empty-state {
  max-width: 760px;
  margin: 42px auto;
  padding: 28px;
  border: 1px solid rgba(255, 255, 255, 0.08);
  border-radius: 20px;
  background: rgba(255, 255, 255, 0.03);
  text-align: center;
}

.empty-badge {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  padding: 6px 12px;
  border-radius: 999px;
  background: rgba(100, 108, 255, 0.12);
  border: 1px solid rgba(100, 108, 255, 0.25);
  color: #d7dbff;
  font-size: 12px;
  font-weight: 700;
}

.empty-title {
  margin-top: 14px;
  font-size: 24px;
  font-weight: 800;
  color: rgba(245, 247, 255, 0.98);
}

.empty-desc {
  margin-top: 10px;
  color: rgba(226, 232, 240, 0.62);
  line-height: 1.8;
}

.empty-actions {
  display: flex;
  flex-wrap: wrap;
  justify-content: center;
  gap: 10px;
  margin-top: 18px;
}

.msg {
  width: min(100%, 920px);
  margin: 0 auto 16px;
  padding: 14px 16px;
  border-radius: 18px;
  border: 1px solid rgba(255, 255, 255, 0.08);
  background: rgba(255, 255, 255, 0.04);
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.14);
  box-sizing: border-box;
}

.role-user {
  background: rgba(100, 108, 255, 0.08);
  border-color: rgba(100, 108, 255, 0.24);
}

.role-assistant {
  background: rgba(255, 255, 255, 0.04);
}

.msg-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  margin-bottom: 10px;
}

.msg-head-left,
.msg-head-right {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 8px;
}

.role-badge,
.mini-badge,
.pill,
.toolbar-tag {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: 4px 9px;
  border-radius: 999px;
  font-size: 12px;
  font-weight: 700;
}

.badge-user {
  background: rgba(100, 108, 255, 0.14);
  color: #cfd4ff;
}

.badge-assistant {
  background: rgba(255, 255, 255, 0.08);
  color: rgba(245, 247, 255, 0.92);
}

.mini-badge {
  background: rgba(255, 255, 255, 0.07);
  color: rgba(226, 232, 240, 0.78);
  border: 1px solid rgba(255, 255, 255, 0.06);
}

.mini-badge.warn {
  background: rgba(255, 166, 0, 0.1);
  color: #ffd89a;
  border-color: rgba(255, 166, 0, 0.2);
}

.msg-time {
  font-size: 12px;
  color: rgba(226, 232, 240, 0.46);
}

.msg-body {
  font-size: 15px;
  line-height: 1.85;
  color: rgba(245, 247, 255, 0.94);
  word-break: break-word;
}

.user-body {
  white-space: pre-wrap;
}

.assistant-body :deep(p) {
  margin: 0 0 12px;
}

.assistant-body :deep(p:last-child) {
  margin-bottom: 0;
}

.assistant-body :deep(pre) {
  margin: 12px 0;
  padding: 12px 14px;
  overflow: auto;
  border-radius: 12px;
  background: rgba(4, 10, 24, 0.88);
  color: #e2e8f0;
  font-size: 13px;
  line-height: 1.6;
  border: 1px solid rgba(255, 255, 255, 0.08);
}

.assistant-body :deep(code) {
  font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace;
}

.assistant-body :deep(:not(pre) > code) {
  padding: 2px 6px;
  border-radius: 8px;
  background: rgba(255, 255, 255, 0.08);
  color: #eef2ff;
}

.sub-block {
  margin-top: 14px;
  padding-top: 12px;
  border-top: 1px dashed rgba(255, 255, 255, 0.08);
}

.sub-block-title {
  margin-bottom: 8px;
  font-size: 13px;
  font-weight: 800;
  color: rgba(226, 232, 240, 0.88);
}

.reasoning-block {
  background: rgba(100, 108, 255, 0.08);
  border-radius: 12px;
  padding: 12px;
  border: 1px solid rgba(100, 108, 255, 0.18);
}

.reasoning-content {
  white-space: pre-wrap;
  font-size: 14px;
  line-height: 1.7;
  color: #dddfff;
}

.pill-row {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.pill {
  background: rgba(100, 108, 255, 0.12);
  color: #d7dbff;
  border: 1px solid rgba(100, 108, 255, 0.2);
}

.pill.soft {
  background: rgba(255, 255, 255, 0.06);
  color: rgba(226, 232, 240, 0.84);
  border-color: rgba(255, 255, 255, 0.06);
}

.source-list {
  display: grid;
  gap: 10px;
}

.source-card {
  padding: 12px;
  border-radius: 14px;
  border: 1px solid rgba(255, 255, 255, 0.08);
  background: rgba(255, 255, 255, 0.03);
}

.source-top {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  align-items: center;
}

.source-title {
  font-size: 14px;
  font-weight: 700;
  color: rgba(245, 247, 255, 0.96);
}

.source-id {
  margin-top: 6px;
  font-size: 12px;
  color: rgba(226, 232, 240, 0.46);
}

.source-snippet {
  margin-top: 8px;
  font-size: 13px;
  line-height: 1.65;
  color: rgba(226, 232, 240, 0.72);
  white-space: pre-wrap;
}

.msg-actions {
  display: flex;
  justify-content: flex-end;
  margin-top: 10px;
}

.text-btn {
  padding: 6px 10px;
  border-radius: 10px;
  background: rgba(255, 255, 255, 0.05);
  color: rgba(226, 232, 240, 0.72);
  border: 1px solid rgba(255, 255, 255, 0.06);
  font-size: 12px;
  font-weight: 700;
}

.text-btn:hover {
  background: rgba(255, 255, 255, 0.1);
  color: rgba(245, 247, 255, 0.92);
}

.typing-box {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  margin: 8px auto 0;
  padding: 12px 14px;
  border-radius: 999px;
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(255, 255, 255, 0.08);
  color: rgba(226, 232, 240, 0.72);
  font-size: 13px;
  box-shadow: 0 8px 20px rgba(0, 0, 0, 0.12);
}

.typing-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: #8f95ff;
  animation: blink 1.1s infinite ease-in-out;
}

.typing-dot:nth-child(2) {
  animation-delay: 0.15s;
}

.typing-dot:nth-child(3) {
  animation-delay: 0.3s;
}

@keyframes blink {
  0%,
  80%,
  100% {
    opacity: 0.25;
    transform: translateY(0);
  }
  40% {
    opacity: 1;
    transform: translateY(-2px);
  }
}

.composer {
  flex: 0 0 auto;
  padding: 14px 18px 18px;
  border-top: 1px solid rgba(255, 255, 255, 0.07);
  background: rgba(255, 255, 255, 0.02);
  overflow: visible;
}

.error-box {
  margin-bottom: 10px;
  padding: 11px 12px;
  border-radius: 12px;
  border: 1px solid rgba(255, 80, 80, 0.18);
  background: rgba(255, 80, 80, 0.08);
  color: rgba(255, 200, 200, 0.95);
  font-size: 13px;
  line-height: 1.6;
}

.composer-shell {
  position: relative;
  padding: 14px;
  border-radius: 18px;
  background: rgba(0, 0, 0, 0.14);
  border: 1px solid rgba(255, 255, 255, 0.08);
}

.composer-toolbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  margin-bottom: 12px;
}

.tool-btn {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  padding: 10px 12px;
  border-radius: 12px;
  background: rgba(100, 108, 255, 0.12);
  color: #d7dbff;
  border: 1px solid rgba(100, 108, 255, 0.24);
  white-space: nowrap;
  flex-shrink: 0;
}

.tool-btn:hover {
  background: rgba(100, 108, 255, 0.2);
  border-color: rgba(100, 108, 255, 0.36);
}

.tool-icon {
  font-size: 14px;
  line-height: 1;
}

.tool-count {
  min-width: 20px;
  height: 20px;
  padding: 0 6px;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  border-radius: 999px;
  background: rgba(255, 255, 255, 0.14);
  color: #eef2ff;
  font-size: 12px;
  font-weight: 800;
}

.toolbar-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  justify-content: flex-end;
}

.toolbar-tag {
  background: rgba(255, 255, 255, 0.05);
  color: rgba(226, 232, 240, 0.84);
  border: 1px solid rgba(255, 255, 255, 0.06);
}

.settings-pop {
  position: absolute;
  left: 0;
  right: 0;
  bottom: calc(100% + 12px);
  z-index: 20;
  padding: 16px;
  border-radius: 18px;
  background: rgba(15, 23, 42, 0.96);
  border: 1px solid rgba(255, 255, 255, 0.1);
  box-shadow: 0 18px 40px rgba(0, 0, 0, 0.32);
  backdrop-filter: blur(18px);
}

.settings-pop-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  margin-bottom: 14px;
}

.settings-pop-title {
  font-size: 14px;
  font-weight: 800;
  color: rgba(245, 247, 255, 0.96);
}

.link {
  background: transparent;
  color: rgba(226, 232, 240, 0.72);
  text-decoration: underline;
  font-size: 13px;
}

.link:hover {
  color: rgba(245, 247, 255, 0.96);
}

.settings-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 12px;
}

.setting-item + .setting-item {
  margin-top: 0;
}

.setting-label {
  display: block;
  margin-bottom: 7px;
  font-size: 11px;
  font-weight: 700;
  opacity: 0.65;
  letter-spacing: 0.07em;
  text-transform: uppercase;
  color: rgba(226, 232, 240, 0.92);
}

.select,
.composer-input {
  width: 100%;
  box-sizing: border-box;
  background: rgba(0, 0, 0, 0.15);
  border: 1.5px solid rgba(255, 255, 255, 0.1);
  border-radius: 12px;
  color: inherit;
  font: inherit;
  outline: none;
  transition: border-color 0.15s, background 0.15s, box-shadow 0.15s;
}

.select {
  padding: 11px 12px;
}

.select:focus,
.composer-input:focus {
  border-color: rgba(100, 108, 255, 0.55);
  background: rgba(100, 108, 255, 0.04);
  box-shadow: 0 0 0 4px rgba(100, 108, 255, 0.08);
}

.switch-list {
  margin-top: 12px;
}

.switch-row {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 12px;
  padding: 12px 0;
  border-top: 1px solid rgba(255, 255, 255, 0.06);
}

.switch-row:first-of-type {
  border-top: none;
  padding-top: 4px;
}

.switch-title {
  font-size: 14px;
  font-weight: 700;
  color: rgba(245, 247, 255, 0.96);
}

.switch-desc {
  margin-top: 4px;
  font-size: 12px;
  line-height: 1.5;
  color: rgba(226, 232, 240, 0.58);
}

.switch {
  flex: 0 0 auto;
  width: 50px;
  height: 30px;
  padding: 3px;
  border: none;
  border-radius: 999px;
  background: rgba(255, 255, 255, 0.18);
  cursor: pointer;
  transition: background 0.18s ease;
}

.switch.on {
  background: rgba(100, 108, 255, 0.85);
}

.switch-dot {
  display: block;
  width: 24px;
  height: 24px;
  border-radius: 50%;
  background: #fff;
  transition: transform 0.18s ease;
  box-shadow: 0 2px 6px rgba(15, 23, 42, 0.16);
}

.switch.on .switch-dot {
  transform: translateX(20px);
}

.composer-input {
  resize: vertical;
  min-height: 120px;
  max-height: 260px;
  padding: 14px 16px;
  line-height: 1.75;
}

.composer-input::placeholder {
  opacity: 0.35;
}

.composer-bar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  margin-top: 12px;
}

.composer-tip {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
  font-size: 12px;
  color: rgba(226, 232, 240, 0.48);
}

.send-btn {
  width: auto;
  min-width: 120px;
  padding-left: 20px;
  padding-right: 20px;
}

.mono {
  font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace;
}

.conversation-list::-webkit-scrollbar,
.message-pane::-webkit-scrollbar {
  width: 8px;
}

.conversation-list::-webkit-scrollbar-thumb,
.message-pane::-webkit-scrollbar-thumb {
  background: rgba(255, 255, 255, 0.12);
  border-radius: 999px;
}

.conversation-list::-webkit-scrollbar-track,
.message-pane::-webkit-scrollbar-track {
  background: transparent;
}

@media (max-width: 1080px) {
  .agent-page {
    grid-template-columns: 1fr;
    height: auto;
    min-height: 100vh;
    overflow: visible;
  }

  .sidebar {
    order: 2;
    overflow: visible;
  }

  .chat-shell {
    order: 1;
    min-height: 72vh;
  }

  .conversation-panel {
    min-height: 320px;
  }
}

@media (max-width: 760px) {
  .settings-grid {
    grid-template-columns: 1fr;
  }

  .composer-toolbar {
    flex-direction: column;
    align-items: stretch;
  }

  .toolbar-tags {
    justify-content: flex-start;
  }

  .settings-pop {
    left: -2px;
    right: -2px;
  }
}

@media (max-width: 640px) {
  .agent-page {
    padding: 10px;
    gap: 10px;
  }

  .chat-header,
  .message-pane,
  .composer,
  .panel,
  .brand-card {
    padding-left: 14px;
    padding-right: 14px;
  }

  .conversation-row {
    grid-template-columns: 1fr;
  }

  .danger-text-btn {
    padding: 9px 10px;
  }

  .composer-bar {
    flex-direction: column;
    align-items: stretch;
  }

  .send-btn {
    width: 100%;
  }

  .empty-state {
    padding: 20px 16px;
  }

  .msg {
    padding: 13px 14px;
  }
}
</style>