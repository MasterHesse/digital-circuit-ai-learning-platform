// src/stores/session.ts
import { computed, ref } from 'vue'

/**
 * 说明：
 * - 现在：后端用 X-User-Id 识别用户，所以 userId 必须有
 * - 以后：接入登录后，你可以在 accessToken 里存 JWT（或用 Cookie），页面代码不需要改
 */

const KEY = 'diglearn.session.v1'

type PersistedSession = {
  userId?: string
  name?: string
  accessToken?: string | null
}

function safeRead(): PersistedSession {
  try {
    const raw = localStorage.getItem(KEY)
    if (!raw) return {}
    const obj = JSON.parse(raw)
    if (obj && typeof obj === 'object') return obj as PersistedSession
    return {}
  } catch {
    return {}
  }
}

function write(p: PersistedSession) {
  localStorage.setItem(KEY, JSON.stringify(p))
}

const initial = safeRead()

// 仍然保留 userId 这个导出：保证你现有所有页面/后续代码不需要重写
export const userId = ref<string>(initial.userId || '')

// 可选：显示用（现在你只有 Name 表字段时也能用）
export const name = ref<string>(initial.name || '')

// 未来接入登录（JWT）用；现在可以一直是 null
export const accessToken = ref<string | null>(
  typeof initial.accessToken === 'string' ? initial.accessToken : null
)

export const isLoggedIn = computed(() => {
  // 如果你未来用 token 鉴权：return !!accessToken.value
  // 如果你未来用 cookie session：也可以 return true/false 依据 /api/me 是否可用
  return !!userId.value
})

export function setUserId(v: string) {
  const id = (v || '').trim()
  userId.value = id
  write({ userId: userId.value, name: name.value, accessToken: accessToken.value })
}

export function setName(v: string) {
  name.value = (v || '').trim()
  write({ userId: userId.value, name: name.value, accessToken: accessToken.value })
}

/**
 * 登录成功后调用：存 token（JWT）
 * - 若你后端走 Cookie，这个可以不使用
 */
export function setAccessToken(token: string | null) {
  accessToken.value = token && token.trim() ? token.trim() : null
  write({ userId: userId.value, name: name.value, accessToken: accessToken.value })
}

/**
 * 退出登录：清掉本地会话
 */
export function logout() {
  userId.value = ''
  name.value = ''
  accessToken.value = null
  localStorage.removeItem(KEY)
}