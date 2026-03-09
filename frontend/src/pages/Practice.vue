<template>
  <section class="page">

    <!-- ─── Header ─── -->
    <header class="card top">
      <div class="top__brand">
        <span class="brand-icon">⚡</span>
        <div>
          <h1 class="h1">练习中心</h1>
          <p class="sub">章节练习 · 推荐题目 · 巩固练习</p>
        </div>
      </div>

      <div class="top__right">
        <nav class="tabs">
          <button :class="{ on: tab === 'chapter' }" @click="setTab('chapter')">章节练习</button>
          <button :class="{ on: tab === 'recommended' }" @click="setTab('recommended')">推荐题目</button>
        </nav>

        <div class="toolbar">
          <label class="pill">
            <span class="pill__label">🔍</span>
            <input v-model="query" class="pill__input" placeholder="搜索题干关键词…" />
          </label>
          <label class="pill" v-if="tab === 'chapter'">
            <span class="pill__label">分类</span>
            <select
              v-model="category"
              class="pill__input pill__input--sm ui-select"
              :disabled="loadingChapters"
              @change="onCategoryChange"
            >
              <option v-for="c in categoryOptions" :key="c" :value="c">
                {{ c }}
              </option>
            </select>
          </label>
          <button class="btn-ghost" @click="reloadAll">↺ 刷新</button>
        </div>
      </div>
    </header>

    <!-- ─── Body Grid ─── -->
    <!-- 增加动态 class：当没有侧边栏时，移除 300px 的网格列限制 -->
    <div class="body-grid" :class="{ 'no-sidebar': tab !== 'chapter' }">

      <!-- ─── Sidebar: Chapter List ─── -->
      <aside v-if="tab === 'chapter'" class="card sidebar">
        <div class="panel-head">
          <span class="panel-title">章节列表</span>
          <div class="spacer" />
          <button class="btn-ghost btn-sm" :disabled="loadingChapters" @click="loadChapters">刷新</button>
        </div>

        <div v-if="loadingChapters" class="loading-row">
          <span class="spin" /><span class="muted">加载中…</span>
        </div>
        <div v-else-if="chaptersError" class="err-box">{{ chaptersError }}</div>

        <div v-else class="chapter-list">
          <button
            v-for="c in chapters"
            :key="c.kpId"
            class="chapter-btn"
            :class="{ active: c.kpId === selectedKpId, done: c.done }"
            @click="selectChapter(c.kpId)"
          >
            <div class="chapter-btn__row">
              <span class="status-dot" :class="c.done ? 'dot-done' : 'dot-todo'">{{ c.done ? '✓' : '' }}</span>
              <div class="chapter-btn__text">
                <span class="mono ch-id">{{ c.kpId }}</span>
                <span class="ch-title">{{ c.title || '(no title)' }}</span>
              </div>
              <span v-if="c.difficulty != null" class="diff-tag">Lv{{ c.difficulty }}</span>
            </div>
            <div class="ch-prog">
              <div class="prog-bar">
                <div class="prog-fill" :style="{ width: percent(c.attempted, c.totalQuestions) + '%' }" />
              </div>
              <div class="prog-nums muted small">
                <span>{{ c.attempted ?? 0 }}/{{ c.totalQuestions ?? 0 }}</span>
                <span>{{ percent(c.attempted, c.totalQuestions) }}%</span>
              </div>
            </div>
          </button>
        </div>
      </aside>

      <!-- ─── Main Content ─── -->
      <main class="main-col">

        <!-- Question List Card -->
        <div class="card">
          <div class="panel-head">
            <div class="panel-head__left">
              <span class="panel-title">
                <template v-if="tab === 'chapter'">
                  题目列表<span v-if="selectedKpId"> · <em class="mono accent">{{ selectedKpId }}</em></span>
                </template>
                <span v-else>推荐题目 · 错题池</span>
              </span>
              <span v-if="!rightLoading && filteredRows.length > 0" class="cnt-badge">{{ filteredRows.length }} 题</span>
            </div>
            <div class="spacer" />
            <div class="filter-bar">
              <button class="fbtn" :class="{ on: filter === 'all' }"   @click="filter = 'all'">全部</button>
              <button class="fbtn" :class="{ on: filter === 'todo' }"  @click="filter = 'todo'">未做</button>
              <button class="fbtn" :class="{ on: filter === 'done' }"  @click="filter = 'done'">已做</button>
              <button class="fbtn" :class="{ on: filter === 'wrong' }" @click="filter = 'wrong'">错题</button>
            </div>
            <button class="btn-ghost btn-sm" :disabled="rightLoading" @click="reloadRight">↺</button>
          </div>

          <!-- Loading / Error -->
          <div v-if="rightLoading" class="loading-row"><span class="spin" /><span class="muted">加载题目中…</span></div>
          <div v-else-if="rightError" class="err-box">{{ rightError }}</div>

          <template v-else>
            <div v-if="tab === 'chapter' && !selectedKpId" class="empty-state">
              <div class="empty-state__ico">👈</div>
              <div class="empty-state__msg">请在左侧选择一个章节</div>
              <div class="empty-state__sub muted small">点击任意章节以查看题目列表</div>
            </div>
            <div v-else-if="filteredRows.length === 0" class="empty-state">
              <div class="empty-state__ico">📭</div>
              <div class="empty-state__msg">暂无符合条件的题目</div>
              <div class="empty-state__sub muted small">尝试切换筛选条件</div>
            </div>

            <div v-else class="q-list">
              <div
                v-for="(r, i) in filteredRows"
                :key="r.questionId"
                class="q-item"
                :class="{
                  'q-item--current': active && active.id === r.questionId,
                  'q-item--done':  r.attempted === true && !(r.wrongCount && r.wrongCount > 0),
                  'q-item--wrong': !!(r.wrongCount && r.wrongCount > 0)
                }"
              >
                <span class="q-num">{{ i + 1 }}</span>

                <div class="q-body">
                  <div class="q-title-row">
                    <span class="type-chip">{{ typeLabel(r.type) }}</span>
                    <span class="q-stem">{{ r.stem }}</span>
                  </div>
                  <div v-if="r.difficulty != null || r.lastWrongAt" class="q-meta">
                    <span v-if="r.difficulty != null" class="meta-pill">难度 {{ r.difficulty }}</span>
                    <span v-if="r.lastWrongAt" class="meta-pill meta-pill--warn">错误 {{ formatTime(r.lastWrongAt) }}</span>
                  </div>
                </div>

                <div class="q-side">
                  <span v-if="r.attempted === true && !(r.wrongCount && r.wrongCount > 0)" class="st-pill st-ok">✓ 已做</span>
                  <span v-else-if="r.wrongCount && r.wrongCount > 0" class="st-pill st-bad">✗ 错{{ r.wrongCount }}次</span>
                  <span v-else class="st-pill">未做</span>
                  <div class="q-acts">
                    <button class="btn-primary btn-sm" @click="openQuestion(r)">
                      {{ active && active.id === r.questionId ? '当前' : '开始' }}
                    </button>
                    <button v-if="tab === 'recommended'" class="btn-ghost btn-sm" @click="markMastered(r.questionId)">已掌握</button>
                  </div>
                </div>
              </div>
            </div>
          </template>
        </div>

        <!-- ─── Quiz Runner ─── -->
        <div v-if="active" class="card runner">

          <!-- Runner Top Bar -->
          <div class="runner-bar">
            <span class="mode-chip">{{ active.context.mode }}</span>
            <span v-if="active.context.contextKpId" class="kp-chip mono">{{ active.context.contextKpId }}</span>
            <span v-if="active.context.sourceQuestionId" class="meta-pill mono">来源 {{ active.context.sourceQuestionId }}</span>
            <div class="spacer" />
            <button class="btn-ghost" @click="closeRunner">✕ 关闭</button>
          </div>

          <!-- Question Display -->
          <div class="runner-q">
            <span class="type-chip type-chip--accent">{{ typeLabel(active.type) }}</span>
            <div class="runner-stem">{{ active.stem }}</div>
          </div>

          <!-- Choice Options -->
          <div v-if="isChoice(active.type)" class="op-list">
            <button
              v-for="op in active.options"
              :key="op.id"
              class="op"
              :class="optionClass(op.id)"
              @click="pickOption(op.id)"
            >
              <span class="op__letter">{{ op.id }}</span>
              <span class="op__text">{{ op.text }}</span>
              <span class="op__ctrl">
                <input
                  v-if="active.type === 'SINGLE_CHOICE'"
                  type="radio" name="single"
                  :value="op.id" v-model="singleSelected" @click.stop
                />
                <input
                  v-else
                  type="checkbox"
                  :value="op.id" v-model="multiSelected" @click.stop
                />
              </span>
            </button>
          </div>

          <!-- Short Answer -->
          <textarea v-else class="sa" v-model="shortAnswer" placeholder="请输入你的答案…" rows="5" />

          <!-- Actions -->
          <div class="runner-acts">
            <button class="btn-submit" :disabled="!canSubmit || submitting" @click="submit">
              {{ submitting ? '提交中…' : '提交答案' }}
            </button>
            <button
              v-if="submitResult && submitResult.isCorrect === false"
              class="btn-reinforce"
              :disabled="reinforcing"
              @click="loadReinforcement"
            >
              {{ reinforcing ? '加载中…' : '⟳ 巩固练习' }}
            </button>
            <span v-if="submitResult" class="muted small">
              graded={{ submitResult.graded }},
              isCorrect={{ submitResult.isCorrect === null ? 'null' : submitResult.isCorrect }}
            </span>
          </div>

          <!-- Result Banner -->
          <div v-if="submitResult" class="res-banner" :class="bannerClass">
            <template v-if="submitResult.graded && submitResult.isCorrect === true">
              <span class="res-banner__ico">🎉</span>
              <div>
                <div class="res-banner__title">回答正确！</div>
                <div class="res-banner__sub">已记录本次作答，继续保持！</div>
              </div>
            </template>
            <template v-else-if="submitResult.graded && submitResult.isCorrect === false">
              <span class="res-banner__ico">💡</span>
              <div>
                <div class="res-banner__title">回答错误</div>
                <div class="res-banner__sub">查看下方解析了解正确答案，或点击「巩固练习」加强记忆。</div>
              </div>
            </template>
            <template v-else>
              <span class="res-banner__ico">📝</span>
              <div>
                <div class="res-banner__title">已提交，待批改</div>
                <div class="res-banner__sub">
                  可能原因：题型为简答题或题库未配置标准答案字段（<span class="mono">solution.answer</span>）。
                </div>
              </div>
            </template>
          </div>

          <!-- Explanation / Solution -->
          <div v-if="submitResult" class="expl">
            <div class="expl__title">解析</div>
            <div v-if="submitResult.explanation" class="expl__text">{{ submitResult.explanation }}</div>
            <div v-if="isChoice(active.type)" class="expl__ans">
              <span class="muted small">识别到的标准答案：</span>
              <span class="ans-chip mono">{{ prettyCorrectAnswer }}</span>
            </div>
            <details class="sol">
              <summary>查看完整 solution（提交后解锁）</summary>
              <pre class="sol__pre">{{ JSON.stringify(unlockedSolution, null, 2) }}</pre>
            </details>
          </div>

          <!-- Reinforcement List -->
          <div v-if="reinforcement.length || reinforcementKps.length" class="reinforce">

            <!-- 先学知识点 -->
            <template v-if="reinforcementKps.length">
              <div class="reinforce__title">建议先学知识点</div>
              <div class="q-list">
                <div v-for="k in reinforcementKps" :key="k.kpId" class="q-item">
                  <div class="q-body">
                    <div class="q-title-row">
                      <span class="type-chip">知识点</span>
                      <span class="q-stem">{{ k.title || k.kpId }}</span>
                    </div>
                    <div class="q-meta">
                      <span class="meta-pill mono">{{ k.kpId }}</span>
                      <span v-if="k.difficulty != null" class="meta-pill">难度 {{ k.difficulty }}</span>
                      <span v-if="k.depth != null" class="meta-pill">前置层级 +{{ k.depth }}</span>
                    </div>
                  </div>

                  <div class="q-side">
                    <button class="btn-primary btn-sm" @click="goToKp(k.kpId)">
                      去章节练习
                    </button>
                  </div>
                </div>
              </div>
            </template>

            <!-- 巩固题 -->
            <template v-if="reinforcement.length">
              <div class="reinforce__title" :style="reinforcementKps.length ? { marginTop: '12px' } : {}">
                巩固练习题
              </div>
              <div class="q-list">
                <div v-for="rr in reinforcement" :key="rr.questionId" class="q-item">
                  <div class="q-body">
                    <div class="q-title-row">
                      <span class="type-chip">{{ typeLabel(rr.type) }}</span>
                      <span class="q-stem">{{ rr.stem }}</span>
                    </div>
                    <div v-if="rr.difficulty != null" class="q-meta">
                      <span class="meta-pill">难度 {{ rr.difficulty }}</span>
                    </div>
                  </div>
                  <div class="q-side">
                    <button
                      class="btn-primary btn-sm"
                      @click="openQuestion(rr, { mode: 'REINFORCEMENT', sourceQuestionId: reinforcementSourceQuestionId })"
                    >
                      练这题
                    </button>
                  </div>
                </div>
              </div>
            </template>

          </div>

        </div><!-- /runner -->
      </main>
    </div>
  </section>
