<template>
  <div class="about-view">
    <!-- Hero Section -->
    <div class="hero">
      <div class="hero-bg"></div>
      <div class="hero-content">
        <div class="hero-icon-wrap">
          <MessageCircleHeart :size="48" :stroke-width="1.5" />
        </div>
        <h1>Chat2Date Admin</h1>
        <p class="hero-subtitle">
          Administrative dashboard for managing reports, users, and platform moderation
        </p>
        <div class="version-badge">
          <Tag :size="13" :stroke-width="2" />
          v1.0.0
        </div>
      </div>
    </div>

    <!-- Features -->
    <section class="section">
      <div class="section-header">
        <div class="icon-wrapper icon-wrapper-lg icon-wrapper-brand">
          <Sparkles :size="24" :stroke-width="2" />
        </div>
        <h2>Key Features</h2>
      </div>
      <div class="features-grid">
        <div class="feature-card">
          <div class="icon-wrapper icon-wrapper-brand">
            <BarChart3 :size="22" :stroke-width="2" />
          </div>
          <h3>Report Management</h3>
          <p>View, filter, and manage user reports with detailed evidence</p>
        </div>
        <div class="feature-card">
          <div class="icon-wrapper icon-wrapper-purple">
            <Search :size="22" :stroke-width="2" />
          </div>
          <h3>Advanced Filtering</h3>
          <p>Filter by status, sort by date or ID, paginate seamlessly</p>
        </div>
        <div class="feature-card">
          <div class="icon-wrapper icon-wrapper-teal">
            <UsersIcon :size="22" :stroke-width="2" />
          </div>
          <h3>User Profiles</h3>
          <p>Comprehensive user data with behavior scores and status</p>
        </div>
        <div class="feature-card">
          <div class="icon-wrapper icon-wrapper-pink">
            <ImageIcon :size="22" :stroke-width="2" />
          </div>
          <h3>Evidence Review</h3>
          <p>View and review evidence images and videos from reports</p>
        </div>
        <div class="feature-card">
          <div class="icon-wrapper icon-wrapper-warning">
            <Zap :size="22" :stroke-width="2" />
          </div>
          <h3>Quick Actions</h3>
          <p>Resolve, dismiss, or reject reports with one click</p>
        </div>
        <div class="feature-card">
          <div class="icon-wrapper icon-wrapper-success">
            <Smartphone :size="22" :stroke-width="2" />
          </div>
          <h3>Responsive</h3>
          <p>Works perfectly on desktop, tablet, and mobile</p>
        </div>
      </div>
    </section>

    <!-- Tech Stack -->
    <section class="section">
      <div class="section-header">
        <div class="icon-wrapper icon-wrapper-lg icon-wrapper-orange">
          <Wrench :size="24" :stroke-width="2" />
        </div>
        <h2>Tech Stack</h2>
      </div>
      <div class="tech-grid">
        <div class="tech-card" v-for="tech in techs" :key="tech.name">
          <div :class="['icon-wrapper', tech.iconClass]">
            <component :is="tech.icon" :size="20" :stroke-width="2" />
          </div>
          <h4>{{ tech.name }}</h4>
          <p>{{ tech.desc }}</p>
        </div>
      </div>
    </section>

    <!-- System Info -->
    <section class="section">
      <div class="section-header">
        <div class="icon-wrapper icon-wrapper-lg icon-wrapper-teal">
          <ClipboardList :size="24" :stroke-width="2" />
        </div>
        <h2>System Info</h2>
      </div>
      <div class="info-cards">
        <div class="info-card" v-for="info in systemInfo" :key="info.label">
          <div class="info-icon-wrap">
            <component :is="info.icon" :size="18" :stroke-width="2" />
          </div>
          <div>
            <div class="info-label">{{ info.label }}</div>
            <div class="info-value">{{ info.value }}</div>
          </div>
        </div>
      </div>
    </section>

    <!-- Design System Colors -->
    <section class="section">
      <div class="section-header">
        <div class="icon-wrapper icon-wrapper-lg icon-wrapper-pink">
          <Palette :size="24" :stroke-width="2" />
        </div>
        <h2>Color Palette</h2>
      </div>
      <div class="colors-grid">
        <div class="color-card" v-for="c in colors" :key="c.name">
          <div class="color-sample" :style="{ background: c.gradient }"></div>
          <div class="color-info">
            <strong>{{ c.name }}</strong>
            <code>{{ c.hex }}</code>
          </div>
        </div>
      </div>
    </section>

    <!-- Team -->
    <section class="section">
      <div class="section-header">
        <div class="icon-wrapper icon-wrapper-lg icon-wrapper-teal">
          <UsersIcon :size="24" :stroke-width="2" />
        </div>
        <h2>Team</h2>
      </div>
      <div class="team-card">
        <div class="team-header">
          <GraduationCap :size="28" :stroke-width="1.5" />
          <h3>CP25SSI2 — Chat2Date</h3>
          <p>School of IT, KMUTT</p>
        </div>
        <div class="team-content">
          <p>Capstone Project for Computer Science students at King Mongkut's University of Technology Thonburi.</p>
          <div class="team-details">
            <div class="team-detail-item">
              <Layers :size="15" :stroke-width="2" />
              <span><strong>Project:</strong> Chat2Date Dating Platform</span>
            </div>
            <div class="team-detail-item">
              <BookOpen :size="15" :stroke-width="2" />
              <span><strong>Course:</strong> CP25SSI2 — Capstone II</span>
            </div>
            <div class="team-detail-item">
              <Calendar :size="15" :stroke-width="2" />
              <span><strong>Year:</strong> 2024–2025</span>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- Links -->
    <section class="section">
      <div class="section-header">
        <div class="icon-wrapper icon-wrapper-lg icon-wrapper-purple">
          <BookOpen :size="24" :stroke-width="2" />
        </div>
        <h2>Quick Links</h2>
      </div>
      <div class="links-grid">
        <a href="http://cp25ssi2.sit.kmutt.ac.th/api/v1/swagger-ui.html" target="_blank" class="link-card">
          <div class="icon-wrapper icon-wrapper-brand"><FileText :size="20" :stroke-width="2" /></div>
          <div class="link-content">
            <h4>API Docs</h4>
            <p>Swagger / OpenAPI</p>
          </div>
          <ChevronRight :size="18" class="link-arrow" />
        </a>
        <a href="https://github.com" target="_blank" class="link-card">
          <div class="icon-wrapper icon-wrapper-purple"><ExternalLink :size="20" :stroke-width="2" /></div>
          <div class="link-content">
            <h4>GitHub</h4>
            <p>Source Code</p>
          </div>
          <ChevronRight :size="18" class="link-arrow" />
        </a>
        <router-link to="/" class="link-card">
          <div class="icon-wrapper icon-wrapper-warning"><BarChart3 :size="20" :stroke-width="2" /></div>
          <div class="link-content">
            <h4>Reports</h4>
            <p>Manage Reports</p>
          </div>
          <ChevronRight :size="18" class="link-arrow" />
        </router-link>
        <router-link to="/users" class="link-card">
          <div class="icon-wrapper icon-wrapper-teal"><UsersIcon :size="20" :stroke-width="2" /></div>
          <div class="link-content">
            <h4>Users</h4>
            <p>User Management</p>
          </div>
          <ChevronRight :size="18" class="link-arrow" />
        </router-link>
      </div>
    </section>

    <!-- Footer -->
    <div class="about-footer">
      <p>
        Built with <Heart :size="13" :stroke-width="2" class="heart-inline" /> using Vue.js 3
      </p>
      <p class="text-muted" style="font-size: 0.75rem">Updated Feb 2025</p>
    </div>
  </div>
