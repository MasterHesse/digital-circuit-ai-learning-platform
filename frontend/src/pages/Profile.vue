<template>
  <section class="page">

    <!-- ─── Hero ─── -->
    <div class="card hero">
      <div class="hero-glow" />

      <div class="hero-top">
        <div class="hero-ident">
          <div class="avatar">{{ displayInitial }}</div>
          <div class="hero-meta">
            <div class="hero-greeting">你好，{{ profile.displayName }} 👋</div>
            <div class="hero-uid-row">
              <span class="uid-chip mono">UID: {{ profile.userId }}</span>
            </div>
          </div>
        </div>
        <div class="hero-actions">
          <button class="btn-primary" @click="goPractice()">⚡ 开始章节练习</button>
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
          <div class="stat-v">{{ stats.accuracy }}<span class="stat-unit">%</span></div>
          <div class="stat-k">正确率</div>
        </div>
        <div class="stat-div" />
        <div class="stat">
          <div class="stat-v">{{ stats.wrongPool }}</div>
          <div class="stat-k">错题池</div>
        </div>
      </div>
    </div>

    <!-- ─── Body ─── -->
    <div class="body-grid">

      <!-- Continue Learning -->
      <div class="card">
        <div class="panel-head">
          <span class="panel-title">继续学习</span>
          <span class="cnt-badge">2 个章节</span>
        </div>
        <div class="learn-list">
          <div class="learn-item">
            <div class="learn-item__left">
              <span class="kp-chip mono">DC-BOOL-02</span>
              <div>
                <div class="learn-title">布尔代数基本定律</div>
                <div class="learn-sub">建议先做 3~5 题巩固</div>
              </div>
            </div>
            <button class="btn-primary btn-sm" @click="goPractice('chapter', 'DC-BOOL-02')">练这个</button>
          </div>
          <div class="learn-item">
            <div class="learn-item__left">
              <span class="kp-chip mono">DC-BOOL-05</span>
              <div>
                <div class="learn-title">卡诺图化简（2~4 变量）</div>
                <div class="learn-sub">难度 2</div>
              </div>
            </div>
            <button class="btn-primary btn-sm" @click="goPractice('chapter', 'DC-BOOL-05')">练这个</button>
          </div>
        </div>
      </div>

      <!-- Tools -->
      <div class="card">
        <div class="panel-head">
          <span class="panel-title">工具箱</span>
        </div>
        <button class="tool-item" @click="goVerilog()">
          <div class="tool-ico">⌨️</div>
          <div class="tool-body">
            <div class="tool-title">Online Verilog Editor</div>
            <div class="tool-sub">做题时可随时打开在线编辑器做验证</div>
          </div>
          <span class="tool-arrow">→</span>
        </button>
      </div>

    </div>
  </section>
</template>

<script setup lang="ts">
import { computed, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { name, userId } from '../stores/session'

const router = useRouter()

const profile = computed(() => ({
  displayName: name.value || 'Student',
  userId: userId.value,
}))

const displayInitial = computed(() =>
  (name.value || 'S').charAt(0).toUpperCase()
)

const stats = reactive({
  attempts: 0,
  accuracy: 0,
  wrongPool: 0,
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
@media (max-width: 900px) {
  .body-grid { grid-template-columns: 1fr; }
}

/* ─── Card ─── */
.card {
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 16px;
  padding: 20px;
  position: relative;
}
.hero { overflow: hidden; }

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
.hero-greeting { font-size: 19px; font-weight: 800; }
.hero-uid-row { margin-top: 5px; }
.uid-chip {
  display: inline-block;
  font-size: 11px;
  padding: 3px 9px;
  border-radius: 6px;
  background: rgba(255, 255, 255, 0.06);
  border: 1px solid rgba(255, 255, 255, 0.1);
  opacity: 0.65;
}
.hero-actions {
  display: flex;
  gap: 10px;
  flex-wrap: wrap;
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
.btn-primary:hover { background: rgba(100, 108, 255, 0.28); }
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
.btn-ghost:hover { background: rgba(255, 255, 255, 0.07); opacity: 1; }

/* ─── Panel Head ─── */
.panel-head {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 14px;
}
.panel-title { font-weight: 800; font-size: 15px; }
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
.learn-item:hover { background: rgba(255, 255, 255, 0.055); }
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
.learn-title { font-weight: 700; font-size: 14px; }
.learn-sub   { font-size: 12px; opacity: 0.55; margin-top: 3px; }

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
.tool-ico   { font-size: 22px; flex-shrink: 0; }
.tool-body  { flex: 1; min-width: 0; }
.tool-title { font-weight: 700; font-size: 14px; }
.tool-sub   { font-size: 12px; opacity: 0.55; margin-top: 3px; }
.tool-arrow { font-size: 16px; opacity: 0.4; flex-shrink: 0; transition: transform 0.15s; }
.tool-item:hover .tool-arrow { transform: translateX(3px); opacity: 0.65; }

/* ─── Utilities ─── */
.mono { font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, "Liberation Mono", "Courier New", monospace; }
</style>