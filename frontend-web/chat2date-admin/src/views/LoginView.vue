<template>
  <div class="login-view">
    <div class="login-bg"></div>
    <div class="login-card">
      <div class="login-header">
        <div class="login-icon">
          <MessageCircleHeart :size="40" :stroke-width="1.5" />
        </div>
        <h1>Chat2Date</h1>
        <span class="login-badge">Admin Dashboard</span>
        <p class="login-desc">Sign in with your admin credentials to continue</p>
      </div>

      <div class="login-body">
        <!-- Error -->
        <div v-if="authStore.error" class="login-error">
          <AlertTriangle :size="16" />
          <span>{{ authStore.error }}</span>
        </div>

        <!-- Login Form -->
        <form @submit.prevent="handleLogin" class="login-form">
          <div class="input-group">
            <label for="identifier">
              <Mail :size="14" />
              Email or Phone Number
            </label>
            <input
              id="identifier"
              type="text"
              v-model="identifier"
              placeholder="e.g. admin@chat2date.internal"
              required
              autocomplete="email"
              :disabled="authStore.loading"
            />
          </div>

          <button type="submit" class="btn-login" :disabled="authStore.loading || !identifier.trim()">
            <Loader2 v-if="authStore.loading" :size="18" class="spin" />
            <LogIn v-else :size="18" />
            <span>{{ authStore.loading ? 'Signing in...' : 'Sign In' }}</span>
          </button>
        </form>

        <div class="login-divider">
          <span>Admin access only</span>
        </div>

        <div class="login-note">
          <Shield :size="14" />
          <span>Only accounts with admin role can access this dashboard</span>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '../stores/auth'
import { MessageCircleHeart, AlertTriangle, Shield, Loader2, LogIn, Mail } from 'lucide-vue-next'

const router = useRouter()
const authStore = useAuthStore()
const identifier = ref('')

const handleLogin = async () => {
  try {
    await authStore.loginWithEmail(identifier.value.trim())
    router.push('/')
  } catch (err) {
    console.error('Login failed:', err)
  }
}
</script>

<style scoped>
.login-view {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 2rem;
  position: relative;
}

.login-bg {
  position: fixed;
  inset: 0;
  background:
    radial-gradient(ellipse 80% 50% at 20% 40%, rgba(96, 212, 255, 0.08) 0%, transparent 60%),
    radial-gradient(ellipse 60% 40% at 80% 20%, rgba(77, 216, 230, 0.06) 0%, transparent 50%),
    radial-gradient(ellipse 50% 60% at 50% 80%, rgba(124, 255, 178, 0.04) 0%, transparent 50%);
  animation: meshShift 20s ease-in-out infinite alternate;
  pointer-events: none;
}

@keyframes meshShift {
  0% { opacity: 0.5; }
  100% { opacity: 1; }
}

.login-card {
  position: relative;
  z-index: 1;
  background: var(--glass-bg-strong);
  backdrop-filter: blur(30px) saturate(180%);
  -webkit-backdrop-filter: blur(30px) saturate(180%);
  border: 1px solid var(--glass-border);
  border-radius: var(--radius-2xl);
  box-shadow: var(--shadow-2xl), var(--shadow-brand);
  max-width: 420px;
  width: 100%;
  overflow: hidden;
  animation: modalSlideUp 0.6s cubic-bezier(0.34, 1.56, 0.64, 1);
}

@keyframes modalSlideUp {
  from { opacity: 0; transform: translateY(30px) scale(0.97); }
  to { opacity: 1; transform: translateY(0) scale(1); }
}

.login-header {
  padding: 2.5rem 2rem 1.5rem;
  text-align: center;
  background: linear-gradient(180deg, rgba(96, 212, 255, 0.06) 0%, transparent 100%);
  border-bottom: 1px solid rgba(99, 118, 148, 0.08);
}

.login-icon {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 80px;
  height: 80px;
  border-radius: var(--radius-2xl);
  background: linear-gradient(135deg, var(--brand-primary) 0%, var(--btn-primary) 100%);
  color: var(--bg-body);
  margin-bottom: 1.25rem;
  box-shadow: 0 0 30px rgba(96, 212, 255, 0.3);
  animation: float 3s ease-in-out infinite;
}

