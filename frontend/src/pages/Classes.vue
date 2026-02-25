<template>
  <div class="wrap">
    <h1 class="h">班级</h1>
    <p class="p" v-if="isTeacher">
      你管理的班级（把班级 ID 发给学生，他们可以通过 ID 申请加入）
    </p>
    <p class="p" v-else>
      你加入/申请的班级（可通过班级 ID 申请加入）
    </p>

    <div v-if="err" class="err">{{ err }}</div>
    <div v-if="info" class="info">{{ info }}</div>

    <!-- TEACHER: create -->
    <div v-if="isTeacher" class="card">
      <div class="row">
        <input class="input" v-model="newName" placeholder="新班级名称（最多200字）" />
        <button class="btn" :disabled="loading || !newName.trim()" @click="createClass">
          {{ loading ? '创建中…' : '创建班级' }}
        </button>
      </div>
    </div>

    <!-- STUDENT: join by id -->
    <div v-else class="card">
      <div class="row">
        <input class="input" v-model="joinId" placeholder="输入班级ID（UUID）" />
        <button class="btn" :disabled="loading || !joinId.trim()" @click="applyById">
          {{ loading ? '提交中…' : '申请加入' }}
        </button>
      </div>
      <div class="hint">提示：申请后会进入待审核状态，老师批准后即可加入。</div>
    </div>

    <!-- Lists -->
    <div class="card">
      <div class="list-h">{{ isTeacher ? '我的班级' : '我的班级（含申请）' }}</div>

      <div v-if="loading && items.length === 0" class="muted">加载中…</div>
      <div v-else-if="items.length === 0" class="muted">暂无数据</div>

      <div v-for="it in items" :key="it.key" class="item">
        <div class="item-main">
          <div class="title">{{ it.name }}</div>

          <div class="meta">
            <span class="mono">ID: {{ it.id }}</span>
            <span v-if="it.status" class="tag" :class="`tag--${it.status}`">
              {{ statusLabel(it.status) }}
            </span>
          </div>

          <div class="meta" v-if="it.teacherName">
            教师：{{ it.teacherName }}
          </div>
        </div>

        <div class="actions">
          <button class="btn-ghost" @click="copy(it.id)">复制ID</button>
          <button class="btn-ghost" @click="goDetail(it.id)">详情</button>

          <!-- TEACHER actions -->
          <template v-if="isTeacher">
            <button class="btn-ghost" @click="startEdit(it)">改名</button>
            <button class="btn-danger" @click="delClass(it.id)">删除</button>
          </template>

          <!-- STUDENT actions -->
          <template v-else>
            <button class="btn-danger" v-if="it.status" @click="leave(it.id)">
              {{ it.status === 'PENDING' ? '取消申请' : '退出班级' }}
            </button>
          </template>
        </div>

        <!-- inline rename -->
        <div v-if="isTeacher && editingId === it.id" class="edit">
          <input class="input" v-model="editName" />
          <div class="actions">
            <button class="btn" :disabled="loading || !editName.trim()" @click="saveEdit(it.id)">保存</button>
            <button class="btn-ghost" :disabled="loading" @click="cancelEdit">取消</button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted, ref, watch } from 'vue'
import { useRouter } from 'vue-router'
import { api, ApiError } from '../lib/api'
import { me } from '../stores/session'

type ClassResponse = {
  id: string
  name: string
  teacherId: string
  createdAt: string
}

type MembershipSummary = {
  membershipId: string
  status: 'PENDING' | 'APPROVED' | 'REJECTED' | string
  requestedAt: string
  decidedAt: string | null
}

type UserProfileResponse = {
  userId: string
  username: string
  email: string
  name: string | null
}

type MyClassResponse = {
  classId: string
  name: string
  teacherId: string
  createdAt: string
  teacher: UserProfileResponse | null
  membership: MembershipSummary
}