</template>

<script setup>
import { markRaw } from 'vue'
import {
  MessageCircleHeart, Tag, Sparkles, BarChart3, Search,
  Users as UsersIcon, ImageIcon, Zap, Smartphone, Wrench,
  Palette, Map as MapIcon, Store, Settings, Coffee,
  ClipboardList, Globe, Code, Terminal, Package as PackageIcon,
  BookOpen, FileText, ExternalLink, ChevronRight, Heart,
  GraduationCap, Layers, Calendar
} from 'lucide-vue-next'

const techs = [
  { name: 'Vue.js 3', desc: 'Frontend Framework', icon: markRaw(Zap), iconClass: 'icon-wrapper-success' },
  { name: 'CSS3', desc: 'Modern Styling', icon: markRaw(Palette), iconClass: 'icon-wrapper-pink' },
  { name: 'Vue Router', desc: 'Routing', icon: markRaw(MapIcon), iconClass: 'icon-wrapper-brand' },
  { name: 'Pinia', desc: 'State Mgmt', icon: markRaw(Store), iconClass: 'icon-wrapper-warning' },
  { name: 'Vite', desc: 'Build Tool', icon: markRaw(Settings), iconClass: 'icon-wrapper-purple' },
  { name: 'Spring Boot', desc: 'Backend API', icon: markRaw(Coffee), iconClass: 'icon-wrapper-orange' },
]

