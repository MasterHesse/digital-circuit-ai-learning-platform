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
      <p class="login-p">请输入你的用户 ID 以继续学习</p>

      <div class="field">
        <label class="field-label">用户 ID</label>
        <input
          v-model="id"
          class="field-input"
          placeholder="请输入 userId…"
          autocomplete="off"
          @keyup.enter="login"
        />
      </div>

      <button class="btn-submit" :disabled="!id.trim()" @click="login">
        进入学习 →
      </button>

    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { setUserId } from '../stores/session'

const router = useRouter()
const route = useRoute()
const id = ref('')

async function login() {
  if (!id.value.trim()) return
  setUserId(id.value.trim())
  const redirect = (route.query.redirect as string) || '/profile'
  await router.replace(redirect)
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
.brand-name { font-size: 14px; font-weight: 800; }
.brand-eng  { font-size: 11px; opacity: 0.5; margin-top: 3px; letter-spacing: 0.03em; }

.sep {
  height: 1px;
  background: rgba(255, 255, 255, 0.07);
  margin-bottom: 22px;
}

/* ─── Heading ─── */
.login-h { margin: 0 0 6px; font-size: 21px; font-weight: 800; }
.login-p { margin: 0 0 22px; font-size: 13px; opacity: 0.55; }

/* ─── Field ─── */
.field { margin-bottom: 18px; }
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
.field-input::placeholder { opacity: 0.35; }

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
.btn-submit:active:not(:disabled) { transform: translateY(0); }
.btn-submit:disabled { opacity: 0.28; cursor: not-allowed; }
</style>