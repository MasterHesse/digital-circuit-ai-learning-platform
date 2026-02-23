// src/lib/api.ts
import { accessToken, userId } from '../stores/session'

type HttpMethod = 'GET' | 'POST' | 'PUT' | 'DELETE'

function buildErrorMessage(status: number, statusText: string, text: string) {
  const msg = `${status} ${statusText}`.trim()
  return text ? `${msg}: ${text}` : msg
}

async function request<T>(method: HttpMethod, url: string, body?: any): Promise<T> {
  const headers: Record<string, string> = {
    Accept: 'application/json',
  }

  // 只有在有 body 时才设置 Content-Type（更通用，也避免某些后端对 GET 带 content-type 的怪行为）
  if (body != null) headers['Content-Type'] = 'application/json'

  // 现在：后端大量接口 require X-User-Id，所以这里统一带上
  // 以后：如果改成从 token/cookie 识别用户，这个 header 可以逐步移除（页面不需要动）
  if (userId.value) headers['X-User-Id'] = userId.value

  // 未来：JWT 鉴权（如果你用 Cookie session，则不需要这个 header）
  if (accessToken.value) headers['Authorization'] = `Bearer ${accessToken.value}`

  const res = await fetch(url, {
    method,
    headers,
    body: body == null ? undefined : JSON.stringify(body),
    // 重要：为未来 cookie-session 登录做准备（同域默认也可不写，但写上更明确）
    credentials: 'include',
  })

  // 错误处理：尽量把后端返回文本带出来（你后端常返回 ResponseStatusException 的 message）
  if (!res.ok) {
    const text = await res.text().catch(() => '')
    throw new Error(buildErrorMessage(res.status, res.statusText, text))
  }

  // 204 No Content
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