</template>

<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { api } from '../lib/api.ts'

type PracticeMode = 'CHAPTER' | 'RECOMMENDED' | 'REINFORCEMENT'
type Filter = 'all' | 'todo' | 'done' | 'wrong'

type ChapterRowApi = {
  kpId: string
  title?: string
  difficulty?: number
  totalQuestions?: number
  attempted?: number
  done?: boolean
}

type QuestionRowUi = {
  questionId: string
  type?: 'SINGLE_CHOICE' | 'MULTI_CHOICE' | 'SHORT_ANSWER'
  stem: string
  difficulty?: number
  attempted?: boolean | null
  wrongCount?: number | null
  lastWrongAt?: any
}

type QuestionResponse = {
  id: string
  type: 'SINGLE_CHOICE' | 'MULTI_CHOICE' | 'SHORT_ANSWER'
  stem: string
  difficulty: number
  content: Record<string, any>
  solution: Record<string, any> | null
  explanation: string | null
}

type SubmitResult = {
  attemptId?: string
  graded: boolean
  isCorrect: boolean | null
  solution?: Record<string, any>
  explanation?: string
  kpIds?: string[]
}

type RecoKpRowApi = {
  kpId: string
  title?: string | null
  difficulty?: number | null
  depth?: number | null
}

type ReinforcementResponseApi = {
  questions?: any[]
  knowledgePoints?: RecoKpRowApi[]
}

