<template>
  <div class="login-wrap">
    <div class="login-card">
      <div class="brand">
        <div class="brand-ico">⚡</div>
        <div>
          <div class="brand-name">数字电路 AI 学习平台</div>
          <div class="brand-eng">Digital Circuit Learning</div>
        </div>
      </div>

      <div class="sep" />

      <h2 class="login-h">创建账号</h2>
      <p class="login-p">
        {{ isTeacher ? '提交教师身份申请，管理员审核通过后才能登录' : '注册后将自动登录并进入个人主页' }}
      </p>

      <div v-if="err" class="err">{{ err }}</div>
      <div v-if="ok" class="ok">{{ ok }}</div>

      <div class="field">
        <label class="field-label">身份（role）</label>
        <div class="role-row">
          <label class="role-pill" :class="{ active: desiredRole === 'STUDENT' }">
            <input type="radio" value="STUDENT" v-model="desiredRole" />
            <span>STUDENT 学生</span>
          </label>
          <label class="role-pill" :class="{ active: desiredRole === 'TEACHER' }">
            <input type="radio" value="TEACHER" v-model="desiredRole" />
            <span>TEACHER 教师（需审核）</span>
          </label>
        </div>
        <div v-if="isTeacher" class="hint">
          选择教师后：账号将处于“待审核”状态，审核通过前无法登录。
        </div>
      </div>

      <div class="field">
        <label class="field-label">用户名（username）</label>
        <input v-model="username" class="field-input" placeholder="例如：alice（不需要 @）" autocomplete="username" />
      </div>

      <div class="field">
        <label class="field-label">邮箱（email）</label>
        <input v-model="email" class="field-input" placeholder="例如：alice@example.com" autocomplete="email" />
      </div>

      <div class="field">
        <label class="field-label">姓名（name）</label>
        <input v-model="displayName" class="field-input" placeholder="例如：Alice" autocomplete="name" />
      </div>

      <div class="field">
        <label class="field-label">密码</label>
        <input
          v-model="password"
          class="field-input"
          type="password"
          placeholder="请输入密码…"
          autocomplete="new-password"
        />
      </div>

      <div class="field">
        <label class="field-label">确认密码</label>
        <input
          v-model="password2"
          class="field-input"
          type="password"
          placeholder="再输入一次密码…"
          autocomplete="new-password"
          @keyup.enter="doRegister"
        />
      </div>

      <button class="btn-submit" :disabled="disabled" @click="doRegister">
        {{ loading ? '处理中…' : (isTeacher ? '提交申请 →' : '注册并登录 →') }}
      </button>

      <div class="sub-actions">
        <button class="link" type="button" @click="goLogin">已有账号？去登录</button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { api } from '../lib/api'
import { setMe } from '../stores/session'

type MeResponse = {
  userId: string
  username: string
  email: string
  name: string
  role: 'STUDENT' | 'TEACHER' | 'ADMIN' | string
}

const router = useRouter()
const route = useRoute()

const desiredRole = ref<'STUDENT' | 'TEACHER'>('STUDENT')
const isTeacher = computed(() => desiredRole.value === 'TEACHER')

const username = ref('')
const email = ref('')
const displayName = ref('')
const password = ref('')
const password2 = ref('')

const loading = ref(false)
const err = ref('')
const ok = ref('')

const disabled = computed(() => {
  if (loading.value) return true
  if (!username.value.trim()) return true
  if (!email.value.trim()) return true
  if (!displayName.value.trim()) return true
  if (!password.value) return true
  if (password.value !== password2.value) return true
  return false
})

function normalizeUsername(v: string) {
  return v.trim().replace(/^@+/, '').toLowerCase()
}
function normalizeEmail(v: string) {
  return v.trim().toLowerCase()
}

async function warmupCsrfCookie() {
  try {
    await fetch('/actuator/health', { credentials: 'include' })
  } catch {
    // ignore
  }
}

onMounted(() => {
  warmupCsrfCookie()
})

async function doRegister() {
  err.value = ''
  ok.value = ''

  const u = normalizeUsername(username.value)
  const e = normalizeEmail(email.value)
  const n = displayName.value.trim()
  const p = password.value

  if (!u || !e || !n || !p) return
  if (p !== password2.value) {
    err.value = '两次输入的密码不一致'
    return
  }

  loading.value = true
  try {
    await warmupCsrfCookie()

    await api.post<void>('/api/auth/register', {
      username: u,
      email: e,
      name: n,
      password: p,
      desiredRole: desiredRole.value, // ✅ 新增
    })

    // ✅ TEACHER：不自动登录，直接提示并跳登录页
    if (isTeacher.value) {
      ok.value = '教师申请已提交，请等待管理员审核通过后再登录。'
      await router.replace({ path: '/login', query: { redirect: route.query.redirect, pending: '1' } })
      return
    }

    // ✅ STUDENT：注册后自动登录
    const me = await api.post<MeResponse>('/api/auth/login', {
      login: u,
      password: p,
      rememberMe: true,
    })
    setMe(me)

    const redirect = (route.query.redirect as string) || '/profile'
    await router.replace(redirect)
  } catch (e: any) {
    err.value = e?.message || '注册失败'
  } finally {
    loading.value = false
  }
}

