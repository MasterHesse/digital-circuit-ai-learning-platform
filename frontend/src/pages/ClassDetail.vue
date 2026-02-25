<template>
  <div class="wrap">
    <button class="back" @click="router.push({ name: 'classes' })">← 返回列表</button>

    <div v-if="err" class="err">{{ err }}</div>

    <div v-if="detail" class="card">
      <div class="top">
        <div>
          <div class="h">{{ detail.clazz.name }}</div>
          <div class="meta">
            <span class="mono">班级ID：{{ detail.clazz.id }}</span>
            <button class="btn-ghost" @click="copy(detail.clazz.id)">复制</button>
          </div>
          <div class="meta" v-if="detail.teacher">
            教师：{{ detail.teacher.name || detail.teacher.username }}
          </div>
        </div>

        <!-- STUDENT actions -->
        <div v-if="!isTeacher" class="actions">
          <div v-if="detail.myMembership" class="tag" :class="`tag--${detail.myMembership.status}`">
            {{ statusLabel(detail.myMembership.status) }}
          </div>

          <button
            v-if="!detail.myMembership"
            class="btn"
            :disabled="loading"
            @click="apply"
          >
            申请加入
          </button>

          <button
            v-else
            class="btn-danger"
            :disabled="loading"
            @click="leave"
          >
            {{ detail.myMembership.status === 'PENDING' ? '取消申请' : '退出班级' }}
          </button>
        </div>
      </div>
    </div>

    <!-- TEACHER panels -->
    <template v-if="detail && isTeacher">
      <div class="card">
        <div class="section-h">加入申请（待审核）</div>
        <div v-if="joinReq.length === 0" class="muted">暂无</div>

        <div v-for="r in joinReq" :key="r.membershipId" class="row2">
          <div>
            <div class="title">{{ r.student.name || r.student.username }}</div>
            <div class="meta">
              <span class="mono">membershipId: {{ r.membershipId }}</span>
              <span class="mono">studentId: {{ r.student.userId }}</span>
            </div>
          </div>
          <div class="actions">
            <button class="btn" :disabled="loading" @click="approve(r.membershipId)">批准</button>
            <button class="btn-danger" :disabled="loading" @click="reject(r.membershipId)">驳回</button>
          </div>
        </div>
      </div>

      <div class="card">
        <div class="section-h">学生列表（已加入）</div>
        <div v-if="students.length === 0" class="muted">暂无</div>

        <div v-for="s in students" :key="s.membershipId" class="row2">
          <div>
            <div class="title">{{ s.student.name || s.student.username }}</div>
            <div class="meta">
              <span class="mono">studentId: {{ s.student.userId }}</span>
              <span class="mono">attempted: {{ s.progress.attemptedCount }}</span>
              <span class="mono">mastered: {{ s.progress.masteredCount }}</span>
              <span class="mono">totalWrong: {{ s.progress.totalWrongCount }}</span>
            </div>
          </div>
          <div class="actions">
            <button class="btn-ghost" @click="goRecommended(s.student.userId)">推荐错题</button>
            <button class="btn-danger" :disabled="loading" @click="kick(s.membershipId, s.student.userId)">
              移出
            </button>
          </div>
        </div>
      </div>
    </template>

    <div v-if="info" class="info">{{ info }}</div>
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted, ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { api, ApiError } from '../lib/api'
import { me } from '../stores/session'

type UserProfileResponse = { userId: string; username: string; email: string; name: string | null }

type ClassResponse = { id: string; name: string; teacherId: string; createdAt: string }

type MembershipSummary = {
  membershipId: string
  status: 'PENDING' | 'APPROVED' | 'REJECTED' | string
  requestedAt: string
  decidedAt: string | null
}

type ClassDetailResponse = {
  clazz: ClassResponse
  teacher: UserProfileResponse | null
  myMembership: MembershipSummary | null
}

type JoinRequestResponse = {
  membershipId: string
  classId: string
  requestedAt: string
  student: UserProfileResponse
}

type ProgressResponse = {
  attemptedCount: number
  masteredCount: number
  unmasteredWrongCount: number
  totalWrongCount: number
  lastAttemptAt: string | null
}

type StudentProgressResponse = {
  membershipId: string
  classId: string
  approvedAt: string
  student: UserProfileResponse
  progress: ProgressResponse
}

const route = useRoute()
const router = useRouter()

const classId = computed(() => String(route.params.id || ''))
const role = computed(() => me.value?.role || '')
const isTeacher = computed(() =>
  role.value === 'TEACHER' || role.value === 'ROLE_TEACHER' || role.value === 'ADMIN' || role.value === 'ROLE_ADMIN',
)

const loading = ref(false)
const err = ref('')
const info = ref('')

