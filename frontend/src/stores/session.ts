// src/stores/session.ts
import { computed, ref } from 'vue'
import { api } from '../lib/api'

export type Role = 'STUDENT' | 'TEACHER' | 'ADMIN' | string
export type MeResponse = {
  userId: string
  username: string
  email: string
  name: string
  role: Role
}

export const userId = ref('')
export const name = ref('')
export const me = ref<MeResponse | null>(null)

const checked = ref(false)
let inFlight: Promise<MeResponse | null> | null = null

export const isLoggedIn = computed(() => !!me.value)

function applyMe(m: MeResponse | null) {
  me.value = m
  userId.value = m?.userId ?? ''
  name.value = m?.name ?? ''
}

async function fetchMe(): Promise<MeResponse | null> {
  const res = await fetch('/api/auth/me', {
    method: 'GET',
    credentials: 'include',
    headers: { Accept: 'application/json' },
  })

  if (res.status === 401) return null
  if (!res.ok) {
    const text = await res.text().catch(() => '')
    throw new Error(`${res.status} ${res.statusText}${text ? `: ${text}` : ''}`)
  }

  return (await res.json()) as MeResponse
}

export async function refreshMe() {
  try {
    const data = await fetchMe()
    applyMe(data)
    return data
  } catch {
    applyMe(null)
    return null
  } finally {
    checked.value = true
  }
}

export async function ensureMe() {
  if (checked.value) return me.value
  if (inFlight) return inFlight
  inFlight = refreshMe().finally(() => (inFlight = null))
  return inFlight
}

export function setMe(m: MeResponse) {
  checked.value = true
  applyMe(m)
}

export async function logout() {
  try {
    await api.post<void>('/api/auth/logout')
  } finally {
    checked.value = true
    applyMe(null)
  }
}