type Option = { id: string; text: string }

type ActiveQuestion = {
  id: string
  type: 'SINGLE_CHOICE' | 'MULTI_CHOICE' | 'SHORT_ANSWER'
  stem: string
  options: Option[]
  explanation: string | null
  context: {
    mode: PracticeMode
    contextKpId?: string | null
    sourceQuestionId?: string | null
  }
}

const baseCategoryOptions = ['FND','BOOL', 'COMB', 'ARITH', 'SEQ', 'TIM', 'FSM','MEM']

const tab = ref<'chapter' | 'recommended'>('chapter')
const category = ref('FND')
const query = ref('')
const filter = ref<Filter>('all')

const chapters = ref<ChapterRowApi[]>([])
const selectedKpId = ref<string | null>(null)

const rows = ref<QuestionRowUi[]>([])
const reinforcement = ref<QuestionRowUi[]>([])
const reinforcementSourceQuestionId = ref<string | null>(null)
const reinforcementKps = ref<RecoKpRowApi[]>([])

const loadingChapters = ref(false)
const chaptersError = ref<string | null>(null)

const rightLoading = ref(false)
const rightError = ref<string | null>(null)

const active = ref<ActiveQuestion | null>(null)
const submitting = ref(false)
const reinforcing = ref(false)

const submitResult = ref<SubmitResult | null>(null)
const unlockedSolution = ref<Record<string, any> | null>(null)

const singleSelected = ref<string>('')
const multiSelected = ref<string[]>([])
const shortAnswer = ref<string>('')

const categoryOptions = computed(() => {
  const cur = (category.value || '').trim()
  const out = [...baseCategoryOptions]
  if (cur && !out.includes(cur)) out.unshift(cur)
  return out
})

// ---------- small helpers ----------
async function onCategoryChange() {
  // 切换分类后：清空当前章节选择与题目列表，并重新加载章节
  selectedKpId.value = null
  rows.value = []
  closeRunner()
  await loadChapters()
}

function toErrMsg(e: any): string {
  return e?.message || String(e)
}
function isChoice(t: ActiveQuestion['type']): boolean {
  return t === 'SINGLE_CHOICE' || t === 'MULTI_CHOICE'
}
function percent(a?: number, b?: number): number {
  const aa = typeof a === 'number' ? a : 0
  const bb = typeof b === 'number' ? b : 0
  if (bb <= 0) return 0
  return Math.max(0, Math.min(100, Math.round((aa / bb) * 100)))
}
function formatTime(x: any): string {
  try {
    const d = typeof x === 'string' || typeof x === 'number' ? new Date(x) : new Date(String(x))
    if (Number.isNaN(d.getTime())) return String(x)
    return d.toLocaleString()
  } catch {
    return String(x)
  }
}
function typeLabel(type?: string): string {
  const map: Record<string, string> = {
    SINGLE_CHOICE: '单选题',
    MULTI_CHOICE:  '多选题',
    SHORT_ANSWER:  '简答题',
  }
  return map[type ?? ''] ?? (type || 'QUESTION')
}
function dedupeByQuestionId(list: QuestionRowUi[]): QuestionRowUi[] {
  const seen = new Set<string>()
  const out: QuestionRowUi[] = []
  for (const r of list) {
    if (!r.questionId) continue
    if (seen.has(r.questionId)) continue
    seen.add(r.questionId)
    out.push(r)
  }
  return out
}