const systemInfo = [
  { label: 'Backend', value: 'cp25ssi2.sit.kmutt.ac.th', icon: markRaw(Globe) },
  { label: 'Framework', value: 'Vue.js 3.5', icon: markRaw(Code) },
  { label: 'Node.js', value: '>=22.12.0', icon: markRaw(Terminal) },
  { label: 'Build', value: 'Vite 7', icon: markRaw(PackageIcon) },
]

const colors = [
  { name: 'Primary', hex: '#60D4FF', gradient: 'linear-gradient(135deg, #60d4ff, #38c8ff)' },
  { name: 'Secondary', hex: '#7CFFB2', gradient: 'linear-gradient(135deg, #7cffb2, #4dff94)' },
  { name: 'Accent', hex: '#4DD8E6', gradient: 'linear-gradient(135deg, #4dd8e6, #3cccd9)' },
  { name: 'Success', hex: '#4ADE80', gradient: 'linear-gradient(135deg, #4ade80, #22c55e)' },
  { name: 'Warning', hex: '#FBBF24', gradient: 'linear-gradient(135deg, #fbbf24, #f59e0b)' },
  { name: 'Error', hex: '#F87171', gradient: 'linear-gradient(135deg, #f87171, #ef4444)' },
]
</script>

<style scoped>
.about-view {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2.5rem 2rem;
}

