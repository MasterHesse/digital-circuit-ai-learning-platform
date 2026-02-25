<template>
  <div class="wrap">
    <header class="head">
      <h1 class="title">Teacher 申请收件箱</h1>
      <p class="sub">仅 ADMIN：审批成为 TEACHER 的申请</p>
    </header>

    <div v-if="!isAdmin" class="card error">
      你没有权限访问该页面（需要 ADMIN）。
    </div>

    <div v-else class="card">
      <div class="toolbar">
        <button class="btn" :disabled="loading" @click="loadPending">
          {{ loading ? '加载中…' : '刷新' }}
        </button>
        <span class="count">Pending: {{ items.length }}</span>
      </div>

      <div v-if="err" class="alert error">{{ err }}</div>
      <div v-if="ok" class="alert ok">{{ ok }}</div>

      <div class="table">
        <div class="tr th">
          <div class="td id">User ID</div>
          <div class="td name">Name</div>
          <div class="td time">Requested At</div>
          <div class="td act">Action</div>
        </div>

        <div v-if="items.length === 0" class="empty">暂无待审批申请</div>

        <div v-for="x in items" :key="x.userId" class="tr">
          <div class="td id mono">{{ x.userId }}</div>
          <div class="td name">{{ x.name }}</div>
          <div class="td time mono">{{ fmt(x.requestedAt) }}</div>
          <div class="td act">
            <button class="btn danger" :disabled="busyId === x.userId" @click="approve(x.userId)">
              {{ busyId === x.userId ? '处理中…' : 'Approve' }}
            </button>
            <button class="btn" :disabled="busyId === x.userId" @click="reject(x.userId)">
              Reject
            </button>
          </div>
        </div>
      </div>

      <div class="hint">
        Approve 会把该用户从 STUDENT 升级为 TEACHER，同时将申请标记为 APPROVED。
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { api } from '../lib/api'
import { me } from '../stores/session'

type TeacherRequestStatus = 'PENDING' | 'APPROVED' | 'REJECTED'
type TeacherRequest = {
  userId: string
  name: string
  status: TeacherRequestStatus
  requestedAt: string
}

const loading = ref(false)
const err = ref('')
const ok = ref('')
const items = ref<TeacherRequest[]>([])
const busyId = ref('')

const isAdmin = computed(() => {
  const r = me.value?.role
  return r === 'ADMIN' || r === 'ROLE_ADMIN'
})

function fmt(iso: string) {
  try {
    return new Date(iso).toLocaleString()
  } catch {
    return iso
  }
}

async function loadPending() {
  err.value = ''
  ok.value = ''
  loading.value = true
  try {
    items.value = await api.get<TeacherRequest[]>('/api/users/teacher-requests')
  } catch (e: any) {
    err.value = e?.message || '加载失败'
  } finally {
    loading.value = false
  }
}

async function approve(userId: string) {
  err.value = ''
  ok.value = ''
  busyId.value = userId
  try {
    await api.post<void>(`/api/users/teacher-requests/${encodeURIComponent(userId)}/approve`)
    ok.value = `已通过：${userId}`
    await loadPending()
  } catch (e: any) {
    err.value = e?.message || '通过失败'
  } finally {
    busyId.value = ''
  }
}

async function reject(userId: string) {
  err.value = ''
  ok.value = ''
  busyId.value = userId
  try {
    await api.post<void>(`/api/users/teacher-requests/${encodeURIComponent(userId)}/reject`)
    ok.value = `已拒绝：${userId}`
    await loadPending()
  } catch (e: any) {
    err.value = e?.message || '拒绝失败'
  } finally {
    busyId.value = ''
  }
}

onMounted(() => {
  if (isAdmin.value) loadPending()
})
</script>

<style scoped>
.wrap { max-width: 1100px; margin: 0 auto; padding: 16px; }
.head { margin: 10px 0 16px; }
.title { margin: 0; font-size: 22px; font-weight: 900; }
.sub { margin: 6px 0 0; opacity: 0.65; font-size: 13px; }

.card {
  border: 1px solid rgba(255,255,255,0.12);
  background: rgba(255,255,255,0.04);
  border-radius: 16px;
  padding: 16px;
}
.toolbar { display: flex; gap: 12px; align-items: center; margin-bottom: 12px; }
.count { opacity: 0.7; font-size: 12px; }

.btn {
  border-radius: 12px;
  border: 1px solid rgba(255,255,255,0.14);
  background: rgba(255,255,255,0.06);
  color: inherit;
  padding: 10px 12px;
  cursor: pointer;
}
.btn:disabled { opacity: 0.5; cursor: not-allowed; }
.btn.danger {
  border-color: rgba(255, 80, 80, 0.35);
  background: rgba(255, 80, 80, 0.12);
}

.alert { margin: 10px 0; padding: 10px 12px; border-radius: 12px; font-size: 13px; }
.alert.error { border: 1px solid rgba(255, 80, 80, 0.25); background: rgba(255, 80, 80, 0.08); }
.alert.ok { border: 1px solid rgba(80, 255, 160, 0.20); background: rgba(80, 255, 160, 0.06); }

.table { margin-top: 10px; border-top: 1px solid rgba(255,255,255,0.10); }
.tr {
  display: grid;
  grid-template-columns: 2.0fr 1.0fr 1.2fr 1.2fr;
  gap: 10px;
  padding: 10px 0;
  border-bottom: 1px solid rgba(255,255,255,0.08);
  align-items: center;
}
.th { opacity: 0.75; font-size: 12px; font-weight: 800; }
.td { overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.mono { font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, "Liberation Mono", "Courier New", monospace; }
.empty { padding: 14px 0; opacity: 0.6; }
.hint { margin-top: 12px; opacity: 0.6; font-size: 12px; line-height: 1.4; }
.error { color: rgba(255, 220, 220, 0.95); }
</style>