function normalizeQuestionRow(x: any): QuestionRowUi {
  const qid = x?.questionId ?? x?.id
  return {
    questionId: qid ? String(qid) : '',
    type: x?.type,
    stem: String(x?.stem ?? ''),
    difficulty: x?.difficulty,
    attempted: x?.attempted ?? null,
    wrongCount: x?.wrongCount ?? null,
    lastWrongAt: x?.lastWrongAt ?? null,
  }
}

function parseOptionsFromContent(content: Record<string, any>): Option[] {
  const raw = content?.options
  if (!Array.isArray(raw)) return []
  return raw.map((x: any) => ({
    id: String(x?.id),
    text: String(x?.text),
  }))
}

// ---------- filtering ----------
const filteredRows = computed(() => {
  const q = query.value.trim().toLowerCase()
  const base = rows.value.filter(r => {
    if (!q) return true
    return String(r.stem ?? '').toLowerCase().includes(q)
  })
  if (filter.value === 'all') return base
  if (filter.value === 'todo') return base.filter(r => r.attempted === false || r.attempted == null)
  if (filter.value === 'done') return base.filter(r => r.attempted === true)
  return base.filter(r => (r.wrongCount ?? 0) > 0)
})

// ---------- submit enable ----------
const canSubmit = computed(() => {
  if (!active.value) return false
  if (submitting.value) return false
  if (active.value.type === 'SINGLE_CHOICE') return !!singleSelected.value
  if (active.value.type === 'MULTI_CHOICE') return multiSelected.value.length > 0
  return shortAnswer.value.trim().length > 0
})

// ---------- correct answer extraction ----------
function asString(v: any): string | null {
  if (v == null) return null
  const s = String(v).trim()
  return s ? s : null
}
function asStringSet(v: any): Set<string> {
  const out = new Set<string>()
  if (v == null) return out
  if (Array.isArray(v)) {
    for (const x of v) { const s = asString(x); if (s) out.add(s) }
    return out
  }
  const s = asString(v)
  if (s) out.add(s)
  return out
}
function extractCorrectIdsFromSolution(sol: Record<string, any> | null, type: ActiveQuestion['type']): Set<string> {
  if (!sol) return new Set()
  if (type === 'SINGLE_CHOICE') {
    const s = asString(sol.correctOptionId) ?? asString(sol.answer) ?? asString(sol.correct) ?? asString(sol.expected)
    if (s) return new Set([s])
    const set = asStringSet(sol.correctOptionIds ?? sol.answers ?? sol.answer)
    if (set.size > 0) return new Set([Array.from(set)[0]])
    return new Set()
  }
  if (type === 'MULTI_CHOICE') {
    const set = asStringSet(sol.correctOptionIds)
    if (set.size > 0) return set
    const set2 = asStringSet(sol.answer ?? sol.answers)
    if (set2.size > 0) return set2
    const one = asString(sol.correctOptionId) ?? asString(sol.answer)
    return one ? new Set([one]) : new Set()
  }
  return new Set()
}

const correctIds = computed(() => extractCorrectIdsFromSolution(unlockedSolution.value, active.value?.type ?? 'SHORT_ANSWER'))

const prettyCorrectAnswer = computed(() => {
  const ids = Array.from(correctIds.value)
  if (ids.length === 0) return '(未识别到)'
  return ids.join(', ')
})

function optionClass(optionId: string): Record<string, boolean> {
  const isPickedSingle = singleSelected.value === optionId
  const isPickedMulti = multiSelected.value.includes(optionId)
  const picked = isPickedSingle || isPickedMulti
  const hasResult = !!submitResult.value
  const isCorrectOpt = correctIds.value.has(optionId)
  return {
    picked,
    correct: hasResult && isCorrectOpt,
    wrongPick: hasResult && picked && !isCorrectOpt && submitResult.value?.graded === true,
  }
}

const bannerClass = computed(() => {
  if (!submitResult.value) return ''
  if (submitResult.value.graded && submitResult.value.isCorrect === true) return 'ok'
  if (submitResult.value.graded && submitResult.value.isCorrect === false) return 'bad'
  return 'muted'
})

// ---------- actions ----------
function setTab(t: 'chapter' | 'recommended') {
  tab.value = t
  rows.value = []
  reinforcement.value = []
  closeRunner()
  reloadRight()
}

function selectChapter(kpId: string) {
  selectedKpId.value = kpId
  closeRunner()
  reloadRight()
}

async function loadChapters() {
  loadingChapters.value = true
  chaptersError.value = null
  try {
    chapters.value = await api.get<ChapterRowApi[]>(
      `/api/practice/chapters?category=${encodeURIComponent(category.value.trim() || 'BOOL')}`
    )
  } catch (e: any) {
    chaptersError.value = toErrMsg(e)
  } finally {
    loadingChapters.value = false
  }
}

async function loadChapterQuestions(kpId: string) {
  rightLoading.value = true
  rightError.value = null
  try {
    const raw = await api.get<any[]>(`/api/practice/chapters/${encodeURIComponent(kpId)}/questions`)
    rows.value = dedupeByQuestionId(raw.map(normalizeQuestionRow))
  } catch (e: any) {
    rightError.value = toErrMsg(e)
  } finally {
    rightLoading.value = false
  }
}

async function loadRecommended() {
  rightLoading.value = true
  rightError.value = null
  try {
    const raw = await api.get<any[]>(`/api/practice/recommended`)
    rows.value = dedupeByQuestionId(raw.map(normalizeQuestionRow))
  } catch (e: any) {
    rightError.value = toErrMsg(e)
  } finally {
    rightLoading.value = false
  }
}

async function reloadRight() {
  reinforcement.value = []
  reinforcementKps.value = []
  reinforcementSourceQuestionId.value = null
  submitResult.value = null
  unlockedSolution.value = null
  if (tab.value === 'chapter') {
    if (!selectedKpId.value) { rows.value = []; return }
    await loadChapterQuestions(selectedKpId.value)
  } else {
    await loadRecommended()
  }
}

async function refreshRightListOnly() {
  if (tab.value === 'chapter') {
    if (!selectedKpId.value) return
    await loadChapterQuestions(selectedKpId.value)
  } else {
    await loadRecommended()
  }
}

async function reloadAll() {
  closeRunner()
  if (tab.value === 'chapter') await loadChapters()
  await reloadRight()
}

