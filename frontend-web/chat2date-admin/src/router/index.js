import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '../stores/auth'
import LoginView from '../views/LoginView.vue'
import ReportsView from '../views/ReportsView.vue'
import UserManagementView from '../views/UserManagementView.vue'

const router = createRouter({
  history: createWebHistory('/'),
  routes: [
    {
      path: '/login',
      name: 'login',
      component: LoginView,
      meta: {
        title: 'Login - Chat2Date Admin',
        public: true,
      },
    },
    {
      path: '/',
      name: 'users',
      component: UserManagementView,
      meta: {
        title: 'User Management - Chat2Date Admin',
      },
    },
    {
      path: '/reports',
      name: 'reports',
      component: ReportsView,
      meta: {
        title: 'Report Management - Chat2Date Admin',
      },
    },
    {
      path: '/contact',
      name: 'contact',
      component: () => import('../views/ContactView.vue'),
    },
    {
      path: '/about',
      name: 'about',
      component: () => import('../views/AboutView.vue'),
      meta: {
        title: 'About - Chat2Date Admin',
      },
    },
  ],
})

// Auth guard
router.beforeEach((to, from, next) => {
  document.title = to.meta.title || 'Chat2Date Admin'

  const authStore = useAuthStore()

  if (to.meta.public) {
    // If already authenticated and trying to go to login, redirect to home
    if (to.name === 'login' && authStore.isAuthenticated) {
      return next({ name: 'reports' })
    }
    return next()
  }

  // Protected route — check auth
  if (!authStore.isAuthenticated) {
    return next({ name: 'login' })
  }

  next()
})

export default router
