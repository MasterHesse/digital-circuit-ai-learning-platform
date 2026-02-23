<template>
  <header class="nav">
    <div class="nav__inner">
      <div class="brand" @click="go('/profile')" role="button" tabindex="0">
        DigLearn
      </div>

      <nav class="links">
        <RouterLink to="/profile" class="link" :class="{ active: is('/profile') }">主页</RouterLink>
        <RouterLink to="/practice" class="link" :class="{ active: is('/practice') }">练习</RouterLink>
        <RouterLink to="/verilog" class="link" :class="{ active: is('/verilog') }">Online Verilog</RouterLink>
      </nav>

      <div class="right">
        <span class="pill">Demo</span>
      </div>
    </div>
  </header>
</template>

<script setup lang="ts">
import { useRoute, useRouter } from 'vue-router'

const route = useRoute()
const router = useRouter()

function is(prefix: string) {
  return route.path.startsWith(prefix)
}
function go(path: string) {
  router.push(path)
}
</script>

<style scoped>
.nav {
  position: sticky;
  top: 0;
  z-index: 10;
  backdrop-filter: blur(10px);
  background: color-mix(in srgb, var(--bg, #242424) 86%, transparent);
  border-bottom: 1px solid rgba(255,255,255,0.10);
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
.link.active { opacity: 1; background: rgba(100,108,255,0.18); border: 1px solid rgba(100,108,255,0.25); }
.right { display: flex; align-items: center; }
.pill {
  font-size: 12px;
  padding: 6px 10px;
  border-radius: 999px;
  border: 1px solid rgba(255,255,255,0.12);
  opacity: 0.85;
}
</style>