function closeRunner() {
  active.value = null
  submitResult.value = null
  unlockedSolution.value = null
  reinforcement.value = []
  reinforcementKps.value = []
  reinforcementSourceQuestionId.value = null
  singleSelected.value = ''
  multiSelected.value = []
  shortAnswer.value = ''
}

async function openQuestion(
  row: QuestionRowUi,
  ctx?: { mode?: PracticeMode; sourceQuestionId?: string | null }
) {
  rightError.value = null
  if (!row?.questionId) {
    rightError.value = `题目数据缺少 id/questionId，无法打开。row=${JSON.stringify(row)}`
    return
  }
  submitResult.value = null
  unlockedSolution.value = null
  reinforcement.value = []
  reinforcementKps.value = []
  reinforcementSourceQuestionId.value = ctx?.sourceQuestionId ?? null
  try {
    const q = await api.get<QuestionResponse>(`/api/questions/${row.questionId}`)
    const mode: PracticeMode = ctx?.mode ?? (tab.value === 'chapter' ? 'CHAPTER' : 'RECOMMENDED')
    const opts = q.type === 'SHORT_ANSWER' ? [] : parseOptionsFromContent(q.content)
    if ((q.type === 'SINGLE_CHOICE' || q.type === 'MULTI_CHOICE') && opts.length === 0) {
      rightError.value = '题目 content.options 为空，无法渲染选择题'
      return
    }
    active.value = {
      id: q.id, type: q.type, stem: q.stem, options: opts,
      explanation: q.explanation ?? null,
      context: { mode, contextKpId: mode === 'CHAPTER' ? selectedKpId.value : null, sourceQuestionId: ctx?.sourceQuestionId ?? null },
    }
    singleSelected.value = ''
    multiSelected.value = []
    shortAnswer.value = ''
  } catch (e: any) {
    rightError.value = toErrMsg(e)
  }
}

function pickOption(optionId: string) {
  if (!active.value) return
  if (active.value.type === 'SINGLE_CHOICE') {
    singleSelected.value = optionId
  } else if (active.value.type === 'MULTI_CHOICE') {
    const idx = multiSelected.value.indexOf(optionId)
    if (idx >= 0) multiSelected.value.splice(idx, 1)
    else multiSelected.value.push(optionId)
  }
}

async function submit() {
  if (!active.value || !canSubmit.value) return
  submitting.value = true
  submitResult.value = null
  unlockedSolution.value = null
  try {
    const q = active.value
    const answer: Record<string, any> = {}
    if (q.type === 'SINGLE_CHOICE') {
      answer.selectedOptionId = singleSelected.value
      answer.answer = singleSelected.value
    } else if (q.type === 'MULTI_CHOICE') {
      answer.selectedOptionIds = [...multiSelected.value]
      answer.answer = [...multiSelected.value]
    } else {
      answer.text = shortAnswer.value.trim()
      answer.answer = shortAnswer.value.trim()
    }
    const body = {
      mode: q.context.mode,
      contextKpId: q.context.contextKpId || null,
      sourceQuestionId: q.context.sourceQuestionId || null,
      answer,
    }
    const r = await api.post<SubmitResult>(`/api/questions/${q.id}/submit`, body)
    submitResult.value = r
    unlockedSolution.value = r.solution ?? null
    await refreshRightListOnly()
  } catch (e: any) {
    rightError.value = toErrMsg(e)
  } finally {
    submitting.value = false
  }
}

async function markMastered(questionId: string) {
  try {
    await api.post<void>(`/api/practice/recommended/${questionId}/mastered`)
    await loadRecommended()
  } catch (e: any) {
    rightError.value = toErrMsg(e)
  }
}

async function loadReinforcement() {
  if (!active.value) return
  reinforcing.value = true
  try {
    reinforcementSourceQuestionId.value = active.value.id

    const resp = await api.get<ReinforcementResponseApi>(
      `/api/practice/reinforcement/${active.value.id}?count=2`
    )

    reinforcement.value = dedupeByQuestionId((resp.questions ?? []).map(normalizeQuestionRow))
    reinforcementKps.value = resp.knowledgePoints ?? []
  } catch (e: any) {
    rightError.value = toErrMsg(e)
  } finally {
    reinforcing.value = false
  }
}

function inferCategoryFromKpId(kpId: string): string | null {
  // 约定：DC-BOOL-05 / DC-COMB-01 这种
  const parts = String(kpId || '').split('-')
  if (parts.length >= 2 && parts[1]) return parts[1]
  return null
}

async function goToKp(kpId: string) {
  // 尽量自动切分类（BOOL/COMB/SEQ...）
  const inferred = inferCategoryFromKpId(kpId)
  if (inferred) category.value = inferred

  tab.value = 'chapter'
  selectedKpId.value = kpId

  closeRunner()
  await loadChapters()
  await loadChapterQuestions(kpId)
}

