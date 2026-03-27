<template>
  <div id="app">
    <!-- Navigation Bar (hidden on login page) -->
    <nav v-if="showNavbar" class="navbar">
      <div class="navbar-container">
        <div class="navbar-brand">
          <div class="brand-icon">
            <MessageCircleHeart :size="28" :stroke-width="2" />
          </div>
          <h1 class="brand-title">Chat2Date</h1>
          <span class="brand-badge">Admin</span>
        </div>
        <ul class="navbar-menu">

          <li>
            <router-link to="/" :class="{ active: $route.path === '/' }">
              <Users :size="18" :stroke-width="2" />
              <span>Users</span>
            </router-link>
          </li>
          <li>
            <router-link to="/reports" :class="{ active: $route.path === '/reports' }">
              <FileText :size="18" :stroke-width="2" />
              <span>Reports</span>
            </router-link>
          </li>

          <li>
            <router-link to="/contact" :class="{ active: $route.path === '/contact' }">
              <Mail :size="18" :stroke-width="2" />
              <span>Contact</span>
            </router-link>
          </li>
          <li>
            <router-link to="/about" :class="{ active: $route.path === '/about' }">
              <Info :size="18" :stroke-width="2" />
              <span>About</span>
            </router-link>
          </li>
        </ul>
        <div class="navbar-right">
          <span class="user-email" v-if="authStore.userEmail">
            <Mail :size="14" />
            {{ authStore.userEmail }}
          </span>
          <button class="btn-logout" @click="handleLogout">
            <LogOut :size="16" />
            <span class="logout-text">Logout</span>
          </button>
          <button class="mobile-menu-toggle" @click="toggleMobileMenu">
            <Menu v-if="!mobileMenuOpen" :size="22" />
            <X v-else :size="22" />
          </button>
        </div>
      </div>
      <transition name="slide-down">
        <div v-if="mobileMenuOpen" class="mobile-menu">
          <router-link to="/" @click="closeMobileMenu" :class="{ active: $route.path === '/' }">
            <FileText :size="18" :stroke-width="2" />
            <span>Reports</span>
          </router-link>
          <router-link to="/users" @click="closeMobileMenu" :class="{ active: $route.path === '/users' }">
            <Users :size="18" :stroke-width="2" />
            <span>Users</span>
          </router-link>
          <router-link to="/about" @click="closeMobileMenu" :class="{ active: $route.path === '/about' }">
            <Info :size="18" :stroke-width="2" />
            <span>About</span>
          </router-link>
          <div class="mobile-menu-divider"></div>
          <div class="mobile-user-email" v-if="authStore.userEmail">
            <Mail :size="14" />
            {{ authStore.userEmail }}
          </div>
          <button class="mobile-logout" @click="handleLogout">
            <LogOut :size="16" />
            <span>Logout</span>
          </button>
        </div>
      </transition>
    </nav>

    <!-- Main Content -->
    <main class="main-content">
      <RouterView />
    </main>

    <!-- Footer (hidden on login page) -->
    <footer v-if="showNavbar" class="footer">
      <div class="footer-content">
        <div class="footer-links">
          <a href="https://github.com" target="_blank" class="footer-link">
            <Github :size="15" />
            <span>GitHub</span>
          </a>
          <span class="footer-dot"></span>
          <a href="/api/v1/swagger-ui.html" target="_blank" class="footer-link">
            <Code :size="15" />
            <span>API Docs</span>
          </a>
        </div>
        <p class="footer-copyright">
          <Heart :size="12" class="heart-icon" />
          &copy; 2025 Chat2Date · All rights reserved
        </p>
      </div>
    </footer>
  </div>
</template>

<script setup>
import {
  Code,
  FileText,
  Github,
  Heart,
  Info,
  LogOut,
  Mail,
  Menu,
  MessageCircleHeart,
  Users,
  X
} from 'lucide-vue-next'
import { computed, ref } from 'vue'
import { RouterView, useRoute, useRouter } from 'vue-router'
import { useAuthStore } from './stores/auth'

const route = useRoute()
const router = useRouter()
const authStore = useAuthStore()
const mobileMenuOpen = ref(false)

const showNavbar = computed(() => route.name !== 'login')

