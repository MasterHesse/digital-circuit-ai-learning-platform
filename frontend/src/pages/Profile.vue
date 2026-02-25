<template>
  <section class="page">
    <!-- ─── Hero ─── -->
    <div class="card hero">
      <div class="hero-glow" />

      <div class="hero-top">
        <div class="hero-ident">
          <div class="avatar">{{ displayInitial }}</div>

          <div class="hero-meta">
            <div class="hero-greeting">你好，{{ displayName }} 👋</div>

            <div class="hero-chips">
              <span class="chip mono">UID: {{ meUserId }}</span>
              <span class="chip mono">username: {{ meUsername || '-' }}</span>
              <span class="chip mono">email: {{ meEmail || '-' }}</span>
              <span class="chip mono">role: {{ meRole || '-' }}</span>
            </div>

            <div v-if="meErr" class="hero-err">{{ meErr }}</div>
          </div>
        </div>

        <div class="hero-actions">
          <button class="btn-primary" @click="goPractice()">开始章节练习</button>
          <button class="btn-ghost" @click="goPractice('recommended')">推荐题目</button>
        </div>
      </div>

      <div class="sep" />

      <div class="stats">
        <div class="stat">
          <div class="stat-v">{{ stats.attempts }}</div>
          <div class="stat-k">已练题数</div>
        </div>
        <div class="stat-div" />
        <div class="stat">
          <div class="stat-v">
            {{ stats.accuracy }}<span class="stat-unit">%</span>
          </div>
          <div class="stat-k">正确率</div>
        </div>
        <div class="stat-div" />
        <div class="stat">
          <div class="stat-v">{{ stats.wrongPool }}</div>
          <div class="stat-k">错题池</div>
        </div>
      </div>
    </div>
  </section>
</template>