/* Hero */
.hero {
  position: relative;
  border-radius: var(--radius-2xl);
  padding: 4rem 2rem;
  text-align: center;
  margin-bottom: 3rem;
  overflow: hidden;
  background: linear-gradient(135deg, rgba(96, 212, 255, 0.08) 0%, rgba(77, 216, 230, 0.04) 50%, rgba(124, 255, 178, 0.03) 100%);
  border: 1px solid var(--glass-border);
  box-shadow: var(--shadow-lg), var(--shadow-brand);
}
.hero-bg {
  position: absolute;
  inset: 0;
  background:
    radial-gradient(ellipse 60% 40% at 20% 50%, rgba(96, 212, 255, 0.12) 0%, transparent 70%),
    radial-gradient(ellipse 50% 50% at 80% 30%, rgba(77, 216, 230, 0.08) 0%, transparent 60%);
  animation: meshShift 15s ease-in-out infinite alternate;
}
@keyframes meshShift {
  0% { opacity: 0.6; transform: scale(1); }
  100% { opacity: 1; transform: scale(1.05); }
}
.hero-content { position: relative; z-index: 1; }
.hero-icon-wrap {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 88px;
  height: 88px;
  border-radius: var(--radius-2xl);
  background: rgba(96, 212, 255, 0.1);
  border: 1px solid rgba(96, 212, 255, 0.2);
  margin-bottom: 1.5rem;
  color: var(--brand-primary);
  animation: float 3s ease-in-out infinite;
  box-shadow: 0 0 30px rgba(96, 212, 255, 0.15);
}
@keyframes float {
  0%, 100% { transform: translateY(0); }
  50% { transform: translateY(-8px); }
}
.hero h1 {
  font-size: 2.5rem;
  margin-bottom: 0.75rem;
  letter-spacing: -0.03em;
  background: linear-gradient(135deg, var(--text-primary) 0%, var(--brand-primary) 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}
.hero-subtitle {
  font-size: 1rem;
  color: var(--text-muted);
  max-width: 520px;
  margin: 0 auto 1.5rem;
  line-height: 1.6;
}
.version-badge {
  display: inline-flex;
  align-items: center;
  gap: 0.375rem;
  padding: 0.375rem 1rem;
  background: rgba(96, 212, 255, 0.06);
  border: 1px solid rgba(96, 212, 255, 0.15);
  border-radius: var(--radius-full);
  font-weight: 600;
  font-size: 0.8125rem;
  color: var(--brand-primary);
  font-family: 'JetBrains Mono', monospace;
}

/* Section */
.section { margin-bottom: 3.5rem; }
.section-header {
  display: flex;
  align-items: center;
  gap: 0.875rem;
  margin-bottom: 1.75rem;
  justify-content: center;
}
.section-header h2 { margin: 0; font-size: 1.5rem; }

/* Features */
.features-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 1rem;
}
.feature-card {
  background: var(--glass-bg);
  backdrop-filter: var(--glass-blur);
  padding: 1.75rem 1.5rem;
  border-radius: var(--radius-xl);
  border: 1px solid var(--glass-border);
  transition: all var(--transition-base);
  text-align: center;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.625rem;
}
.feature-card:hover {
  transform: translateY(-4px);
  border-color: var(--glass-border-hover);
  box-shadow: var(--shadow-md), var(--shadow-glow-sm);
}
.feature-card h3 { color: var(--text-primary); margin: 0; font-size: 1rem; }
.feature-card p { color: var(--text-muted); font-size: 0.8125rem; line-height: 1.5; margin: 0; }

/* Tech */
.tech-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
  gap: 0.875rem;
}
.tech-card {
  background: var(--glass-bg);
  backdrop-filter: var(--glass-blur);
  padding: 1.25rem;
  border-radius: var(--radius-xl);
  border: 1px solid var(--glass-border);
  text-align: center;
  transition: all var(--transition-base);
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.5rem;
}
.tech-card:hover {
  transform: translateY(-3px);
  border-color: var(--glass-border-hover);
  box-shadow: var(--shadow-sm);
}
.tech-card h4 { color: var(--text-primary); margin: 0; font-size: 0.9375rem; }
.tech-card p { color: var(--text-muted); font-size: 0.75rem; margin: 0; }

/* Info */
.info-cards {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
  gap: 0.875rem;
}
.info-card {
  background: var(--glass-bg);
  backdrop-filter: var(--glass-blur);
  padding: 1rem 1.25rem;
  border-radius: var(--radius-xl);
  border: 1px solid var(--glass-border);
  display: flex;
  align-items: center;
  gap: 0.875rem;
  transition: all var(--transition-base);
}
.info-card:hover { border-color: var(--glass-border-hover); box-shadow: var(--shadow-sm); }
.info-icon-wrap {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 36px;
  height: 36px;
  border-radius: var(--radius-md);
  background: linear-gradient(135deg, rgba(96, 212, 255, 0.12) 0%, rgba(77, 216, 230, 0.06) 100%);
  color: var(--brand-primary);
  flex-shrink: 0;
}
.info-label {
  font-size: 0.6875rem;
  color: var(--text-muted);
  text-transform: uppercase;
  letter-spacing: 0.06em;
  margin-bottom: 0.125rem;
  font-weight: 600;
}
.info-value {
  font-size: 0.9375rem;
  font-weight: 600;
  color: var(--text-primary);
  font-family: 'JetBrains Mono', monospace;
}

/* Colors */
.colors-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(140px, 1fr));
  gap: 0.875rem;
}
.color-card {
  background: var(--glass-bg);
  border-radius: var(--radius-xl);
  overflow: hidden;
  border: 1px solid var(--glass-border);
  transition: all var(--transition-base);
}
.color-card:hover { transform: translateY(-3px); border-color: var(--glass-border-hover); box-shadow: var(--shadow-sm); }
.color-sample { height: 60px; width: 100%; }
.color-info { padding: 0.75rem; text-align: center; }
.color-info strong { display: block; color: var(--text-primary); margin-bottom: 0.125rem; font-size: 0.8125rem; }
.color-info code { font-size: 0.75rem; color: var(--text-muted); }