onMounted(async () => {
  await loadChapters()
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
}
p { margin: 0; }

/* ─── Layout ─── */
.body-grid {
  display: grid;
  grid-template-columns: 300px 1fr;
  gap: 14px;
  align-items: start;
}
/* 新增：当没有侧边栏时，主内容区独占一行 */
.body-grid.no-sidebar {
  grid-template-columns: 1fr;
}
@media (max-width: 960px) {
  .body-grid { grid-template-columns: 1fr; }
}
.main-col {
  display: flex;
  flex-direction: column;
  gap: 14px;
}

/* ─── Card ─── */
.card {
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 16px;
  padding: 16px;
}

/* ─── Header ─── */
.top {
  display: flex;
  align-items: center;
  gap: 16px;
  flex-wrap: wrap;
  justify-content: space-between;
}
.top__brand {
  display: flex;
  align-items: center;
  gap: 11px;
}
.brand-icon { font-size: 26px; line-height: 1; }
.h1 { margin: 0; font-size: 20px; font-weight: 800; }
.sub { margin: 2px 0 0; opacity: 0.6; font-size: 12px; }
.top__right {
  display: flex;
  flex-direction: column;
  align-items: flex-end;
  gap: 10px;
}
@media (max-width: 960px) {
  .top__right { align-items: flex-start; }
}

/* ─── Tabs ─── */
.tabs {
  display: flex;
  background: rgba(0, 0, 0, 0.2);
  border-radius: 12px;
  padding: 4px;
  gap: 4px;
}
.tabs button {
  padding: 7px 18px;
  border-radius: 9px;
  font-size: 13px;
  font-weight: 500;
  background: transparent;
  border: 1px solid transparent;
  opacity: 0.65;
  cursor: pointer;
  transition: background 0.15s, opacity 0.15s;
}
.tabs button.on {
  background: rgba(100, 108, 255, 0.22);
  border-color: rgba(100, 108, 255, 0.4);
  opacity: 1;
  font-weight: 700;
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
  padding: 7px 12px;
  border-radius: 999px;
  border: 1px solid rgba(255, 255, 255, 0.12);
  background: rgba(255, 255, 255, 0.04);
}
.pill__label { opacity: 0.65; font-size: 12px; white-space: nowrap; }
.pill__input {
  border: none;
  outline: none;
  color: var(--text-color);
  min-width: 160px;
  font-size: 13px;
}
.pill__input--sm { min-width: 80px; color: var(--text-color); }

/* ─── Buttons ─── */
.btn-ghost {
  background: transparent;
  border: 1px solid rgba(255, 255, 255, 0.12);
  border-radius: 10px;
  padding: 7px 12px;
  opacity: 0.8;
  font-size: 13px;
  cursor: pointer;
  transition: background 0.15s, opacity 0.15s;
  color: inherit;
}
.btn-ghost:hover:not(:disabled) { background: rgba(255, 255, 255, 0.07); opacity: 1; }
.btn-ghost:disabled { opacity: 0.3; cursor: not-allowed; }

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
  transition: background 0.15s;
}
.btn-primary:hover { background: rgba(100, 108, 255, 0.28); }

.btn-submit {
  background: rgba(100, 108, 255, 0.28);
  border: 1px solid rgba(100, 108, 255, 0.5);
  color: #c8cbff;
  border-radius: 10px;
  padding: 11px 26px;
  font-size: 14px;
  font-weight: 700;
  cursor: pointer;
  transition: background 0.15s, transform 0.1s;
}
.btn-submit:hover:not(:disabled) {
  background: rgba(100, 108, 255, 0.38);
  transform: translateY(-1px);
}
.btn-submit:disabled { opacity: 0.35; cursor: not-allowed; }

.btn-reinforce {
  background: rgba(255, 193, 7, 0.12);
  border: 1px solid rgba(255, 193, 7, 0.3);
  color: #ffd54f;
  border-radius: 10px;
  padding: 11px 18px;
  font-size: 13px;
  font-weight: 600;
  cursor: pointer;
  transition: background 0.15s;
}
.btn-reinforce:hover:not(:disabled) { background: rgba(255, 193, 7, 0.2); }
.btn-reinforce:disabled { opacity: 0.4; cursor: not-allowed; }

/* ─── Panel Header ─── */
.panel-head {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 12px;
  flex-wrap: wrap;
}
.panel-head__left {
  display: flex;
  align-items: center;
  gap: 8px;
}
.panel-title { font-weight: 800; font-size: 14px; }
.spacer { flex: 1; }
.cnt-badge {
  font-size: 11px;
  padding: 2px 9px;
  border-radius: 999px;
  background: rgba(100, 108, 255, 0.18);
  border: 1px solid rgba(100, 108, 255, 0.28);
  color: #b8bcff;
  font-weight: 700;
}

/* ─── Filter Bar ─── */
.filter-bar { display: flex; gap: 4px; }
.fbtn {
  padding: 5px 10px;
  border-radius: 8px;
  border: 1px solid rgba(255, 255, 255, 0.1);
  background: transparent;
  font-size: 12px;
  opacity: 0.65;
  cursor: pointer;
  transition: background 0.15s, opacity 0.15s;
  color: inherit;
}
.fbtn.on {
  background: rgba(100, 108, 255, 0.16);
  border-color: rgba(100, 108, 255, 0.35);
  opacity: 1;
  font-weight: 600;
}

/* ─── States ─── */
.loading-row {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 20px 4px;
  opacity: 0.65;
  font-size: 13px;
}
.spin {
  display: inline-block;
  width: 16px;
  height: 16px;
  border: 2px solid rgba(255, 255, 255, 0.15);
  border-top-color: rgba(100, 108, 255, 0.9);
  border-radius: 50%;
  animation: spin 0.7s linear infinite;
  flex-shrink: 0;
}
@keyframes spin { to { transform: rotate(360deg); } }

.err-box {
  padding: 10px 14px;
  border-radius: 10px;
  background: rgba(255, 80, 80, 0.08);
  border: 1px solid rgba(255, 80, 80, 0.2);
  color: #ff9090;
  font-size: 13px;
}

.empty-state {
  text-align: center;
  padding: 40px 20px;
}
.empty-state__ico { font-size: 30px; margin-bottom: 10px; }
.empty-state__msg { font-size: 15px; font-weight: 600; opacity: 0.7; }
.empty-state__sub { margin-top: 4px; opacity: 0.5; font-size: 12px; }

/* ─── Sidebar ─── */
.sidebar {
  display: flex;
  flex-direction: column;
  gap: 0;
  position: sticky;
  top: 14px;
  max-height: calc(100vh - 80px);
  overflow: hidden;
}
.chapter-list {
  display: flex;
  flex-direction: column;
  gap: 7px;
  overflow-y: auto;
  flex: 1;
  padding-right: 2px;
}
.chapter-list::-webkit-scrollbar { width: 4px; }
.chapter-list::-webkit-scrollbar-track { background: transparent; }
.chapter-list::-webkit-scrollbar-thumb { background: rgba(255, 255, 255, 0.15); border-radius: 2px; }

.chapter-btn {
  width: 100%;
  text-align: left;
  padding: 11px 12px;
  border-radius: 12px;
  border: 1px solid rgba(255, 255, 255, 0.08);
  background: rgba(255, 255, 255, 0.03);
  cursor: pointer;
  transition: background 0.15s, border-color 0.15s;
  border-left: 3px solid transparent;
  color: inherit;
}
.chapter-btn:hover {
  background: rgba(255, 255, 255, 0.06);
  border-color: rgba(255, 255, 255, 0.14);
}
.chapter-btn.active {
  background: rgba(100, 108, 255, 0.1);
  border-left-color: rgba(100, 108, 255, 0.55);
  border-color: rgba(100, 108, 255, 0.3);
}
.chapter-btn.done { border-left-color: rgba(80, 200, 120, 0.45); }