<script setup lang="ts">
import { computed, onMounted, reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import { api } from '../lib/api'
import { name, userId } from '../stores/session'

type MeResponse = {
  userId: string
  username: string
  email: string
  name: string
  role: 'STUDENT' | 'TEACHER' | 'ADMIN' | string
}

type MyClassResponse = {
  classId: string
  className: string
  teacherId: string
  status: 'PENDING' | 'APPROVED' | 'REJECTED' | string
  requestedAt: string
  decidedAt?: string | null
}

const router = useRouter()

const me = ref<MeResponse | null>(null)
const meErr = ref('')

const classLoading = ref(false)
const classErr = ref('')
const myClasses = ref<MyClassResponse[]>([])

const isStudent = computed(() => (me.value?.role || '') === 'STUDENT')

const approvedClasses = computed(() =>
  myClasses.value.filter((c) => c.status === 'APPROVED')
)
const pendingClasses = computed(() =>
  myClasses.value.filter((c) => c.status === 'PENDING')
)

const displayName = computed(() => me.value?.name || name.value || 'Student')
const displayInitial = computed(() => displayName.value.charAt(0).toUpperCase())

const meUserId = computed(() => me.value?.userId || userId.value || '')
const meUsername = computed(() => me.value?.username || '')
const meEmail = computed(() => me.value?.email || '')
const meRole = computed(() => me.value?.role || '')

const stats = reactive({
  attempts: 0,
  accuracy: 0,
  wrongPool: 0,
})

type PracticeStatsResponse = {
  attempts: number
  accuracy: number
  wrongPool: number
}

async function loadStats() {
  try {
    const s = await api.get<PracticeStatsResponse>('/api/practice/stats')
    stats.attempts = s.attempts
    stats.accuracy = s.accuracy
    stats.wrongPool = s.wrongPool
  } catch (e: any) {
    // 这里你可以选择静默失败，或显示提示
    // meErr.value = e?.message || '加载统计失败'
  }
}

async function loadMe() {
  meErr.value = ''
  try {
    const data = await api.get<MeResponse>('/api/auth/me')
    me.value = data

    // 同步到 store（避免旧页面还依赖 name/userId）
    userId.value = data.userId
    name.value = data.name
  } catch (e: any) {
    // 未登录就跳回登录页
    const msg = e?.message || '加载个人信息失败'
    meErr.value = msg
    if (String(msg).includes('401')) {
      await router.replace({ path: '/login', query: { redirect: '/profile' } })
    }
  }
}

async function loadMyClasses() {
  classErr.value = ''
  classLoading.value = true
  try {
    myClasses.value = await api.get<MyClassResponse[]>('/api/classes/mine')
  } catch (e: any) {
    classErr.value = e?.message || '加载班级失败'
  } finally {
    classLoading.value = false
  }
}

onMounted(async () => {
  await loadMe()
  await loadStats()     // ✅ 新增：动态统计
  if (isStudent.value) {
    await loadMyClasses()
  }
})

function goPractice(tab: 'chapter' | 'recommended' = 'chapter', kpId?: string) {
  const q: any = { tab }
  if (kpId) q.kpId = kpId
  router.push({ path: '/practice', query: q })
}
function goVerilog() {
  router.push('/verilog')
}
</script>

<style scoped>
/* ─── Layout ─── */
.page {
  display: flex;
  flex-direction: column;
  gap: 14px;
  font-size: 14px;
}

.body-grid {
  display: grid;
  grid-template-columns: 1.4fr 1fr;
  gap: 14px;
  align-items: start;
}
.col {
  display: flex;
  flex-direction: column;
  gap: 14px;
}
@media (max-width: 900px) {
  .body-grid {
    grid-template-columns: 1fr;
  }
}

/* ─── Card ─── */
.card {
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 16px;
  padding: 20px;
  position: relative;
}
.hero {
  overflow: hidden;
}

/* ─── Hero Glow ─── */
.hero-glow {
  position: absolute;
  top: -50px;
  right: -50px;
  width: 220px;
  height: 220px;
  background: radial-gradient(circle, rgba(100, 108, 255, 0.16) 0%, transparent 68%);
  pointer-events: none;
}

/* ─── Hero Top ─── */
.hero-top {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 16px;
  flex-wrap: wrap;
}
.hero-ident {
  display: flex;
  align-items: center;
  gap: 14px;
}
.avatar {
  width: 52px;
  height: 52px;
  border-radius: 16px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 20px;
  font-weight: 900;
  background: rgba(100, 108, 255, 0.22);
  border: 2px solid rgba(100, 108, 255, 0.38);
  color: #c5c8ff;
  flex-shrink: 0;
}
.hero-greeting {
  font-size: 19px;
  font-weight: 800;
}
.hero-actions {
  display: flex;
  gap: 10px;
  flex-wrap: wrap;
}

.hero-chips {
  margin-top: 8px;
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
}
.chip {
  display: inline-block;
  font-size: 11px;
  padding: 3px 9px;
  border-radius: 8px;
  background: rgba(255, 255, 255, 0.06);
  border: 1px solid rgba(255, 255, 255, 0.1);
  opacity: 0.7;
}
.hero-err {
  margin-top: 10px;
  font-size: 12px;
  opacity: 0.7;
  color: rgba(255, 200, 200, 0.95);
}

/* ─── Separator ─── */
.sep {
  height: 1px;
  background: rgba(255, 255, 255, 0.07);
  margin: 18px 0;
}

/* ─── Stats ─── */
.stats {
  display: flex;
  align-items: center;
}
.stat {
  flex: 1;
  text-align: center;
  padding: 6px 0;
}
.stat-v {
  font-size: 30px;
  font-weight: 900;
  line-height: 1;
}
.stat-unit {
  font-size: 16px;
  font-weight: 700;
  opacity: 0.65;
}
.stat-k {
  font-size: 12px;
  opacity: 0.5;
  margin-top: 6px;
}
.stat-div {
  width: 1px;
  height: 44px;
  background: rgba(255, 255, 255, 0.09);
  flex-shrink: 0;
}

/* ─── Buttons ─── */
.btn-primary {
  background: rgba(100, 108, 255, 0.18);
  border: 1px solid rgba(100, 108, 255, 0.38);
  color: #b8bcff;
  border-radius: 10px;
  padding: 9px 16px;
  font-size: 13px;
  font-weight: 600;
  cursor: pointer;
  transition: background 0.15s;
}
.btn-primary:hover {
  background: rgba(100, 108, 255, 0.28);
}
.btn-primary.btn-sm {
  padding: 6px 12px;
  font-size: 12px;
  border-radius: 8px;
}

.btn-ghost {
  background: transparent;
  border: 1px solid rgba(255, 255, 255, 0.12);
  border-radius: 10px;
  padding: 9px 16px;
  font-size: 13px;
  font-weight: 500;
  cursor: pointer;
  opacity: 0.75;
  color: inherit;
  transition: background 0.15s, opacity 0.15s;
}
.btn-ghost:hover {
  background: rgba(255, 255, 255, 0.07);
  opacity: 1;
}

/* ─── Panel Head ─── */
.panel-head {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 14px;
}
.panel-title {
  font-weight: 800;
  font-size: 15px;
}
.cnt-badge {
  font-size: 11px;
  padding: 2px 9px;
  border-radius: 999px;
  background: rgba(100, 108, 255, 0.16);
  border: 1px solid rgba(100, 108, 255, 0.28);
  color: #b8bcff;
  font-weight: 700;
}

/* ─── Continue Learning ─── */
.learn-list {
  display: flex;
  flex-direction: column;
  gap: 10px;
}
.learn-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 14px;
  border-radius: 13px;
  border: 1px solid rgba(255, 255, 255, 0.08);
  border-left: 3px solid rgba(100, 108, 255, 0.45);
  background: rgba(255, 255, 255, 0.03);
  transition: background 0.15s;
}
.learn-item:hover {
  background: rgba(255, 255, 255, 0.055);
}
.learn-item__left {
  display: flex;
  align-items: flex-start;
  gap: 10px;
  flex: 1;
  min-width: 0;
}
.kp-chip {
  display: inline-block;
  font-size: 10px;
  padding: 3px 8px;
  border-radius: 6px;
  background: rgba(100, 108, 255, 0.14);
  border: 1px solid rgba(100, 108, 255, 0.28);
  color: #a8aeff;
  font-weight: 700;
  white-space: nowrap;
  flex-shrink: 0;
  margin-top: 2px;
}
.learn-title {
  font-weight: 700;
  font-size: 14px;
}
.learn-sub {
  font-size: 12px;
  opacity: 0.55;
  margin-top: 3px;
}

