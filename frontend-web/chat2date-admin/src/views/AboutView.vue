<template>
  <div class="about-view">
    <!-- Hero Section -->
    <div class="hero">
      <div class="hero-content">
        <div class="hero-icon">💬</div>
        <h1>Chat2Date Admin Dashboard</h1>
        <p class="hero-subtitle">
          Comprehensive administrative interface for managing user reports and moderation
        </p>
        <div class="version-badge">Version 1.0.0</div>
      </div>
    </div>

    <!-- Features Section -->
    <section class="section">
      <h2 class="section-title">✨ Key Features</h2>
      <div class="features-grid">
        <div class="feature-card">
          <div class="feature-icon">📊</div>
          <h3>Report Management</h3>
          <p>View, filter, and manage all user reports with detailed information and evidence</p>
        </div>
        <div class="feature-card">
          <div class="feature-icon">🔍</div>
          <h3>Advanced Filtering</h3>
          <p>Filter reports by status, sort by date or ID, and paginate through large datasets</p>
        </div>
        <div class="feature-card">
          <div class="feature-icon">👥</div>
          <h3>User Information</h3>
          <p>Access comprehensive user profiles including behavior scores and account status</p>
        </div>
        <div class="feature-card">
          <div class="feature-icon">🖼️</div>
          <h3>Evidence Review</h3>
          <p>View and review evidence files submitted with reports (images and videos)</p>
        </div>
        <div class="feature-card">
          <div class="feature-icon">⚡</div>
          <h3>Quick Actions</h3>
          <p>Resolve, dismiss, or reject reports with a single click</p>
        </div>
        <div class="feature-card">
          <div class="feature-icon">📱</div>
          <h3>Responsive Design</h3>
          <p>Mobile-friendly interface that works seamlessly on all devices</p>
        </div>
      </div>
    </section>

    <!-- Tech Stack Section -->
    <section class="section">
      <h2 class="section-title">🛠️ Technology Stack</h2>
      <div class="tech-grid">
        <div class="tech-card">
          <div class="tech-logo">⚡</div>
          <h4>Vue.js 3</h4>
          <p>Progressive JavaScript Framework</p>
        </div>
        <div class="tech-card">
          <div class="tech-logo">🎨</div>
          <h4>CSS3</h4>
          <p>Modern Styling</p>
        </div>
        <div class="tech-card">
          <div class="tech-logo">🗺️</div>
          <h4>Vue Router</h4>
          <p>Official Routing</p>
        </div>
        <div class="tech-card">
          <div class="tech-logo">🍍</div>
          <h4>Pinia</h4>
          <p>State Management</p>
        </div>
        <div class="tech-card">
          <div class="tech-logo">⚙️</div>
          <h4>Vite</h4>
          <p>Build Tool</p>
        </div>
        <div class="tech-card">
          <div class="tech-logo">☕</div>
          <h4>Java Spring</h4>
          <p>Backend API</p>
        </div>
      </div>
    </section>

    <!-- System Info Section -->
    <section class="section">
      <h2 class="section-title">📋 System Information</h2>
      <div class="info-cards">
        <div class="info-card">
          <div class="info-label">Backend API</div>
          <div class="info-value">cp25ssi2.sit.kmutt.ac.th</div>
        </div>
        <div class="info-card">
          <div class="info-label">Framework</div>
          <div class="info-value">Vue.js 3.5.22</div>
        </div>
        <div class="info-card">
          <div class="info-label">Node Version</div>
          <div class="info-value">^20.19.0 || >=22.12.0</div>
        </div>
        <div class="info-card">
          <div class="info-label">Build Tool</div>
          <div class="info-value">Vite 7.1.7</div>
        </div>
      </div>
    </section>

    <!-- Color Palette Section -->
    <section class="section">
      <h2 class="section-title">🎨 Design System</h2>
      <p class="section-description">
        The dashboard follows Chat2Date's brand guidelines with a modern, accessible color palette
      </p>
      <div class="colors-grid">
        <div class="color-card">
          <div class="color-sample primary"></div>
          <div class="color-info">
            <strong>Primary</strong>
            <code>#78CEFF</code>
          </div>
        </div>
        <div class="color-card">
          <div class="color-sample secondary"></div>
          <div class="color-info">
            <strong>Secondary</strong>
            <code>#98FB98</code>
          </div>
        </div>
        <div class="color-card">
          <div class="color-sample accent"></div>
          <div class="color-info">
            <strong>Accent</strong>
            <code>#5CE1E6</code>
          </div>
        </div>
        <div class="color-card">
          <div class="color-sample success"></div>
          <div class="color-info">
            <strong>Success</strong>
            <code>#9FE2BF</code>
          </div>
        </div>
        <div class="color-card">
          <div class="color-sample warning"></div>
          <div class="color-info">
            <strong>Warning</strong>
            <code>#FFD166</code>
          </div>
        </div>
        <div class="color-card">
          <div class="color-sample error"></div>
          <div class="color-info">
            <strong>Error</strong>
            <code>#FF6B6B</code>
          </div>
        </div>
      </div>
    </section>

    <!-- Team Section -->
    <section class="section">
      <h2 class="section-title">👥 Development Team</h2>
      <div class="team-card">
        <div class="team-header">
          <h3>CP25SSI2 - Chat2Date Team</h3>
          <p>School of Information Technology, KMUTT</p>
        </div>
        <div class="team-content">
          <p>
            This project is developed as part of the Capstone Project for Computer Science
            students at King Mongkut's University of Technology Thonburi.
          </p>
          <p>
            <strong>Project:</strong> Chat2Date - A Modern Dating Application Platform
          </p>
          <p>
            <strong>Course:</strong> CP25SSI2 - Capstone Project II
          </p>
          <p>
            <strong>Year:</strong> 2024-2025
          </p>
        </div>
      </div>
    </section>

    <!-- API Documentation -->
    <section class="section">
      <h2 class="section-title">📚 Quick Links</h2>
      <div class="links-grid">
        <a
          href="http://cp25ssi2.sit.kmutt.ac.th/api/swagger-ui.html"
          target="_blank"
          class="link-card"
        >
          <div class="link-icon">📖</div>
          <div class="link-content">
            <h4>API Documentation</h4>
            <p>Swagger/OpenAPI Docs</p>
          </div>
          <div class="link-arrow">→</div>
        </a>
        <a href="https://github.com" target="_blank" class="link-card">
          <div class="link-icon">🔗</div>
          <div class="link-content">
            <h4>GitHub Repository</h4>
            <p>View Source Code</p>
          </div>
          <div class="link-arrow">→</div>
        </a>
        <a href="/" class="link-card">
          <div class="link-icon">📊</div>
          <div class="link-content">
            <h4>Reports Dashboard</h4>
            <p>Manage User Reports</p>
          </div>
          <div class="link-arrow">→</div>
        </a>
        <a href="/users" class="link-card">
          <div class="link-icon">👥</div>
          <div class="link-content">
            <h4>User Management</h4>
            <p>View All Users</p>
          </div>
          <div class="link-arrow">→</div>
        </a>
      </div>
    </section>

    <!-- Footer Info -->
    <div class="about-footer">
      <p>
        Built with ❤️ using Vue.js 3 and modern web technologies
      </p>
      <p class="text-muted">
        Last Updated: January 2025
      </p>
    </div>
  </div>