function goLogin() {
  router.push({ path: '/login', query: { redirect: route.query.redirect } })
}
</script>

<style scoped>
/* 基本样式保持你的原样，新增 role / ok 样式 */
.login-wrap { min-height: 100vh; display: flex; align-items: center; justify-content: center; padding: 24px; }
.login-card { width: 100%; max-width: 460px; background: rgba(255, 255, 255, 0.05); border: 1px solid rgba(255, 255, 255, 0.1); border-radius: 20px; padding: 32px 28px; }
.brand { display: flex; align-items: center; gap: 13px; margin-bottom: 22px; }
.brand-ico { width: 48px; height: 48px; display: flex; align-items: center; justify-content: center; font-size: 24px; background: rgba(100, 108, 255, 0.18); border: 1px solid rgba(100, 108, 255, 0.35); border-radius: 14px; flex-shrink: 0; }
.brand-name { font-size: 14px; font-weight: 800; }
.brand-eng { font-size: 11px; opacity: 0.5; margin-top: 3px; letter-spacing: 0.03em; }
.sep { height: 1px; background: rgba(255, 255, 255, 0.07); margin-bottom: 22px; }
.login-h { margin: 0 0 6px; font-size: 21px; font-weight: 800; }
.login-p { margin: 0 0 22px; font-size: 13px; opacity: 0.55; }
.err { margin: 0 0 14px; padding: 10px 12px; border-radius: 12px; background: rgba(255, 80, 80, 0.08); border: 1px solid rgba(255, 80, 80, 0.18); color: rgba(255, 200, 200, 0.95); font-size: 13px; }
.ok { margin: 0 0 14px; padding: 10px 12px; border-radius: 12px; background: rgba(80, 255, 160, 0.06); border: 1px solid rgba(80, 255, 160, 0.18); color: rgba(200, 255, 230, 0.95); font-size: 13px; }

.field { margin-bottom: 14px; }
.field-label { display: block; font-size: 11px; font-weight: 700; opacity: 0.6; margin-bottom: 7px; letter-spacing: 0.07em; text-transform: uppercase; }
.field-input { width: 100%; box-sizing: border-box; background: rgba(0, 0, 0, 0.15); border: 1.5px solid rgba(255, 255, 255, 0.1); border-radius: 12px; padding: 12px 14px; color: inherit; font-size: 14px; outline: none; transition: border-color 0.15s, background 0.15s; }
.field-input:focus { border-color: rgba(100, 108, 255, 0.55); background: rgba(100, 108, 255, 0.04); }
.field-input::placeholder { opacity: 0.35; }

.role-row { display: flex; gap: 10px; flex-wrap: wrap; }
.role-pill { display: inline-flex; align-items: center; gap: 8px; padding: 10px 12px; border-radius: 12px; border: 1px solid rgba(255,255,255,0.12); background: rgba(255,255,255,0.04); cursor: pointer; user-select: none; }
.role-pill input { width: 16px; height: 16px; }
.role-pill.active { border-color: rgba(100, 108, 255, 0.55); background: rgba(100, 108, 255, 0.08); }
.hint { margin-top: 10px; font-size: 12px; opacity: 0.65; line-height: 1.4; }

.btn-submit { width: 100%; background: rgba(100, 108, 255, 0.22); border: 1.5px solid rgba(100, 108, 255, 0.45); color: #c5c8ff; border-radius: 12px; padding: 13px; font-size: 15px; font-weight: 700; cursor: pointer; letter-spacing: 0.02em; transition: background 0.15s, transform 0.1s, box-shadow 0.15s; }
.btn-submit:hover:not(:disabled) { background: rgba(100, 108, 255, 0.35); transform: translateY(-1px); box-shadow: 0 4px 20px rgba(100, 108, 255, 0.18); }
.btn-submit:disabled { opacity: 0.28; cursor: not-allowed; }

.sub-actions { margin-top: 14px; text-align: center; opacity: 0.8; }
.link { background: transparent; border: none; color: inherit; cursor: pointer; font-size: 13px; text-decoration: underline; opacity: 0.75; }
.link:hover { opacity: 1; }
</style>