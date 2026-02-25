<template>
  <header class="nav">
    <div class="nav__inner">
      <div class="brand" @click="go('/profile')" role="button" tabindex="0">
        DigLearn
      </div>

      <nav class="links">
        <template v-if="isAdmin">
          <RouterLink to="/profile" class="link" :class="{ active: is('/profile') }">Profile</RouterLink>
          <RouterLink to="/classes" class="link" :class="{ active: is('/classes') }">Classes</RouterLink>
          <RouterLink to="/promote" class="link" :class="{ active: is('/promote') }">Promote</RouterLink>
        </template>

        <template v-else>
          <RouterLink to="/profile" class="link" :class="{ active: is('/profile') }">个人主页</RouterLink>
          <RouterLink to="/classes" class="link" :class="{ active: is('/classes') }">我的班级</RouterLink>
          <RouterLink to="/practice" class="link" :class="{ active: is('/practice') }">章节练习</RouterLink>
          <RouterLink to="/verilog" class="link" :class="{ active: is('/verilog') }">Verilog 在线仿真</RouterLink>
        </template>
      </nav>

      <div class="right">
        <template v-if="isLoggedIn">
          <span class="pill">{{ displayName }}</span>
          <button class="btn-logout" type="button" :disabled="loggingOut" @click="doLogout">
            {{ loggingOut ? '退出中…' : 'Logout' }}
          </button>
        </template>

        <template v-else>
          <RouterLink to="/login" class="btn-ghost">Login</RouterLink>
          <RouterLink to="/register" class="btn-ghost">Register</RouterLink>
        </template>
      </div>
    </div>
  </header>
</template>

<script setup lang="ts">
import { computed, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { isLoggedIn, name, logout, me } from '../stores/session'

const route = useRoute()
const router = useRouter()
const loggingOut = ref(false)
const isAdmin = computed(() => me.value?.role === 'ADMIN' || me.value?.role === 'ROLE_ADMIN')

const displayName = computed(() => name.value || '已登录')

function is(prefix: string) {
  return route.path.startsWith(prefix)
}
function go(path: string) {
  router.push(path)
}

async function doLogout() {
  if (loggingOut.value) return
  loggingOut.value = true
  try {
    await logout()
    await router.replace({ name: 'login' })
  } finally {
    loggingOut.value = false
  }
}
</script>

<style scoped>
.nav {
  position: sticky;
  top: 0;
  z-index: 10;
  backdrop-filter: blur(10px);
  background: color-mix(in srgb, var(--bg, #242424) 86%, transparent);
  border-bottom: 1px solid rgba(255, 255, 255, 0.10);
}
.nav__inner {
  max-width: 1100px;
  margin: 0 auto;
  padding: 12px 16px;
  display: flex;
  align-items: center;
  gap: 16px;
}
.brand {
  font-weight: 800;
  letter-spacing: 0.3px;
  cursor: pointer;
}
.links { display: flex; gap: 12px; flex: 1; }
.link {
  padding: 8px 10px;
  border-radius: 10px;
  color: inherit;
  opacity: 0.85;
}
.link:hover { opacity: 1; background: rgba(255,255,255,0.06); }
.link.active {
  opacity: 1;
  background: rgba(100,108,255,0.18);
  border: 1px solid rgba(100,108,255,0.25);
}

.right { display: flex; align-items: center; gap: 10px; }

.pill {
  font-size: 12px;
  padding: 6px 10px;
  border-radius: 999px;
  border: 1px solid rgba(255,255,255,0.12);
  opacity: 0.9;
}

.btn-logout {
  font-size: 12px;
  padding: 7px 10px;
  border-radius: 10px;
  border: 1px solid rgba(255, 80, 80, 0.35);
  background: rgba(255, 80, 80, 0.12);
  color: rgba(255, 220, 220, 0.95);
  cursor: pointer;
}
.btn-logout:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.btn-ghost {
  font-size: 12px;
  padding: 7px 10px;
  border-radius: 10px;
  border: 1px solid rgba(255,255,255,0.14);
  opacity: 0.85;
}
.btn-ghost:hover { opacity: 1; background: rgba(255,255,255,0.06); }
</style>