const router = useRouter()
const role = computed(() => me.value?.role || '')
const isTeacher = computed(() =>
  role.value === 'TEACHER' || role.value === 'ROLE_TEACHER' || role.value === 'ADMIN' || role.value === 'ROLE_ADMIN',
)

const loading = ref(false)
const err = ref('')
const info = ref('')

const newName = ref('')
const joinId = ref('')

const teaching = ref<ClassResponse[]>([])
const joined = ref<MyClassResponse[]>([])

const editingId = ref<string | null>(null)
const editName = ref('')

const items = computed(() => {
  if (isTeacher.value) {
    return teaching.value.map((c) => ({
      key: c.id,
      id: c.id,
      name: c.name,
      status: '',
      teacherName: '',
    }))
  } else {
    return joined.value.map((x) => ({
      key: x.classId,
      id: x.classId,
      name: x.name,
      status: x.membership?.status || '',
      teacherName: x.teacher?.name || x.teacher?.username || '',
    }))
  }
})

function statusLabel(s: string) {
  if (s === 'PENDING') return '待审核'
  if (s === 'APPROVED') return '已加入'
  if (s === 'REJECTED') return '已拒绝'
  return s
}

async function load() {
  err.value = ''
  info.value = ''
  loading.value = true
  try {
    if (isTeacher.value) {
      teaching.value = await api.get<ClassResponse[]>('/api/classes/teaching')
    } else {
      joined.value = await api.get<MyClassResponse[]>('/api/classes/joined')
    }
  } catch (e: any) {
    err.value = e instanceof ApiError ? e.message : e?.message || '加载失败'
  } finally {
    loading.value = false
  }
}

onMounted(load)
watch(isTeacher, () => load())

async function createClass() {
  const name = newName.value.trim()
  if (!name) return
  loading.value = true
  err.value = ''
  info.value = ''
  try {
    await api.post<ClassResponse>('/api/classes', { name })
    newName.value = ''
    info.value = '创建成功'
    await load()
  } catch (e: any) {
    err.value = e instanceof ApiError ? e.message : e?.message || '创建失败'
  } finally {
    loading.value = false
  }
}

async function applyById() {
  const id = joinId.value.trim()
  if (!id) return
  loading.value = true
  err.value = ''
  info.value = ''
  try {
    await api.post(`/api/classes/${id}/apply`)
    joinId.value = ''
    info.value = '已提交申请（等待老师审核）'
    await load()
  } catch (e: any) {
    err.value = e instanceof ApiError ? e.message : e?.message || '提交失败'
  } finally {
    loading.value = false
  }
}

function goDetail(id: string) {
  router.push({ name: 'classDetail', params: { id } })
}

async function copy(text: string) {
  info.value = ''
  err.value = ''
  try {
    await navigator.clipboard.writeText(text)
    info.value = '已复制到剪贴板'
  } catch {
    err.value = '复制失败（浏览器可能不允许）'
  }
}

function startEdit(it: any) {
  editingId.value = it.id
  editName.value = it.name
}
function cancelEdit() {
  editingId.value = null
  editName.value = ''
}

async function saveEdit(id: string) {
  const name = editName.value.trim()
  if (!name) return
  loading.value = true
  err.value = ''
  info.value = ''
  try {
    await api.put(`/api/classes/${id}`, { name })
    editingId.value = null
    info.value = '已保存'
    await load()
  } catch (e: any) {
    err.value = e instanceof ApiError ? e.message : e?.message || '保存失败'
  } finally {
    loading.value = false
  }
}

async function delClass(id: string) {
  if (!confirm('确定删除该班级？（将同时删除该班级的所有加入记录）')) return
  loading.value = true
  err.value = ''
  info.value = ''
  try {
    await api.del<void>(`/api/classes/${id}`)
    info.value = '已删除'
    await load()
  } catch (e: any) {
    err.value = e instanceof ApiError ? e.message : e?.message || '删除失败'
  } finally {
    loading.value = false
  }
}

