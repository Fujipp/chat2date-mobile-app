<template>
  <div class="users-view">
    <div class="coming-soon-card">
      <div class="cs-bg"></div>
      <div class="cs-content">
        <div class="cs-icon">
          <Users :size="48" :stroke-width="1.5" />
        </div>
        <h1>User Management</h1>
        <p class="cs-subtitle">This feature is currently under development</p>
        <div class="cs-features">
          <div class="cs-feature">
            <UserSearch :size="18" :stroke-width="2" />
            <span>Search & filter users</span>
          </div>
          <div class="cs-feature">
            <Shield :size="18" :stroke-width="2" />
            <span>Manage user roles</span>
          </div>
          <div class="cs-feature">
            <Activity :size="18" :stroke-width="2" />
            <span>Behavior analytics</span>
          </div>
          <div class="cs-feature">
            <Ban :size="18" :stroke-width="2" />
            <span>Blacklist management</span>
          </div>
        </div>
        <div class="cs-badge">
          <Sparkles :size="14" :stroke-width="2" />
          Coming Soon
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import {
  Users, UserSearch, Shield, Activity, Ban, Sparkles
} from 'lucide-vue-next'
</script>

<style scoped>
.users-view {
  padding: 2rem;
  max-width: 800px;
  margin: 0 auto;
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: calc(100vh - 200px);
}

.coming-soon-card {
  position: relative;
  width: 100%;
  border-radius: var(--radius-2xl);
  overflow: hidden;
  background: var(--glass-bg);
  backdrop-filter: var(--glass-blur);
  border: 1px solid var(--glass-border);
  box-shadow: var(--shadow-lg), var(--shadow-brand);
}

.cs-bg {
  position: absolute;
  inset: 0;
  background:
    radial-gradient(ellipse 60% 50% at 30% 40%, rgba(96, 212, 255, 0.08) 0%, transparent 70%),
    radial-gradient(ellipse 40% 40% at 70% 60%, rgba(167, 139, 250, 0.06) 0%, transparent 60%);
  animation: meshShift 20s ease-in-out infinite alternate;
}

@keyframes meshShift {
  0% { opacity: 0.5; }
  100% { opacity: 1; }
}

.cs-content {
  position: relative;
  z-index: 1;
  padding: 4rem 2rem;
  text-align: center;
  display: flex;
  flex-direction: column;
  align-items: center;
}

.cs-icon {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 96px;
  height: 96px;
  border-radius: var(--radius-2xl);
  background: rgba(96, 212, 255, 0.08);
  border: 1px solid rgba(96, 212, 255, 0.15);
  color: var(--brand-primary);
  margin-bottom: 1.5rem;
  animation: float 3s ease-in-out infinite;
  box-shadow: 0 0 40px rgba(96, 212, 255, 0.1);
}

@keyframes float {
  0%, 100% { transform: translateY(0); }
  50% { transform: translateY(-10px); }
}

.cs-content h1 {
  font-size: 2rem;
  margin-bottom: 0.5rem;
  letter-spacing: -0.03em;
  background: linear-gradient(135deg, var(--text-primary) 0%, var(--brand-primary) 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.cs-subtitle {
  color: var(--text-muted);
  font-size: 1rem;
  margin-bottom: 2rem;
}

.cs-features {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 0.75rem;
  margin-bottom: 2rem;
  width: 100%;
  max-width: 420px;
}

.cs-feature {
  display: flex;
  align-items: center;
  gap: 0.625rem;
  padding: 0.875rem 1rem;
  background: rgba(30, 41, 59, 0.4);
  border: 1px solid var(--glass-border);
  border-radius: var(--radius-lg);
  color: var(--text-secondary);
  font-size: 0.8125rem;
  font-weight: 500;
  transition: all var(--transition-base);
}

.cs-feature:hover {
  border-color: var(--glass-border-hover);
  background: rgba(96, 212, 255, 0.04);
  color: var(--text-primary);
}

.cs-badge {
  display: inline-flex;
  align-items: center;
  gap: 0.375rem;
  padding: 0.5rem 1.25rem;
  background: rgba(96, 212, 255, 0.08);
  border: 1px solid rgba(96, 212, 255, 0.2);
  border-radius: var(--radius-full);
  font-weight: 600;
  font-size: 0.8125rem;
  color: var(--brand-primary);
  animation: glowPulse 3s ease-in-out infinite;
}

@keyframes glowPulse {
  0%, 100% { box-shadow: 0 0 15px rgba(96, 212, 255, 0.1); }
  50% { box-shadow: 0 0 25px rgba(96, 212, 255, 0.25); }
}

@media (max-width: 768px) {
  .users-view { padding: 1rem; }
  .cs-content { padding: 3rem 1.5rem; }
  .cs-content h1 { font-size: 1.5rem; }
  .cs-features { grid-template-columns: 1fr; }
  .cs-icon { width: 72px; height: 72px; }
}
</style>
