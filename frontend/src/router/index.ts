// src/router/index.ts
import { createRouter, createWebHistory } from 'vue-router'
import { ensureMe, isLoggedIn, me } from '../stores/session'

import Promote from '../pages/Promote.vue'
import Login from '../pages/Login.vue'
import Register from '../pages/Register.vue'
import Profile from '../pages/Profile.vue'
import Practice from '../pages/Practice.vue'
import OnlineVerilogEditorPage from '../pages/OnlineVerilogEditorPage.vue'
import Classes from '../pages/Classes.vue'
import ClassDetail from '../pages/ClassDetail.vue'

const router = createRouter({
  history: createWebHistory(),
  routes: [
    { path: '/', redirect: '/profile' },

    { path: '/login', name: 'login', component: Login },
    { path: '/register', name: 'register', component: Register },

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
    {
      path: '/promote',
      name: 'promote',
      component: Promote,
      meta: { requiresAuth: true, requiresRole: 'ADMIN' },
    },
    {
      path: '/classes',
      name: 'classes',
      component: Classes,
      meta: { requiresAuth: true },
    },
    {
      path: '/classes/:id',
      name: 'classDetail',
      component: ClassDetail,
      meta: { requiresAuth: true },
    },

    // 404：更合理的做法：已登录回 profile，否则回 login
    {
      path: '/:pathMatch(.*)*',
      redirect: () => (isLoggedIn.value ? '/profile' : '/login'),
    },
  ],
})

router.beforeEach(async (to) => {
  if (to.meta.requiresAuth || to.name === 'login' || to.name === 'register') {
    try {
      await ensureMe()
    } catch (e) {
      console.error('[ensureMe failed]', e)
    }
  }

  if (to.meta.requiresAuth && !isLoggedIn.value) {
    return { name: 'login', query: { redirect: to.fullPath } }
  }

  // ✅ ADMIN 路由保护
  const requiredRole = (to.meta as any).requiresRole as string | undefined
  if (requiredRole) {
    const role = me.value?.role
    if (!(role === requiredRole || role === `ROLE_${requiredRole}`)) {
      return { name: 'profile' } // 或者你做一个 403 页面
    }
  }

  if ((to.name === 'login' || to.name === 'register') && isLoggedIn.value) {
    return { name: 'profile' }
  }

  return true
})

export default router