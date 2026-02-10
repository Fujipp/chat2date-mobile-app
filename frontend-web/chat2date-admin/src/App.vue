<template>
  <div id="app">
    <!-- Navigation Bar -->
    <nav class="navbar">
      <div class="navbar-container">
        <div class="navbar-brand">
          <span class="brand-icon">💬</span>
          <h1 class="brand-title">Chat2Date Admin</h1>
        </div>
        <ul class="navbar-menu">
          <li>
            <router-link to="/" :class="{ active: $route.path === '/' }">
              <span class="nav-icon">📊</span>
              Reports
            </router-link>
          </li>
          <li>
            <router-link to="/users" :class="{ active: $route.path === '/users' }">
              <span class="nav-icon">👥</span>
              Users
            </router-link>
          </li>
          <li>
            <router-link to="/about" :class="{ active: $route.path === '/about' }">
              <span class="nav-icon">ℹ️</span>
              About
            </router-link>
          </li>
        </ul>
        <button class="mobile-menu-toggle" @click="toggleMobileMenu">
          <span>☰</span>
        </button>
      </div>
      <div v-if="mobileMenuOpen" class="mobile-menu">
        <router-link to="/" @click="closeMobileMenu">
          <span class="nav-icon">📊</span>
          Reports
        </router-link>
        <router-link to="/users" @click="closeMobileMenu">
          <span class="nav-icon">👥</span>
          Users
        </router-link>
        <router-link to="/about" @click="closeMobileMenu">
          <span class="nav-icon">ℹ️</span>
          About
        </router-link>
      </div>
    </nav>

    <!-- Main Content -->
    <main class="main-content">
      <RouterView />
    </main>

    <!-- Footer -->
    <footer class="footer">
      <p>&copy; 2024 Chat2Date. All rights reserved.</p>
    </footer>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { RouterView } from 'vue-router'

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
  box-shadow: var(--shadow-lg);
  position: sticky;
  top: 0;
  z-index: 100;
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
}

.brand-icon {
  font-size: 2rem;
  animation: pulse 2s ease-in-out infinite;
}

@keyframes pulse {
  0%,
  100% {
    transform: scale(1);
  }
  50% {
    transform: scale(1.1);
  }
}

.brand-title {
  font-size: 1.5rem;
  font-weight: 700;
  color: var(--text-primary);
  margin: 0;
  letter-spacing: -0.5px;
}

.navbar-menu {
  display: flex;
  gap: 1rem;
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
  background: rgba(255, 255, 255, 0.2);
  backdrop-filter: blur(10px);
}

.navbar-menu a:hover {
  background: rgba(255, 255, 255, 0.4);
  transform: translateY(-2px);
  box-shadow: var(--shadow-md);
}

.navbar-menu a.active {
  background: var(--bg-white);
  box-shadow: var(--shadow-md);
}

.nav-icon {
  font-size: 1.2rem;
}

.mobile-menu-toggle {
  display: none;
  background: rgba(255, 255, 255, 0.2);
  border: none;
  font-size: 1.5rem;
  padding: 0.5rem 1rem;
  border-radius: var(--radius-md);
  cursor: pointer;
  color: var(--text-primary);
  transition: all 0.3s ease;
}

.mobile-menu-toggle:hover {
  background: rgba(255, 255, 255, 0.4);
}

.mobile-menu {
  display: none;
  flex-direction: column;
  gap: 0.5rem;
  padding: 1rem 2rem;
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(10px);
  border-top: 1px solid rgba(0, 0, 0, 0.1);
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
}

.mobile-menu a:hover {
  background: var(--bg-surface);
}

.mobile-menu a.active {
  background: var(--brand-primary-200);
  color: var(--text-primary);
}

/* Main Content */
.main-content {
  flex: 1;
  width: 100%;
  background: var(--bg-surface);
}

/* Footer */
.footer {
  background: var(--bg-white);
  padding: 2rem;
  text-align: center;
  border-top: 1px solid var(--divider);
  box-shadow: 0 -4px 6px -1px rgba(0, 0, 0, 0.1);
}

.footer p {
  margin: 0;
  color: var(--text-muted);
  font-size: 0.875rem;
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
    display: block;
  }

  .mobile-menu {
    display: flex;
  }

  .main-content {
    padding: 0;
  }
}

@media (min-width: 769px) {
  .mobile-menu {
    display: none !important;
  }
}
</style>