async function leave(id: string) {
  if (!confirm('确定退出/取消申请？')) return
  loading.value = true
  err.value = ''
  info.value = ''
  try {
    await api.del<void>(`/api/classes/${id}/membership`)
    info.value = '已更新'
    await load()
  } catch (e: any) {
    err.value = e instanceof ApiError ? e.message : e?.message || '操作失败'
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.wrap { max-width: 980px; margin: 0 auto; padding: 20px 16px; }
.h { margin: 0 0 6px; font-size: 22px; font-weight: 800; }
.p { margin: 0 0 14px; opacity: 0.65; font-size: 13px; }

.card {
  background: rgba(255,255,255,0.05);
  border: 1px solid rgba(255,255,255,0.10);
  border-radius: 16px;
  padding: 14px;
  margin: 12px 0;
}
.row { display: flex; gap: 10px; align-items: center; flex-wrap: wrap; }
.input {
  flex: 1;
  min-width: 240px;
  box-sizing: border-box;
  background: rgba(0,0,0,0.15);
  border: 1.5px solid rgba(255,255,255,0.10);
  border-radius: 12px;
  padding: 10px 12px;
  color: inherit;
  outline: none;
}
.btn {
  background: rgba(100,108,255,0.22);
  border: 1.5px solid rgba(100,108,255,0.45);
  color: #c5c8ff;
  border-radius: 12px;
  padding: 10px 12px;
  font-weight: 700;
  cursor: pointer;
}
.btn:disabled { opacity: 0.4; cursor: not-allowed; }

.btn-ghost {
  background: transparent;
  border: 1px solid rgba(255,255,255,0.14);
  border-radius: 12px;
  padding: 8px 10px;
  cursor: pointer;
  opacity: 0.9;
}
.btn-danger {
  background: rgba(255,80,80,0.12);
  border: 1px solid rgba(255,80,80,0.30);
  color: rgba(255,220,220,0.95);
  border-radius: 12px;
  padding: 8px 10px;
  cursor: pointer;
}

.list-h { font-weight: 800; margin-bottom: 8px; }
.item {
  border-top: 1px solid rgba(255,255,255,0.08);
  padding: 12px 0;
}
.item:first-of-type { border-top: none; }
.item-main { display: grid; gap: 6px; }
.title { font-weight: 800; }
.meta { opacity: 0.75; font-size: 12px; display: flex; gap: 10px; flex-wrap: wrap; }
.mono { font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, "Liberation Mono", monospace; }
.actions { display: flex; gap: 8px; flex-wrap: wrap; margin-top: 8px; }
.edit { margin-top: 10px; display: grid; gap: 10px; }
.hint { margin-top: 8px; font-size: 12px; opacity: 0.65; }

.err {
  margin: 8px 0;
  padding: 10px 12px;
  border-radius: 12px;
  background: rgba(255, 80, 80, 0.08);
  border: 1px solid rgba(255, 80, 80, 0.18);
  color: rgba(255, 200, 200, 0.95);
  font-size: 13px;
}
.info {
  margin: 8px 0;
  padding: 10px 12px;
  border-radius: 12px;
  background: rgba(100, 108, 255, 0.08);
  border: 1px solid rgba(100, 108, 255, 0.18);
  color: rgba(220, 225, 255, 0.95);
  font-size: 13px;
}
.muted { opacity: 0.6; padding: 8px 0; font-size: 13px; }

.tag {
  padding: 2px 8px;
  border-radius: 999px;
  border: 1px solid rgba(255,255,255,0.12);
}
.tag--PENDING { border-color: rgba(255,200,100,0.35); background: rgba(255,200,100,0.10); }
.tag--APPROVED { border-color: rgba(120,255,170,0.35); background: rgba(120,255,170,0.10); }
.tag--REJECTED { border-color: rgba(255,80,80,0.35); background: rgba(255,80,80,0.10); }
</style>