const toggleMobileMenu = () => { mobileMenuOpen.value = !mobileMenuOpen.value }
const closeMobileMenu = () => { mobileMenuOpen.value = false }

const handleLogout = async () => {
  closeMobileMenu()
  await authStore.logout()
  router.push('/login')
}
</script>

<style scoped>
#app {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
}

/* ===== Navbar ===== */
.navbar {
  background: rgba(13, 19, 33, 0.75);
  backdrop-filter: blur(24px) saturate(180%);
  -webkit-backdrop-filter: blur(24px) saturate(180%);
  position: sticky;
  top: 0;
  z-index: 100;
  border-bottom: 1px solid rgba(99, 118, 148, 0.12);
}

.navbar-container {
  max-width: 1400px;
  margin: 0 auto;
  padding: 0.75rem 2rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.navbar-brand {
  display: flex;
  align-items: center;
  gap: 0.625rem;
  cursor: pointer;
}

.brand-icon {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 38px;
  height: 38px;
  border-radius: var(--radius-lg);
  background: linear-gradient(135deg, var(--brand-primary) 0%, var(--btn-primary) 100%);
  color: var(--bg-body);
  box-shadow: 0 0 20px rgba(96, 212, 255, 0.25);
  animation: glowPulse 3s ease-in-out infinite;
}

.brand-title {
  font-size: 1.25rem;
  font-weight: 700;
  color: var(--text-primary);
  margin: 0;
  letter-spacing: -0.03em;
}

.brand-badge {
  font-size: 0.625rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.1em;
  padding: 0.2rem 0.5rem;
  background: rgba(96, 212, 255, 0.12);
  color: var(--brand-primary);
  border-radius: var(--radius-sm);
  border: 1px solid rgba(96, 212, 255, 0.2);
}

.navbar-menu {
  display: flex;
  gap: 0.375rem;
  list-style: none;
  margin: 0;
  padding: 0;
}

.navbar-menu li {
  display: flex;
}

.navbar-menu a {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.5rem 1rem;
  color: var(--text-muted);
  text-decoration: none;
  font-weight: 500;
  font-size: 0.875rem;
  border-radius: var(--radius-md);
  transition: all var(--transition-base);
  border: 1px solid transparent;
}

.navbar-menu a:hover {
  color: var(--text-primary);
  background: rgba(99, 118, 148, 0.1);
  border-color: rgba(99, 118, 148, 0.1);
}

.navbar-menu a.active {
  color: var(--brand-primary);
  background: rgba(96, 212, 255, 0.08);
  border-color: rgba(96, 212, 255, 0.15);
  box-shadow: 0 0 15px rgba(96, 212, 255, 0.08);
}

/* Right section */
.navbar-right {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.user-email {
  display: flex;
  align-items: center;
  gap: 0.375rem;
  color: var(--text-muted);
  font-size: 0.75rem;
  padding: 0.375rem 0.75rem;
  background: rgba(99, 118, 148, 0.08);
  border-radius: var(--radius-md);
  border: 1px solid rgba(99, 118, 148, 0.1);
  max-width: 200px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.btn-logout {
  display: flex;
  align-items: center;
  gap: 0.375rem;
  padding: 0.5rem 0.875rem;
  background: rgba(248, 113, 113, 0.08);
  border: 1px solid rgba(248, 113, 113, 0.15);
  border-radius: var(--radius-md);
  cursor: pointer;
  color: var(--color-error);
  font-size: 0.8125rem;
  font-weight: 500;
  font-family: inherit;
  transition: all var(--transition-base);
}

.btn-logout:hover {
  background: rgba(248, 113, 113, 0.15);
  border-color: rgba(248, 113, 113, 0.3);
  transform: translateY(-1px);
}

/* Mobile Toggle */
.mobile-menu-toggle {
  display: none;
  background: rgba(99, 118, 148, 0.1);
  border: 1px solid var(--glass-border);
  padding: 0.5rem;
  border-radius: var(--radius-md);
  cursor: pointer;
  color: var(--text-primary);
  transition: all 0.3s ease;
  align-items: center;
  justify-content: center;
}

.mobile-menu-toggle:hover {
  background: rgba(96, 212, 255, 0.1);
}

.mobile-menu {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
  padding: 0.75rem 1.5rem 1rem;
  background: rgba(13, 19, 33, 0.95);
  backdrop-filter: blur(24px);
  border-top: 1px solid rgba(99, 118, 148, 0.1);
}

.mobile-menu a {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  padding: 0.875rem 1rem;
  color: var(--text-secondary);
  text-decoration: none;
  font-weight: 500;
  border-radius: var(--radius-md);
  transition: all 0.2s ease;
  border: 1px solid transparent;
}

.mobile-menu a:hover {
  background: rgba(99, 118, 148, 0.1);
  color: var(--text-primary);
}

.mobile-menu a.active {
  background: rgba(96, 212, 255, 0.08);
  color: var(--brand-primary);
  border-color: rgba(96, 212, 255, 0.15);
}

.mobile-menu-divider {
  height: 1px;
  background: rgba(99, 118, 148, 0.15);
  margin: 0.5rem 0;
}

.mobile-user-email {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.75rem 1rem;
  color: var(--text-muted);
  font-size: 0.8125rem;
}

.mobile-logout {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  padding: 0.875rem 1rem;
  color: var(--color-error);
  font-size: 0.875rem;
  font-weight: 500;
  background: rgba(248, 113, 113, 0.06);
  border: 1px solid rgba(248, 113, 113, 0.12);
  border-radius: var(--radius-md);
  cursor: pointer;
  font-family: inherit;
  transition: all 0.2s ease;
}

.mobile-logout:hover {
  background: rgba(248, 113, 113, 0.12);
}

/* Slide animation */
.slide-down-enter-active,
.slide-down-leave-active {
  transition: all 0.3s ease;
}

.slide-down-enter-from {
  opacity: 0;
  transform: translateY(-10px);
}

.slide-down-leave-to {
  opacity: 0;
  transform: translateY(-10px);
}

/* ===== Main Content ===== */
.main-content {
  flex: 1;
  width: 100%;
}

/* ===== Footer ===== */
.footer {
  background: rgba(13, 19, 33, 0.6);
  backdrop-filter: blur(16px);
  padding: 1.25rem 2rem;
  border-top: 1px solid rgba(99, 118, 148, 0.1);
}

.footer-content {
  max-width: 1400px;
  margin: 0 auto;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.75rem;
}

.footer-links {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.footer-link {
  display: flex;
  align-items: center;
  gap: 0.375rem;
  color: var(--text-muted);
  text-decoration: none;
  font-size: 0.8125rem;
  transition: all 0.2s ease;
  padding: 0.375rem 0.625rem;
  border-radius: var(--radius-md);
}

.footer-link:hover {
  color: var(--brand-primary);
  background: rgba(96, 212, 255, 0.06);
}

.footer-dot {
  width: 3px;
  height: 3px;
  border-radius: 50%;
  background: var(--neutral-500);
}

.footer-copyright {
  margin: 0;
  color: var(--text-muted);
  font-size: 0.75rem;
  display: flex;
  align-items: center;
  gap: 0.375rem;
}

.heart-icon {
  color: var(--color-error);
  animation: heartbeat 1.5s ease-in-out infinite;
}

@keyframes heartbeat {

  0%,
  100% {
    transform: scale(1);
  }

  10%,
  30% {
    transform: scale(1.15);
  }

  20%,
  40% {
    transform: scale(1.05);
  }
}

@keyframes glowPulse {

  0%,
  100% {
    box-shadow: 0 0 15px rgba(96, 212, 255, 0.2);
  }

  50% {
    box-shadow: 0 0 25px rgba(96, 212, 255, 0.35);
  }
}

/* ===== Responsive ===== */
@media (max-width: 768px) {
  .navbar-container {
    padding: 0.75rem 1rem;
  }

  .brand-title {
    font-size: 1.125rem;
  }

  .navbar-menu {
    display: none;
  }

  .user-email {
    display: none;
  }

  .logout-text {
    display: none;
  }

  .btn-logout {
    padding: 0.5rem;
  }

  .mobile-menu-toggle {
    display: flex;
  }

  .footer-content {
    gap: 0.5rem;
  }

  .footer-links {
    flex-direction: column;
    gap: 0.25rem;
  }

  .footer-dot {
    display: none;
  }
}

@media (min-width: 769px) {
  .mobile-menu {
    display: none !important;
  }
}
</style>