.chapter-btn__row {
  display: flex;
  align-items: flex-start;
  gap: 9px;
}
.status-dot {
  width: 20px;
  height: 20px;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  border-radius: 50%;
  font-size: 11px;
  font-weight: 800;
  flex-shrink: 0;
  margin-top: 1px;
}
.dot-done {
  background: rgba(80, 200, 120, 0.2);
  border: 1px solid rgba(80, 200, 120, 0.5);
  color: #50c878;
}
.dot-todo { border: 2px solid rgba(255, 255, 255, 0.2); }

.chapter-btn__text {
  flex: 1;
  min-width: 0;
  display: flex;
  flex-direction: column;
  gap: 2px;
}
.ch-id { font-size: 11px; opacity: 0.6; }
.ch-title {
  font-size: 13px;
  font-weight: 600;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}
.diff-tag {
  font-size: 11px;
  padding: 2px 7px;
  border-radius: 999px;
  border: 1px solid rgba(255, 255, 255, 0.1);
  opacity: 0.65;
  flex-shrink: 0;
  white-space: nowrap;
}

.ch-prog { margin-top: 10px; }
.prog-bar {
  height: 5px;
  background: rgba(255, 255, 255, 0.08);
  border-radius: 999px;
  overflow: hidden;
}
.prog-fill {
  height: 100%;
  background: linear-gradient(90deg, rgba(100, 108, 255, 0.7), rgba(140, 100, 255, 0.65));
  border-radius: 999px;
  transition: width 0.4s ease;
}
.chapter-btn.done .prog-fill {
  background: linear-gradient(90deg, rgba(80, 200, 120, 0.7), rgba(60, 180, 100, 0.65));
}
.prog-nums {
  display: flex;
  justify-content: space-between;
  margin-top: 4px;
}

/* ─── Question List ─── */
.q-list {
  display: flex;
  flex-direction: column;
  gap: 7px;
}

.q-item {
  display: flex;
  align-items: flex-start;
  gap: 12px;
  padding: 12px 14px;
  border-radius: 12px;
  border: 1px solid rgba(255, 255, 255, 0.08);
  border-left: 3px solid transparent;
  background: rgba(255, 255, 255, 0.03);
  transition: background 0.15s, border-color 0.15s;
}
.q-item:hover {
  background: rgba(255, 255, 255, 0.05);
  border-color: rgba(255, 255, 255, 0.13);
}
.q-item--current {
  background: rgba(100, 108, 255, 0.08) !important;
  border-color: rgba(100, 108, 255, 0.35) !important;
  border-left-color: rgba(100, 108, 255, 0.6) !important;
}
.q-item--done  { border-left-color: rgba(80, 200, 120, 0.5); }
.q-item--wrong { border-left-color: rgba(255, 100, 100, 0.5); }

.q-num {
  width: 26px;
  height: 26px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 8px;
  background: rgba(255, 255, 255, 0.06);
  font-size: 12px;
  font-weight: 700;
  flex-shrink: 0;
  margin-top: 1px;
  opacity: 0.75;
}

.q-body { flex: 1; min-width: 0; }
.q-title-row {
  display: flex;
  align-items: baseline;
  gap: 8px;
  flex-wrap: wrap;
}
.q-stem { font-weight: 600; font-size: 14px; line-height: 1.55; }
.q-meta { margin-top: 6px; display: flex; gap: 6px; flex-wrap: wrap; }

.q-side {
  display: flex;
  flex-direction: column;
  align-items: flex-end;
  gap: 8px;
  flex-shrink: 0;
}
.q-acts { display: flex; gap: 6px; flex-wrap: wrap; justify-content: flex-end; }