</template>

<script setup>
// No script needed for static about page
</script>

<style scoped>
.about-view {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
}

/* Hero Section */
.hero {
  background: linear-gradient(135deg, var(--brand-primary) 0%, var(--btn-primary) 100%);
  border-radius: var(--radius-xl);
  padding: 4rem 2rem;
  text-align: center;
  margin-bottom: 3rem;
  box-shadow: var(--shadow-xl);
  position: relative;
  overflow: hidden;
}

.hero::before {
  content: '';
  position: absolute;
  top: -50%;
  right: -50%;
  width: 200%;
  height: 200%;
  background: radial-gradient(circle, rgba(255, 255, 255, 0.1) 0%, transparent 70%);
  animation: pulse-wave 15s ease-in-out infinite;
}

@keyframes pulse-wave {
  0%,
  100% {
    transform: scale(1);
    opacity: 0.5;
  }
  50% {
    transform: scale(1.1);
    opacity: 0.8;
  }
}

.hero-content {
  position: relative;
  z-index: 1;
}

.hero-icon {
  font-size: 4rem;
  margin-bottom: 1rem;
  animation: bounce 2s ease-in-out infinite;
}

@keyframes bounce {
  0%,
  100% {
    transform: translateY(0);
  }
  50% {
    transform: translateY(-10px);
  }
}

.hero h1 {
  font-size: 3rem;
  margin-bottom: 1rem;
  color: var(--text-primary);
  text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.1);
}

.hero-subtitle {
  font-size: 1.25rem;
  color: var(--text-secondary);
  max-width: 600px;
  margin: 0 auto 1.5rem;
}

.version-badge {
  display: inline-block;
  padding: 0.5rem 1.5rem;
  background: var(--bg-white);
  border-radius: var(--radius-full);
  font-weight: 600;
  color: var(--text-primary);
  box-shadow: var(--shadow-md);
}

/* Section */
.section {
  margin-bottom: 4rem;
}

.section-title {
  font-size: 2rem;
  margin-bottom: 1rem;
  color: var(--text-primary);
  text-align: center;
}

.section-description {
  text-align: center;
  color: var(--text-muted);
  max-width: 600px;
  margin: 0 auto 2rem;
}

/* Features Grid */
.features-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 1.5rem;
}

.feature-card {
  background: var(--bg-white);
  padding: 2rem;
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-md);
  transition: all 0.3s ease;
  text-align: center;
}

.feature-card:hover {
  transform: translateY(-5px);
  box-shadow: var(--shadow-xl);
}

.feature-icon {
  font-size: 3rem;
  margin-bottom: 1rem;
}

.feature-card h3 {
  color: var(--text-primary);
  margin-bottom: 0.75rem;
  font-size: 1.25rem;
}

