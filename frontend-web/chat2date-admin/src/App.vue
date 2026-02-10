<template>
  <div id="app">
    <!-- Navigation Bar -->
    <nav class="navbar">
      <div class="navbar-container">
        <div class="navbar-brand">
          <div class="brand-icon">
            <MessageCircleHeart :size="32" :stroke-width="2" />
          </div>
          <h1 class="brand-title">Chat2Date Admin</h1>
        </div>
        <ul class="navbar-menu">
          <li>
            <router-link to="/" :class="{ active: $route.path === '/' }">
              <FileText :size="20" :stroke-width="2" />
              <span>Reports</span>
            </router-link>
          </li>
          <li>
            <router-link to="/users" :class="{ active: $route.path === '/users' }">
              <Users :size="20" :stroke-width="2" />
              <span>Users</span>
            </router-link>
          </li>
          <li>
            <router-link to="/about" :class="{ active: $route.path === '/about' }">
              <Info :size="20" :stroke-width="2" />
              <span>About</span>
            </router-link>
          </li>
        </ul>
        <button class="mobile-menu-toggle" @click="toggleMobileMenu">
          <Menu v-if="!mobileMenuOpen" :size="24" />
          <X v-else :size="24" />
        </button>
      </div>
      <transition name="slide-down">
        <div v-if="mobileMenuOpen" class="mobile-menu">
          <router-link to="/" @click="closeMobileMenu" :class="{ active: $route.path === '/' }">
            <FileText :size="20" :stroke-width="2" />
            <span>Reports</span>
          </router-link>
          <router-link to="/users" @click="closeMobileMenu" :class="{ active: $route.path === '/users' }">
            <Users :size="20" :stroke-width="2" />
            <span>Users</span>
          </router-link>
          <router-link to="/about" @click="closeMobileMenu" :class="{ active: $route.path === '/about' }">
            <Info :size="20" :stroke-width="2" />
            <span>About</span>
          </router-link>
        </div>
      </transition>
    </nav>

    <!-- Main Content -->
    <main class="main-content">
      <RouterView />
    </main>

    <!-- Footer -->
    <footer class="footer">
      <div class="footer-content">
        <div class="footer-links">
          <a href="https://github.com" target="_blank" class="footer-link">
            <Github :size="16" />
            <span>GitHub</span>
          </a>
          <span class="footer-separator">•</span>
          <a href="http://cp25ssi2.sit.kmutt.ac.th/api/swagger-ui.html" target="_blank" class="footer-link">
            <Code :size="16" />
            <span>API Docs</span>
          </a>
        </div>
        <p class="footer-copyright">
          <Heart :size="14" class="heart-icon" />
          &copy; 2024 Chat2Date. All rights reserved.
        </p>
      </div>
    </footer>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { RouterView } from 'vue-router'
import {
  MessageCircleHeart,
  FileText,
  Users,
  Info,
  Menu,
  X,
  Github,
  Code,
  Heart
} from 'lucide-vue-next'

const mobileMenuOpen = ref(false)

const toggleMobileMenu = () => {
  mobileMenuOpen.value = !mobileMenuOpen.value
}

const closeMobileMenu = () => {
  mobileMenuOpen.value = false
}
</script>

<style scoped>
#app {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
}

/* Navbar */
.navbar {
  background: linear-gradient(135deg, var(--brand-primary) 0%, var(--btn-primary) 100%);
  box-shadow: var(--shadow-xl);
  position: sticky;
  top: 0;
  z-index: 100;
  border-bottom: 3px solid rgba(255, 255, 255, 0.2);
}

.navbar-container {
  max-width: 1400px;
  margin: 0 auto;
  padding: 1rem 2rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.navbar-brand {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  cursor: pointer;
  transition: transform 0.3s ease;
}

.navbar-brand:hover {
  transform: scale(1.02);
}

.brand-icon {
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--text-primary);
  animation: pulse 2s ease-in-out infinite;
}

