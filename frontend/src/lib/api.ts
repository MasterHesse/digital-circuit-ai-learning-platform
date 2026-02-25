// src/lib/api.ts
import { userId } from '../stores/session'

type HttpMethod = 'GET' | 'POST' | 'PUT' | 'DELETE'

export class ApiError extends Error {
  status: number
  statusText: string
  url: string
  method: HttpMethod
  rawBody: string

  constructor(opts: {
    status: number
    statusText: string
    url: string
    method: HttpMethod
    message: string
    rawBody: string
  }) {
    super(opts.message)
    this.name = 'ApiError'
    this.status = opts.status
    this.statusText = opts.statusText
    this.url = opts.url
    this.method = opts.method
    this.rawBody = opts.rawBody
  }
}

let xsrfInFlight: Promise<void> | null = null
async function ensureXsrfCookie() {
  if (getCookie('XSRF-TOKEN')) return
  if (!xsrfInFlight) {
    xsrfInFlight = fetch('/api/auth/csrf', { credentials: 'include' })
      .then(() => undefined)
      .finally(() => {
        xsrfInFlight = null
      })
  }
  await xsrfInFlight
}

function getCookie(name: string): string | null {
  const parts = document.cookie.split(';').map((p) => p.trim())
  for (const p of parts) {
    if (!p) continue
    const idx = p.indexOf('=')
    if (idx < 0) continue
    const k = p.slice(0, idx)
    const v = p.slice(idx + 1)
    if (k === name) {
      try {
        return decodeURIComponent(v)
      } catch {
        return v
      }
    }
  }
  return null
}

function isSafeMethod(method: HttpMethod) {
  return method === 'GET'
}

function pickMessageFromJson(obj: any): string | null {
  if (!obj || typeof obj !== 'object') return null
  const candidates = [obj.message, obj.detail, obj.title, obj.error, obj.error_description]
  for (const c of candidates) {
    if (typeof c === 'string' && c.trim()) return c.trim()
  }
  if (Array.isArray(obj.errors) && obj.errors.length) {
    const m = obj.errors
      .map((e: any) => e?.defaultMessage || e?.message)
      .filter(Boolean)
      .join('；')
    if (m) return m
  }
  return null
}

async function request<T>(method: HttpMethod, url: string, body?: any): Promise<T> {
  const headers: Record<string, string> = {
    Accept: 'application/json',
  }
  if (body != null) headers['Content-Type'] = 'application/json'

  // CSRF：CookieCsrfTokenRepository（XSRF-TOKEN -> X-XSRF-TOKEN）
  if (!isSafeMethod(method)) {
    if (!getCookie('XSRF-TOKEN')) await ensureXsrfCookie()
    const xsrf = getCookie('XSRF-TOKEN')
    if (xsrf) headers['X-XSRF-TOKEN'] = xsrf
  }

  // 过渡期：如果你后端还依赖 X-User-Id，就先保留
  if (userId.value) headers['X-User-Id'] = userId.value

  const res = await fetch(url, {
    method,
    headers,
    body: body == null ? undefined : JSON.stringify(body),
    credentials: 'include',
  })

  if (!res.ok) {
    const raw = await res.text().catch(() => '')
    const ct = (res.headers.get('content-type') || '').toLowerCase()

    let msg = raw.trim()
    if (ct.includes('application/json') && raw) {
      try {
        const j = JSON.parse(raw)
        msg = (pickMessageFromJson(j) || raw).trim()
      } catch {
        // ignore
      }
    }

    if (!msg) msg = `${res.status} ${res.statusText}`.trim()

    throw new ApiError({
      status: res.status,
      statusText: res.statusText,
      url,
      method,
      message: msg, // ✅ 这里直接是后端文案：密码错误 / 审核中 / 用户不存在...
      rawBody: raw,
    })
  }

  if (res.status === 204) return undefined as T

  const contentType = res.headers.get('content-type') || ''
  if (!contentType.includes('application/json')) return undefined as T
  return (await res.json()) as T
}

export const api = {
  get: <T>(url: string) => request<T>('GET', url),
  post: <T>(url: string, body?: any) => request<T>('POST', url, body),
  put: <T>(url: string, body?: any) => request<T>('PUT', url, body),
  del: <T>(url: string) => request<T>('DELETE', url),
}