/* Team */
.team-card {
  background: var(--glass-bg);
  backdrop-filter: var(--glass-blur);
  border-radius: var(--radius-xl);
  border: 1px solid var(--glass-border);
  overflow: hidden;
}
.team-header {
  background: linear-gradient(135deg, rgba(96, 212, 255, 0.1) 0%, rgba(77, 216, 230, 0.05) 100%);
  padding: 2rem;
  text-align: center;
  border-bottom: 1px solid var(--glass-border);
  color: var(--brand-primary);
}
.team-header h3 { color: var(--text-primary); margin-bottom: 0.375rem; font-size: 1.25rem; }
.team-header p { color: var(--text-muted); font-size: 0.875rem; margin: 0; }
.team-content { padding: 1.5rem; }
.team-content > p { color: var(--text-secondary); line-height: 1.7; margin-bottom: 1.25rem; font-size: 0.9rem; }
.team-details { display: flex; flex-direction: column; gap: 0.5rem; }
.team-detail-item {
  display: flex;
  align-items: center;
  gap: 0.625rem;
  padding: 0.625rem 0.875rem;
  background: var(--bg-surface-muted);
  border-radius: var(--radius-lg);
  border: 1px solid var(--glass-border);
  color: var(--text-secondary);
  font-size: 0.875rem;
}

/* Links */
.links-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
  gap: 0.875rem;
}
.link-card {
  display: flex;
  align-items: center;
  gap: 0.875rem;
  background: var(--glass-bg);
  backdrop-filter: var(--glass-blur);
  padding: 1rem 1.25rem;
  border-radius: var(--radius-xl);
  border: 1px solid var(--glass-border);
  text-decoration: none;
  transition: all var(--transition-base);
}
.link-card:hover {
  transform: translateX(4px);
  border-color: var(--glass-border-hover);
  box-shadow: var(--shadow-sm), var(--shadow-glow-sm);
}
.link-content { flex: 1; }
.link-content h4 { color: var(--text-primary); margin: 0 0 0.125rem; font-size: 0.875rem; }
.link-content p { color: var(--text-muted); font-size: 0.75rem; margin: 0; }
.link-arrow {
  color: var(--text-muted);
  flex-shrink: 0;
  transition: all var(--transition-base);
}
.link-card:hover .link-arrow {
  color: var(--brand-primary);
  transform: translateX(4px);
}

/* Footer */
.about-footer {
  text-align: center;
  padding: 2.5rem;
  background: var(--glass-bg);
  backdrop-filter: var(--glass-blur);
  border-radius: var(--radius-xl);
  border: 1px solid var(--glass-border);
  margin-top: 1rem;
}
.about-footer p {
  margin-bottom: 0.375rem;
  color: var(--text-secondary);
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.375rem;
  font-size: 0.875rem;
}
.heart-inline {
  color: var(--color-error);
  animation: heartbeat 1.5s ease-in-out infinite;
}
@keyframes heartbeat {
  0%, 100% { transform: scale(1); }
  10%, 30% { transform: scale(1.15); }
  20%, 40% { transform: scale(1.05); }
}

/* Responsive */
@media (max-width: 768px) {
  .about-view { padding: 1.5rem 1rem; }
  .hero { padding: 3rem 1.5rem; border-radius: var(--radius-xl); }
  .hero h1 { font-size: 1.875rem; }
  .hero-icon-wrap { width: 68px; height: 68px; }
  .section-header { justify-content: flex-start; }
  .section-header h2 { font-size: 1.25rem; }
  .features-grid, .tech-grid, .colors-grid, .links-grid, .info-cards { grid-template-columns: 1fr; }
}

@media (min-width: 769px) and (max-width: 1024px) {
  .features-grid { grid-template-columns: repeat(2, 1fr); }
}
</style>