@keyframes float {
  0%, 100% { transform: translateY(0); }
  50% { transform: translateY(-6px); }
}

.login-header h1 {
  font-size: 1.75rem;
  margin-bottom: 0.5rem;
  letter-spacing: -0.03em;
  background: linear-gradient(135deg, var(--text-primary) 0%, var(--brand-primary) 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.login-badge {
  display: inline-flex;
  padding: 0.25rem 0.75rem;
  background: rgba(96, 212, 255, 0.1);
  border: 1px solid rgba(96, 212, 255, 0.2);
  border-radius: var(--radius-full);
  font-size: 0.6875rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.1em;
  color: var(--brand-primary);
  margin-bottom: 1rem;
}

.login-desc {
  color: var(--text-muted);
  font-size: 0.875rem;
  margin: 0;
  line-height: 1.5;
}

.login-body {
  padding: 1.75rem 2rem 2rem;
}

.login-error {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.75rem 1rem;
  background: rgba(248, 113, 113, 0.08);
  border: 1px solid rgba(248, 113, 113, 0.2);
  border-radius: var(--radius-lg);
  color: var(--color-error);
  font-size: 0.8125rem;
  font-weight: 500;
  margin-bottom: 1.25rem;
}

.login-form {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.input-group {
  display: flex;
  flex-direction: column;
  gap: 0.375rem;
}

.input-group label {
  display: flex;
  align-items: center;
  gap: 0.375rem;
  font-size: 0.8125rem;
  font-weight: 600;
  color: var(--text-secondary);
}

.input-group input {
  padding: 0.75rem 1rem;
  background: rgba(99, 118, 148, 0.08);
  border: 1px solid rgba(99, 118, 148, 0.15);
  border-radius: var(--radius-md);
  font-size: 0.9375rem;
  font-family: inherit;
  color: var(--text-primary);
  outline: none;
  transition: all var(--transition-base);
}

.input-group input::placeholder {
  color: var(--text-muted);
  opacity: 0.6;
}

.input-group input:focus {
  border-color: rgba(96, 212, 255, 0.4);
  background: rgba(99, 118, 148, 0.12);
  box-shadow: 0 0 0 3px rgba(96, 212, 255, 0.08);
}

.input-group input:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.btn-login {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.625rem;
  width: 100%;
  padding: 0.875rem 1.5rem;
  background: linear-gradient(135deg, var(--brand-primary) 0%, var(--btn-primary) 100%);
  border: none;
  border-radius: var(--radius-lg);
  font-size: 0.9375rem;
  font-weight: 600;
  font-family: inherit;
  color: var(--bg-body);
  cursor: pointer;
  transition: all var(--transition-base);
  box-shadow: 0 0 20px rgba(96, 212, 255, 0.2);
}

.btn-login:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 0 30px rgba(96, 212, 255, 0.35);
}

.btn-login:active:not(:disabled) {
  transform: translateY(0);
}

.btn-login:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.spin {
  animation: spin 1s linear infinite;
}

@keyframes spin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}

.login-divider {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  margin: 1.5rem 0;
}

.login-divider::before,
.login-divider::after {
  content: '';
  flex: 1;
  height: 1px;
  background: var(--divider);
}

.login-divider span {
  font-size: 0.6875rem;
  color: var(--text-muted);
  text-transform: uppercase;
  letter-spacing: 0.06em;
  font-weight: 600;
  white-space: nowrap;
}

.login-note {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  padding: 0.75rem;
  background: rgba(96, 212, 255, 0.04);
  border: 1px solid rgba(96, 212, 255, 0.1);
  border-radius: var(--radius-lg);
  color: var(--text-muted);
  font-size: 0.75rem;
}

@media (max-width: 480px) {
  .login-view { padding: 1rem; }
  .login-header { padding: 2rem 1.5rem 1.25rem; }
  .login-body { padding: 1.5rem; }
  .login-icon { width: 64px; height: 64px; }
  .login-header h1 { font-size: 1.5rem; }
}
</style>
