// src/router/index.ts
import { createRouter, createWebHistory } from 'vue-router'
import { isLoggedIn } from '../stores/session'

import Login from '../pages/Login.vue'
import Profile from '../pages/Profile.vue'
import Practice from '../pages/Practice.vue'
import OnlineVerilogEditorPage from '../pages/OnlineVerilogEditorPage.vue'

const router = createRouter({
  history: createWebHistory(),
  routes: [
    // 关键：默认先去登录页
    { path: '/', redirect: '/login' },

    { path: '/login', name: 'login', component: Login },

    // 个人主页（你希望登录后到这里）
    {
      path: '/profile',
      name: 'profile',
      component: Profile,
      meta: { requiresAuth: true },
    },

    {
      path: '/practice',
      name: 'practice',
      component: Practice,
      meta: { requiresAuth: true },
    },

    {
      path: '/verilog',
      name: 'verilog',
      component: OnlineVerilogEditorPage,
      meta: { requiresAuth: true },
    },

    // 404：未登录就回登录；已登录也可以改成回 /profile
    { path: '/:pathMatch(.*)*', redirect: '/login' },
  ],
})

router.beforeEach((to) => {
  // 未登录访问受保护页面 -> 去登录
  if (to.meta.requiresAuth && !isLoggedIn.value) {
    return { name: 'login', query: { redirect: to.fullPath } }
  }

  // 已登录还访问登录页 -> 去个人主页
  if (to.name === 'login' && isLoggedIn.value) {
    return { name: 'profile' }
  }
})

export default router