@keyframes pulse {
  0%,
  100% {
    transform: scale(1);
  }
  50% {
    transform: scale(1.08);
  }
}

.brand-title {
  font-size: 1.5rem;
  font-weight: 700;
  color: var(--text-primary);
  margin: 0;
  letter-spacing: -0.5px;
  text-shadow: 1px 1px 2px rgba(0, 0, 0, 0.05);
}

.navbar-menu {
  display: flex;
  gap: 0.75rem;
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
  padding: 0.75rem 1.25rem;
  color: var(--text-primary);
  text-decoration: none;
  font-weight: 500;
  border-radius: var(--radius-lg);
  transition: all 0.3s ease;
  background: rgba(255, 255, 255, 0.15);
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.2);
}

.navbar-menu a:hover {
  background: rgba(255, 255, 255, 0.35);
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
  border-color: rgba(255, 255, 255, 0.4);
}

.navbar-menu a.active {
  background: var(--bg-white);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
  border-color: var(--bg-white);
}

.mobile-menu-toggle {
  display: none;
  background: rgba(255, 255, 255, 0.2);
  border: 1px solid rgba(255, 255, 255, 0.3);
  padding: 0.5rem;
  border-radius: var(--radius-md);
  cursor: pointer;
  color: var(--text-primary);
  transition: all 0.3s ease;
  align-items: center;
  justify-content: center;
}

.mobile-menu-toggle:hover {
  background: rgba(255, 255, 255, 0.35);
  transform: scale(1.05);
}

.mobile-menu {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
  padding: 1rem 2rem;
  background: rgba(255, 255, 255, 0.98);
  backdrop-filter: blur(20px);
  border-top: 1px solid rgba(0, 0, 0, 0.08);
  box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.5);
}

.mobile-menu a {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  padding: 1rem;
  color: var(--text-primary);
  text-decoration: none;
  font-weight: 500;
  border-radius: var(--radius-md);
  transition: all 0.2s ease;
  border: 1px solid transparent;
}

.mobile-menu a:hover {
  background: var(--bg-surface);
  border-color: var(--brand-primary-200);
}

.mobile-menu a.active {
  background: var(--brand-primary-200);
  color: var(--text-primary);
  border-color: var(--brand-primary);
}

/* Slide down animation */
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

/* Main Content */
.main-content {
  flex: 1;
  width: 100%;
  background: var(--bg-surface);
}

/* Footer */
.footer {
  background: linear-gradient(to top, var(--bg-white) 0%, var(--bg-surface) 100%);
  padding: 2rem;
  border-top: 1px solid var(--divider);
  box-shadow: 0 -4px 12px rgba(0, 0, 0, 0.05);
}

.footer-content {
  max-width: 1400px;
  margin: 0 auto;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 1rem;
}

.footer-links {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.footer-link {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  color: var(--text-secondary);
  text-decoration: none;
  font-size: 0.875rem;
  transition: all 0.2s ease;
  padding: 0.5rem;
  border-radius: var(--radius-md);
}

.footer-link:hover {
  color: var(--brand-primary);
  background: var(--bg-surface);
}

.footer-separator {
  color: var(--text-muted);
}

.footer-copyright {
  margin: 0;
  color: var(--text-muted);
  font-size: 0.875rem;
  display: flex;
  align-items: center;
  gap: 0.5rem;
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
    transform: scale(1.1);
  }
  20%,
  40% {
    transform: scale(1.05);
  }
}

/* Responsive */
@media (max-width: 768px) {
  .navbar-container {
    padding: 1rem;
  }

  .brand-title {
    font-size: 1.25rem;
  }

  .navbar-menu {
    display: none;
  }

  .mobile-menu-toggle {
    display: flex;
  }

  .footer-content {
    gap: 0.75rem;
  }

  .footer-links {
    flex-direction: column;
    gap: 0.5rem;
  }

  .footer-separator {
    display: none;
  }
}

@media (min-width: 769px) {
  .mobile-menu {
    display: none !important;
  }
}
</style>