/* ─── Student Class ─── */
.class-list {
  display: flex;
  flex-direction: column;
  gap: 10px;
}
.class-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 14px;
  border-radius: 13px;
  border: 1px solid rgba(255, 255, 255, 0.08);
  background: rgba(255, 255, 255, 0.03);
}
.class-left {
  flex: 1;
  min-width: 0;
}
.class-name {
  font-weight: 800;
  font-size: 14px;
}
.class-sub {
  font-size: 12px;
  opacity: 0.55;
  margin-top: 4px;
  word-break: break-all;
}
.status-badge {
  font-size: 11px;
  padding: 4px 10px;
  border-radius: 999px;
  border: 1px solid rgba(255, 255, 255, 0.12);
  opacity: 0.85;
  flex-shrink: 0;
}
.status-badge.ok {
  background: rgba(80, 200, 120, 0.12);
  border-color: rgba(80, 200, 120, 0.28);
  color: rgba(200, 255, 220, 0.95);
}
.hint {
  margin-top: 12px;
  font-size: 12px;
  opacity: 0.6;
}
.muted {
  font-size: 13px;
  opacity: 0.6;
}
.warn {
  font-size: 13px;
  color: rgba(255, 200, 200, 0.95);
  opacity: 0.9;
}

/* ─── Tools ─── */
.tool-item {
  display: flex;
  align-items: center;
  gap: 14px;
  padding: 16px;
  border-radius: 13px;
  border: 1px solid rgba(255, 255, 255, 0.08);
  background: rgba(255, 255, 255, 0.03);
  width: 100%;
  text-align: left;
  cursor: pointer;
  color: inherit;
  transition: background 0.15s, border-color 0.15s;
}
.tool-item:hover {
  background: rgba(255, 255, 255, 0.06);
  border-color: rgba(255, 255, 255, 0.14);
}
.tool-ico {
  font-size: 22px;
  flex-shrink: 0;
}
.tool-body {
  flex: 1;
  min-width: 0;
}
.tool-title {
  font-weight: 700;
  font-size: 14px;
}
.tool-sub {
  font-size: 12px;
  opacity: 0.55;
  margin-top: 3px;
}
.tool-arrow {
  font-size: 16px;
  opacity: 0.4;
  flex-shrink: 0;
  transition: transform 0.15s;
}
.tool-item:hover .tool-arrow {
  transform: translateX(3px);
  opacity: 0.65;
}

/* ─── Utilities ─── */
.mono {
  font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, 'Liberation Mono',
    'Courier New', monospace;
}
</style>