import { createRouter, createWebHistory } from 'vue-router'
import ReportsView from '../views/ReportsView.vue'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      name: 'reports',
      component: ReportsView,
      meta: {
        title: 'Report Management - Chat2Date Admin',
      },
    },
    {
      path: '/about',
      name: 'about',
      component: () => import('../views/AboutView.vue'),
      meta: {
        title: 'About - Chat2Date Admin',
      },
    },
    {
      path: '/users',
      name: 'users',
      component: () => import('../views/HomeView.vue'),
      meta: {
        title: 'User Management - Chat2Date Admin',
      },
    },
  ],
})

// Update document title on route change
router.beforeEach((to, from, next) => {
  document.title = to.meta.title || 'Chat2Date Admin'
  next()
})

export default router
