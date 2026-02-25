<template>
  <div class="login-wrap">
    <div class="login-card">
      <!-- Brand -->
      <div class="brand">
        <div class="brand-ico">⚡</div>
        <div>
          <div class="brand-name">数字电路 AI 学习平台</div>
          <div class="brand-eng">Digital Circuit Learning</div>
        </div>
      </div>

      <div class="sep" />

      <h2 class="login-h">欢迎回来</h2>
      <p class="login-p">使用用户名/邮箱 + 密码登录</p>

      <div v-if="info" class="info">{{ info }}</div>
      <div v-if="err" class="err">{{ err }}</div>

      <div class="field">
        <label class="field-label">用户名或邮箱</label>
        <input
          v-model="loginId"
          class="field-input"
          placeholder="username 或 email…"
          autocomplete="username"
          @keyup.enter="doLogin"
        />
      </div>

      <div class="field">
        <label class="field-label">密码</label>
        <input
          v-model="password"
          class="field-input"
          type="password"
          placeholder="请输入密码…"
          autocomplete="current-password"
          @keyup.enter="doLogin"
        />
      </div>

      <label class="remember">
        <input type="checkbox" v-model="rememberMe" />
        <span>记住我（30 天）</span>
      </label>

      <button class="btn-submit" :disabled="disabled" @click="doLogin">
        {{ loading ? '登录中…' : '进入学习 →' }}
      </button>

      <div class="sub-actions">
        <button class="link" type="button" @click="goRegister">
          没有账号？去注册
        </button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { setMe } from '../stores/session'
import { computed, onMounted, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { api, ApiError } from '../lib/api'

type MeResponse = {
  userId: string
  username: string
  email: string
  name: string
  role: 'STUDENT' | 'TEACHER' | 'ADMIN' | string
}

const router = useRouter()
const route = useRoute()

const loginId = ref('')
const password = ref('')
const rememberMe = ref(true)

const loading = ref(false)
const err = ref('')
const info = ref('')

const disabled = computed(() => loading.value || !loginId.value.trim() || !password.value)

async function warmupCsrfCookie() {
  try {
    await fetch('/actuator/health', { credentials: 'include' })
  } catch {
    // ignore
  }
}

onMounted(() => {
  warmupCsrfCookie()

  // 可选：从注册页跳转过来 ?pending=1 时先提示一次
  if (route.query.pending === '1') {
    info.value = '教师申请已提交，审核通过后才能登录。'
  }
})

async function doLogin() {
  err.value = ''
  info.value = ''

  const login = loginId.value.trim()
  const pwd = password.value
  if (!login || !pwd) return

  loading.value = true
  try {
    await warmupCsrfCookie()

    const m = await api.post<MeResponse>('/api/auth/login', {
      login,
      password: pwd,
      rememberMe: rememberMe.value,
    })

    setMe(m)

    const redirect = '/profile'
    await router.replace(redirect)
  } catch (e: any) {
    if (e instanceof ApiError) {
      // ✅ 后端已返回你要的中文文案
      // 401 -> “密码错误” / “用户不存在/审核被驳回”
      // 423 -> “账号仍在审核中...”
      err.value = e.message || '登录失败'
    } else {
      err.value = e?.message || '登录失败'
    }
  } finally {
    loading.value = false
  }
}

function goRegister() {
  router.push({ path: '/register', query: { redirect: route.query.redirect } })
}
</script>

<style scoped>
.login-wrap {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 24px;
}

.login-card {
  width: 100%;
  max-width: 420px;
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 20px;
  padding: 32px 28px;
}

/* ─── Brand ─── */
.brand {
  display: flex;
  align-items: center;
  gap: 13px;
  margin-bottom: 22px;
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
}
.brand-eng {
  font-size: 11px;
  opacity: 0.5;
  margin-top: 3px;
  letter-spacing: 0.03em;
}

.sep {
  height: 1px;
  background: rgba(255, 255, 255, 0.07);
  margin-bottom: 22px;
}

/* ─── Heading ─── */
.login-h {
  margin: 0 0 6px;
  font-size: 21px;
  font-weight: 800;
}
.login-p {
  margin: 0 0 22px;
  font-size: 13px;
  opacity: 0.55;
}

/* ─── Error ─── */
.err {
  margin: 0 0 14px;
  padding: 10px 12px;
  border-radius: 12px;
  background: rgba(255, 80, 80, 0.08);
  border: 1px solid rgba(255, 80, 80, 0.18);
  color: rgba(255, 200, 200, 0.95);
  font-size: 13px;
}

/* ─── Field ─── */
.field {
  margin-bottom: 14px;
}
.field-label {
  display: block;
  font-size: 11px;
  font-weight: 700;
  opacity: 0.6;
  margin-bottom: 7px;
  letter-spacing: 0.07em;
  text-transform: uppercase;
}
.field-input {
  width: 100%;
  box-sizing: border-box;
  background: rgba(0, 0, 0, 0.15);
  border: 1.5px solid rgba(255, 255, 255, 0.1);
  border-radius: 12px;
  padding: 12px 14px;
  color: inherit;
  font-size: 14px;
  outline: none;
  transition: border-color 0.15s, background 0.15s;
}
.field-input:focus {
  border-color: rgba(100, 108, 255, 0.55);
  background: rgba(100, 108, 255, 0.04);
}
.field-input::placeholder {
  opacity: 0.35;
}

/* ─── Remember ─── */
.remember {
  display: flex;
  align-items: center;
  gap: 10px;
  margin: 6px 0 18px;
  opacity: 0.75;
  font-size: 13px;
}
.remember input {
  width: 16px;
  height: 16px;
}

/* ─── Submit ─── */
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
  transition: background 0.15s, transform 0.1s, box-shadow 0.15s;
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

/* ─── Sub actions ─── */
.sub-actions {
  margin-top: 14px;
  text-align: center;
  opacity: 0.8;
}
.link {
  background: transparent;
  border: none;
  color: inherit;
  cursor: pointer;
  font-size: 13px;
  text-decoration: underline;
  opacity: 0.75;
}
.link:hover {
  opacity: 1;
}
.info {
  margin: 0 0 14px;
  padding: 10px 12px;
  border-radius: 12px;
  background: rgba(100, 108, 255, 0.08);
  border: 1px solid rgba(100, 108, 255, 0.18);
  color: rgba(220, 225, 255, 0.95);
  font-size: 13px;
}
</style>