.feature-card p {
  color: var(--text-muted);
  font-size: 0.95rem;
  line-height: 1.6;
}

/* Tech Grid */
.tech-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
  gap: 1rem;
}

.tech-card {
  background: var(--bg-white);
  padding: 1.5rem;
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-md);
  text-align: center;
  transition: all 0.3s ease;
}

.tech-card:hover {
  transform: translateY(-3px);
  box-shadow: var(--shadow-lg);
  background: linear-gradient(135deg, var(--brand-primary-200) 0%, var(--bg-white) 100%);
}

.tech-logo {
  font-size: 2.5rem;
  margin-bottom: 0.5rem;
}

.tech-card h4 {
  color: var(--text-primary);
  margin-bottom: 0.25rem;
  font-size: 1rem;
}

.tech-card p {
  color: var(--text-muted);
  font-size: 0.875rem;
  margin: 0;
}

/* Info Cards */
.info-cards {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 1rem;
}

.info-card {
  background: var(--bg-white);
  padding: 1.5rem;
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-md);
  border-left: 4px solid var(--brand-primary);
}

.info-label {
  font-size: 0.875rem;
  color: var(--text-muted);
  text-transform: uppercase;
  letter-spacing: 0.05em;
  margin-bottom: 0.5rem;
}

.info-value {
  font-size: 1.25rem;
  font-weight: 600;
  color: var(--text-primary);
  font-family: monospace;
}

/* Colors Grid */
.colors-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
  gap: 1rem;
}

.color-card {
  background: var(--bg-white);
  border-radius: var(--radius-lg);
  overflow: hidden;
  box-shadow: var(--shadow-md);
  transition: all 0.3s ease;
}

.color-card:hover {
  transform: translateY(-3px);
  box-shadow: var(--shadow-lg);
}

.color-sample {
  height: 80px;
  width: 100%;
}

.color-sample.primary {
  background-color: var(--brand-primary);
}
.color-sample.secondary {
  background-color: var(--brand-secondary);
}
.color-sample.accent {
  background-color: var(--btn-primary);
}
.color-sample.success {
  background-color: var(--color-success);
}
.color-sample.warning {
  background-color: var(--color-warning);
}
.color-sample.error {
  background-color: var(--color-error);
}

.color-info {
  padding: 1rem;
  text-align: center;
}

.color-info strong {
  display: block;
  color: var(--text-primary);
  margin-bottom: 0.25rem;
}

.color-info code {
  font-family: monospace;
  color: var(--text-muted);
  font-size: 0.875rem;
}

/* Team Card */
.team-card {
  background: var(--bg-white);
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-md);
  overflow: hidden;
}

.team-header {
  background: linear-gradient(135deg, var(--brand-primary) 0%, var(--btn-primary) 100%);
  padding: 2rem;
  text-align: center;
}

.team-header h3 {
  color: var(--text-primary);
  margin-bottom: 0.5rem;
  font-size: 1.75rem;
}

.team-header p {
  color: var(--text-secondary);
  font-size: 1rem;
  margin: 0;
}

.team-content {
  padding: 2rem;
}

.team-content p {
  color: var(--text-secondary);
  line-height: 1.8;
  margin-bottom: 1rem;
}

/* Links Grid */
.links-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 1rem;
}

.link-card {
  display: flex;
  align-items: center;
  gap: 1rem;
  background: var(--bg-white);
  padding: 1.5rem;
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-md);
  text-decoration: none;
  transition: all 0.3s ease;
}

.link-card:hover {
  transform: translateX(5px);
  box-shadow: var(--shadow-lg);
  background: linear-gradient(135deg, var(--brand-primary-200) 0%, var(--bg-white) 100%);
}

.link-icon {
  font-size: 2rem;
  flex-shrink: 0;
}

.link-content {
  flex: 1;
}

.link-content h4 {
  color: var(--text-primary);
  margin-bottom: 0.25rem;
  font-size: 1rem;
}

.link-content p {
  color: var(--text-muted);
  font-size: 0.875rem;
  margin: 0;
}

.link-arrow {
  font-size: 1.5rem;
  color: var(--brand-primary);
  flex-shrink: 0;
  transition: transform 0.3s ease;
}

.link-card:hover .link-arrow {
  transform: translateX(5px);
}

/* About Footer */
.about-footer {
  text-align: center;
  padding: 3rem 2rem;
  background: var(--bg-white);
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-md);
  margin-top: 3rem;
}

.about-footer p {
  margin-bottom: 0.5rem;
  color: var(--text-secondary);
}

/* Responsive */
@media (max-width: 768px) {
  .about-view {
    padding: 1rem;
  }

  .hero {
    padding: 3rem 1.5rem;
  }

  .hero h1 {
    font-size: 2rem;
  }

  .hero-subtitle {
    font-size: 1rem;
  }

  .section-title {
    font-size: 1.5rem;
  }

  .features-grid,
  .tech-grid,
  .colors-grid,
  .links-grid {
    grid-template-columns: 1fr;
  }

  .info-cards {
    grid-template-columns: 1fr;
  }
}
</style>