const detail = ref<ClassDetailResponse | null>(null)
const joinReq = ref<JoinRequestResponse[]>([])
const students = ref<StudentProgressResponse[]>([])

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
    detail.value = await api.get<ClassDetailResponse>(`/api/classes/${classId.value}`)

    if (isTeacher.value) {
      joinReq.value = await api.get<JoinRequestResponse[]>(`/api/classes/${classId.value}/join-requests`)
      students.value = await api.get<StudentProgressResponse[]>(`/api/classes/${classId.value}/students`)
    } else {
      joinReq.value = []
      students.value = []
    }
  } catch (e: any) {
    err.value = e instanceof ApiError ? e.message : e?.message || '加载失败'
  } finally {
    loading.value = false
  }
}

onMounted(load)
watch(classId, () => load())

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

async function apply() {
  if (!confirm('确认申请加入该班级？')) return
  loading.value = true
  err.value = ''
  info.value = ''
  try {
    await api.post(`/api/classes/${classId.value}/apply`)
    info.value = '已提交申请，等待老师审核'
    await load()
  } catch (e: any) {
    err.value = e instanceof ApiError ? e.message : e?.message || '提交失败'
  } finally {
    loading.value = false
  }
}

async function leave() {
  if (!confirm('确认退出/取消申请？')) return
  loading.value = true
  err.value = ''
  info.value = ''
  try {
    await api.del<void>(`/api/classes/${classId.value}/membership`)
    info.value = '已更新'
    await load()
  } catch (e: any) {
    err.value = e instanceof ApiError ? e.message : e?.message || '操作失败'
  } finally {
    loading.value = false
  }
}

async function approve(membershipId: string) {
  loading.value = true
  err.value = ''
  try {
    await api.post<void>(`/api/classes/${classId.value}/join-requests/${membershipId}/approve`)
    await load()
  } catch (e: any) {
    err.value = e instanceof ApiError ? e.message : e?.message || '批准失败'
  } finally {
    loading.value = false
  }
}

async function reject(membershipId: string) {
  if (!confirm('确认驳回该申请？')) return
  loading.value = true
  err.value = ''
  try {
    await api.post<void>(`/api/classes/${classId.value}/join-requests/${membershipId}/reject`)
    await load()
  } catch (e: any) {
    err.value = e instanceof ApiError ? e.message : e?.message || '驳回失败'
  } finally {
    loading.value = false
  }
}

async function kick(membershipId: string, studentId: string) {
  if (!confirm(`确认将该学生移出班级？\nstudentId: ${studentId}`)) return
  loading.value = true
  err.value = ''
  info.value = ''
  try {
    await api.del<void>(`/api/classes/${classId.value}/memberships/${membershipId}`)
    info.value = '已移出'
    await load()
  } catch (e: any) {
    err.value = e instanceof ApiError ? e.message : e?.message || '移出失败'
  } finally {
    loading.value = false
  }
}

function goRecommended(studentId: string) {
  // 你已有推荐接口：/api/classes/{classId}/students/{studentId}/recommended
  // 这里先不做 UI，后续你可以跳到一个推荐题目页面
  console.log('recommended for', studentId)
}
</script>

<style scoped>
.wrap { max-width: 980px; margin: 0 auto; padding: 20px 16px; }
.back { background: transparent; border: none; color: inherit; cursor: pointer; opacity: 0.8; margin-bottom: 10px; }
.card {
  background: rgba(255,255,255,0.05);
  border: 1px solid rgba(255,255,255,0.10);
  border-radius: 16px;
  padding: 14px;
  margin: 12px 0;
}
.top { display: flex; justify-content: space-between; gap: 12px; flex-wrap: wrap; align-items: flex-start; }
.h { font-size: 20px; font-weight: 900; margin: 0 0 6px; }
.meta { opacity: 0.75; font-size: 12px; display: flex; gap: 10px; flex-wrap: wrap; align-items: center; }
.mono { font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, "Liberation Mono", monospace; }

.section-h { font-weight: 900; margin-bottom: 10px; }
.row2 {
  border-top: 1px solid rgba(255,255,255,0.08);
  padding: 12px 0;
  display: flex;
  justify-content: space-between;
  gap: 10px;
  flex-wrap: wrap;
}
.row2:first-of-type { border-top: none; }
.title { font-weight: 800; }

.actions { display: flex; gap: 8px; flex-wrap: wrap; align-items: center; }
.btn {
  background: rgba(100,108,255,0.22);
  border: 1.5px solid rgba(100,108,255,0.45);
  color: #c5c8ff;
  border-radius: 12px;
  padding: 8px 10px;
  font-weight: 700;
  cursor: pointer;
}
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
.btn:disabled, .btn-danger:disabled { opacity: 0.5; cursor: not-allowed; }

.muted { opacity: 0.6; font-size: 13px; }

.tag {
  padding: 4px 10px;
  border-radius: 999px;
  border: 1px solid rgba(255,255,255,0.12);
  font-size: 12px;
}
.tag--PENDING { border-color: rgba(255,200,100,0.35); background: rgba(255,200,100,0.10); }
.tag--APPROVED { border-color: rgba(120,255,170,0.35); background: rgba(120,255,170,0.10); }
.tag--REJECTED { border-color: rgba(255,80,80,0.35); background: rgba(255,80,80,0.10); }

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
</style>