/* ─── Status Pills ─── */
.st-pill {
  display: inline-block;
  font-size: 11px;
  padding: 3px 9px;
  border-radius: 999px;
  border: 1px solid rgba(255, 255, 255, 0.13);
  background: rgba(255, 255, 255, 0.05);
  white-space: nowrap;
}
.st-ok  { border-color: rgba(80, 200, 120, 0.38); background: rgba(80, 200, 120, 0.1); color: #50c878; }
.st-bad { border-color: rgba(255, 100, 100, 0.38); background: rgba(255, 100, 100, 0.1); color: #ff8888; }

/* ─── Type Chip ─── */
.type-chip {
  display: inline-block;
  font-size: 11px;
  padding: 3px 8px;
  border-radius: 6px;
  border: 1px solid rgba(255, 255, 255, 0.1);
  background: rgba(255, 255, 255, 0.06);
  white-space: nowrap;
  flex-shrink: 0;
  font-weight: 600;
}
.type-chip--accent {
  border-color: rgba(100, 108, 255, 0.35);
  background: rgba(100, 108, 255, 0.15);
  color: #b8bcff;
}

/* ─── Meta Pill ─── */
.meta-pill {
  font-size: 11px;
  padding: 2px 7px;
  border-radius: 999px;
  border: 1px solid rgba(255, 255, 255, 0.1);
  background: rgba(255, 255, 255, 0.03);
  opacity: 0.8;
}
.meta-pill--warn {
  border-color: rgba(255, 180, 100, 0.3);
  background: rgba(255, 180, 100, 0.07);
  color: #ffb96a;
  opacity: 1;
}

/* ─── Quiz Runner ─── */
.runner {
  background: rgba(0, 0, 0, 0.16);
  border-color: rgba(100, 108, 255, 0.18);
}

.runner-bar {
  display: flex;
  align-items: center;
  gap: 8px;
  flex-wrap: wrap;
  padding-bottom: 14px;
  margin-bottom: 18px;
  border-bottom: 1px solid rgba(255, 255, 255, 0.07);
}
.mode-chip {
  font-size: 11px;
  padding: 3px 10px;
  border-radius: 6px;
  background: rgba(100, 108, 255, 0.2);
  border: 1px solid rgba(100, 108, 255, 0.35);
  color: #a8aeff;
  font-weight: 700;
}
.kp-chip {
  font-size: 12px;
  padding: 3px 8px;
  border-radius: 6px;
  background: rgba(255, 255, 255, 0.06);
  border: 1px solid rgba(255, 255, 255, 0.1);
  opacity: 0.8;
}

.runner-q { margin-bottom: 20px; }
.runner-stem {
  margin-top: 10px;
  font-size: 17px;
  font-weight: 700;
  line-height: 1.65;
}

/* ─── Option Cards ─── */
.op-list {
  display: flex;
  flex-direction: column;
  gap: 10px;
  margin-bottom: 22px;
}

.op {
  display: flex;
  align-items: center;
  gap: 14px;
  padding: 14px 16px;
  border-radius: 13px;
  border: 2px solid rgba(255, 255, 255, 0.1);
  background: rgba(255, 255, 255, 0.04);
  width: 100%;
  text-align: left;
  cursor: pointer;
  transition: background 0.15s, border-color 0.15s, transform 0.1s;
  color: inherit;
}
.op:hover:not(:disabled) {
  background: rgba(255, 255, 255, 0.07);
  border-color: rgba(100, 108, 255, 0.25);
  transform: translateX(2px);
}
.op.picked {
  border-color: rgba(100, 108, 255, 0.55);
  background: rgba(100, 108, 255, 0.11);
}
.op.correct {
  border-color: rgba(80, 200, 120, 0.6);
  background: rgba(80, 200, 120, 0.09);
}
.op.wrongPick {
  border-color: rgba(255, 100, 100, 0.6);
  background: rgba(255, 100, 100, 0.09);
}

.op__letter {
  width: 36px;
  height: 36px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 9px;
  background: rgba(255, 255, 255, 0.08);
  border: 1px solid rgba(255, 255, 255, 0.12);
  font-weight: 800;
  font-size: 14px;
  flex-shrink: 0;
  transition: background 0.15s, border-color 0.15s, color 0.15s;
}
.op.picked .op__letter {
  background: rgba(100, 108, 255, 0.3);
  border-color: rgba(100, 108, 255, 0.55);
  color: #c5c8ff;
}
.op.correct .op__letter {
  background: rgba(80, 200, 120, 0.28);
  border-color: rgba(80, 200, 120, 0.6);
  color: #50c878;
}
.op.wrongPick .op__letter {
  background: rgba(255, 100, 100, 0.28);
  border-color: rgba(255, 100, 100, 0.6);
  color: #ff8a8a;
}
.op__text { flex: 1; font-size: 14px; font-weight: 500; line-height: 1.5; }
.op__ctrl { flex-shrink: 0; opacity: 0.7; }

/* ─── Short Answer ─── */
.sa {
  width: 100%;
  border-radius: 12px;
  border: 1px solid rgba(255, 255, 255, 0.12);
  background: rgba(0, 0, 0, 0.15);
  color: inherit;
  padding: 12px 14px;
  font-size: 14px;
  resize: vertical;
  box-sizing: border-box;
  margin-bottom: 22px;
  font-family: inherit;
  transition: border-color 0.15s;
}
.sa:focus { outline: none; border-color: rgba(100, 108, 255, 0.45); }

/* ─── Runner Actions ─── */
.runner-acts {
  display: flex;
  align-items: center;
  gap: 12px;
  flex-wrap: wrap;
  margin-bottom: 18px;
}

/* ─── Result Banner ─── */
.res-banner {
  display: flex;
  align-items: flex-start;
  gap: 12px;
  padding: 14px 16px;
  border-radius: 13px;
  border: 1px solid rgba(255, 255, 255, 0.1);
  background: rgba(255, 255, 255, 0.04);
  margin-bottom: 14px;
}
.res-banner.ok  { border-color: rgba(80, 200, 120, 0.38); background: rgba(80, 200, 120, 0.07); }
.res-banner.bad { border-color: rgba(255, 100, 100, 0.38); background: rgba(255, 100, 100, 0.07); }
.res-banner.muted { border-color: rgba(255, 255, 255, 0.1); background: rgba(255, 255, 255, 0.03); }
.res-banner__ico { font-size: 22px; line-height: 1; flex-shrink: 0; margin-top: 1px; }
.res-banner__title { font-weight: 800; font-size: 15px; }
.res-banner__sub { margin-top: 3px; opacity: 0.8; font-size: 13px; }

/* ─── Explanation ─── */
.expl {
  padding: 14px 16px;
  border-radius: 12px;
  background: rgba(0, 0, 0, 0.1);
  border: 1px solid rgba(255, 255, 255, 0.07);
  margin-bottom: 14px;
}
.expl__title {
  font-weight: 800;
  font-size: 11px;
  text-transform: uppercase;
  letter-spacing: 0.07em;
  opacity: 0.55;
  margin-bottom: 10px;
}
.expl__text { font-size: 14px; line-height: 1.65; margin-bottom: 10px; }
.expl__ans { margin-top: 6px; }
.ans-chip {
  display: inline-block;
  padding: 2px 9px;
  border-radius: 6px;
  background: rgba(80, 200, 120, 0.13);
  border: 1px solid rgba(80, 200, 120, 0.3);
  color: #50c878;
  font-size: 13px;
}

.sol summary { cursor: pointer; font-size: 12px; opacity: 0.6; margin-top: 12px; display: block; }
.sol__pre {
  margin: 8px 0 0;
  padding: 12px;
  border-radius: 10px;
  background: rgba(0, 0, 0, 0.2);
  font-size: 12px;
  overflow: auto;
  border: 1px solid rgba(255, 255, 255, 0.06);
}

/* ─── Reinforce Section ─── */
.reinforce {
  border-top: 1px solid rgba(255, 255, 255, 0.07);
  padding-top: 14px;
}
.reinforce__title { font-weight: 800; margin-bottom: 12px; }

/* ─── Utilities ─── */
.muted  { opacity: 0.6; }
.small  { font-size: 12px; }
.mono   { font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, "Liberation Mono", "Courier New", monospace; }
.accent { color: #a5a9ff; font-style: normal; }
</style>