<template>
  <div class="reports-view">
    <!-- Header -->
    <div class="header">
      <div>
        <h1>Report Management</h1>
        <p class="text-muted">Manage and review user reports</p>
      </div>
      <div class="stats-summary">
        <div class="stat-card">
          <span class="stat-label">Total</span>
          <span class="stat-value">{{ totalReports }}</span>
        </div>
        <div class="stat-card pending">
          <span class="stat-label">Pending</span>
          <span class="stat-value">{{ stats.pending }}</span>
        </div>
        <div class="stat-card resolved">
          <span class="stat-label">Resolved</span>
          <span class="stat-value">{{ stats.resolved }}</span>
        </div>
      </div>
    </div>

    <!-- Filters -->
    <div class="filters">
      <div class="filter-group">
        <label for="status-filter">Filter by Status:</label>
        <select id="status-filter" v-model="selectedStatus" @change="fetchReports">
          <option value="">All Status</option>
          <option value="PENDING">Pending</option>
          <option value="RESOLVED">Resolved</option>
          <option value="DISMISSED">Dismissed</option>
          <option value="REJECTED">Rejected</option>
        </select>
      </div>
      <div class="filter-group">
        <label for="sort-filter">Sort by:</label>
        <select id="sort-filter" v-model="sortBy" @change="fetchReports">
          <option value="createdAt">Date Created</option>
          <option value="reportId">Report ID</option>
          <option value="status">Status</option>
        </select>
      </div>
      <div class="filter-group">
        <label for="direction-filter">Order:</label>
        <select id="direction-filter" v-model="sortDirection" @change="fetchReports">
          <option value="DESC">Descending</option>
          <option value="ASC">Ascending</option>
        </select>
      </div>
      <button class="btn btn-primary" @click="fetchReports">
        <span>🔄</span> Refresh
      </button>
    </div>

    <!-- Loading State -->
    <div v-if="loading" class="loading-container">
      <div class="spinner"></div>
      <p>Loading reports...</p>
    </div>

    <!-- Error State -->
    <div v-else-if="error" class="error-message">
      <span>⚠️</span>
      <p>{{ error }}</p>
      <button class="btn btn-outline" @click="fetchReports">Try Again</button>
    </div>

    <!-- Reports Table -->
    <div v-else class="table-container">
      <table>
        <thead>
          <tr>
            <th>ID</th>
            <th>Reporter</th>
            <th>Target User</th>
            <th>Reason</th>
            <th>Status</th>
            <th>Created At</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          <tr v-if="reports.length === 0">
            <td colspan="7" class="text-center text-muted">No reports found</td>
          </tr>
          <tr v-for="report in reports" :key="report.reportId">
            <td><strong>#{{ report.reportId }}</strong></td>
            <td>
              <div class="user-cell">
                <span class="user-id">{{ report.reporterId }}</span>
              </div>
            </td>
            <td>
              <div class="user-cell">
                <span class="user-id">{{ report.targetUserId }}</span>
              </div>
            </td>
            <td>
              <span class="reason-badge">{{ report.reason }}</span>
            </td>
            <td>
              <span :class="['badge', `badge-${report.status.toLowerCase()}`]">
                {{ report.status }}
              </span>
            </td>
            <td>{{ formatDate(report.createdAt) }}</td>
            <td>
              <button class="btn-action btn-view" @click="viewReport(report.reportId)">
                👁️ View
              </button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- Pagination -->
    <div v-if="!loading && !error && totalPages > 0" class="pagination">
      <button
        class="btn btn-outline"
        :disabled="currentPage === 0"
        @click="changePage(currentPage - 1)"
      >
        ← Previous
      </button>
      <span class="page-info">
        Page {{ currentPage + 1 }} of {{ totalPages }} ({{ totalReports }} total)
      </span>
      <button
        class="btn btn-outline"
        :disabled="currentPage >= totalPages - 1"
        @click="changePage(currentPage + 1)"
      >
        Next →
      </button>
    </div>

    <!-- Report Detail Modal -->
    <div v-if="selectedReport" class="modal-overlay" @click.self="closeModal">
      <div class="modal">
        <div class="modal-header">
          <h2>Report Details #{{ selectedReport.reportId }}</h2>
          <button class="btn-close" @click="closeModal">✕</button>
        </div>

        <div class="modal-body">
          <!-- Status Badge -->
          <div class="detail-section">
            <span
              :class="['badge', 'badge-large', `badge-${selectedReport.status.toLowerCase()}`]"
            >
              {{ selectedReport.status }}
            </span>
            <span class="detail-date">{{ formatDate(selectedReport.createdAt) }}</span>
          </div>

          <!-- Reporter Info -->
          <div class="detail-section">
            <h3>Reporter Information</h3>
            <div v-if="selectedReport.reporter" class="user-info">
              <img
                v-if="selectedReport.reporter.profilePhotoUrl"
                :src="selectedReport.reporter.profilePhotoUrl"
                alt="Profile"
                class="user-avatar"
              />
              <div class="user-avatar-placeholder" v-else>
                {{ selectedReport.reporter.firstname?.[0] || '?' }}
              </div>
              <div class="user-details">
                <p><strong>User ID:</strong> {{ selectedReport.reporterId }}</p>
                <p><strong>Name:</strong> {{ selectedReport.reporter.firstname }} {{ selectedReport.reporter.lastname }}</p>
                <p><strong>Nickname:</strong> {{ selectedReport.reporter.nickname }}</p>
                <p><strong>Email:</strong> {{ selectedReport.reporter.email }}</p>
                <p><strong>Phone:</strong> {{ selectedReport.reporter.phoneNumber }}</p>
                <p><strong>Age:</strong> {{ selectedReport.reporter.age }} | <strong>Sex:</strong> {{ selectedReport.reporter.sex }}</p>
                <p><strong>Behavior Score:</strong> {{ selectedReport.reporter.behaviorScore }}</p>
                <p v-if="selectedReport.reporter.isBlacklist" class="text-error">
                  ⚠️ <strong>BLACKLISTED</strong>
                </p>
              </div>
            </div>
            <p v-else class="text-muted">Reporter information not available</p>
          </div>

          <div class="divider"></div>

          <!-- Target User Info -->
          <div class="detail-section">
            <h3>Target User Information</h3>
            <div v-if="selectedReport.targetUser" class="user-info">
              <img
                v-if="selectedReport.targetUser.profilePhotoUrl"
                :src="selectedReport.targetUser.profilePhotoUrl"
                alt="Profile"
                class="user-avatar"
              />
              <div class="user-avatar-placeholder" v-else>
                {{ selectedReport.targetUser.firstname?.[0] || '?' }}
              </div>
              <div class="user-details">
                <p><strong>User ID:</strong> {{ selectedReport.targetUserId }}</p>
                <p><strong>Name:</strong> {{ selectedReport.targetUser.firstname }} {{ selectedReport.targetUser.lastname }}</p>
                <p><strong>Nickname:</strong> {{ selectedReport.targetUser.nickname }}</p>
                <p><strong>Email:</strong> {{ selectedReport.targetUser.email }}</p>
                <p><strong>Phone:</strong> {{ selectedReport.targetUser.phoneNumber }}</p>
                <p><strong>Age:</strong> {{ selectedReport.targetUser.age }} | <strong>Sex:</strong> {{ selectedReport.targetUser.sex }}</p>
                <p><strong>Behavior Score:</strong> {{ selectedReport.targetUser.behaviorScore }}</p>
                <p v-if="selectedReport.targetUser.isBlacklist" class="text-error">
                  ⚠️ <strong>BLACKLISTED</strong>
                </p>
              </div>
            </div>
            <p v-else class="text-muted">Target user information not available</p>
          </div>

          <div class="divider"></div>

          <!-- Report Details -->
          <div class="detail-section">
            <h3>Report Information</h3>
            <div class="report-info">
              <p><strong>Reason:</strong> <span class="reason-badge">{{ selectedReport.reason }}</span></p>
              <p v-if="selectedReport.anotherReason">
                <strong>Additional Reason:</strong> {{ selectedReport.anotherReason }}
              </p>
              <p v-if="selectedReport.description">
                <strong>Description:</strong><br />
                <span class="description-text">{{ selectedReport.description }}</span>
              </p>
              <p><strong>Notified:</strong> {{ selectedReport.isNotified ? 'Yes' : 'No' }}</p>
            </div>
          </div>

          <!-- Evidence -->
          <div v-if="selectedReport.evidenceUrls && selectedReport.evidenceUrls.length > 0" class="detail-section">
            <h3>Evidence ({{ selectedReport.evidenceUrls.length }})</h3>
            <div class="evidence-grid">
              <a
                v-for="(url, index) in selectedReport.evidenceUrls"
                :key="index"
                :href="url"
                target="_blank"
                class="evidence-item"
              >
                <img :src="url" :alt="`Evidence ${index + 1}`" />
                <div class="evidence-overlay">
                  <span>🔍 View</span>
                </div>
              </a>
            </div>
          </div>

          <!-- Update Status -->
          <div class="detail-section">
            <h3>Update Status</h3>
            <div class="status-actions">
              <button
                v-if="selectedReport.status !== 'RESOLVED'"
                class="btn btn-success"
                @click="updateStatus('RESOLVED')"
                :disabled="updatingStatus"
              >
                ✓ Mark as Resolved
              </button>
              <button
                v-if="selectedReport.status !== 'DISMISSED'"
                class="btn btn-secondary"
                @click="updateStatus('DISMISSED')"
                :disabled="updatingStatus"
              >
                ✕ Dismiss
              </button>
              <button
                v-if="selectedReport.status !== 'REJECTED'"
                class="btn btn-danger"
                @click="updateStatus('REJECTED')"
                :disabled="updatingStatus"
              >
                🚫 Reject
              </button>
              <button
                v-if="selectedReport.status !== 'PENDING'"
                class="btn btn-outline"
                @click="updateStatus('PENDING')"
                :disabled="updatingStatus"
              >
                ↻ Back to Pending
              </button>
            </div>
            <p v-if="updateError" class="text-error mt-2">{{ updateError }}</p>
            <p v-if="updateSuccess" class="text-success mt-2">{{ updateSuccess }}</p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'

// API Configuration
const API_BASE_URL = 'http://cp25ssi2.sit.kmutt.ac.th/api/admin'

// State
const reports = ref([])
const selectedReport = ref(null)
const loading = ref(false)
const error = ref(null)
const currentPage = ref(0)
const pageSize = ref(20)
const totalPages = ref(0)
const totalReports = ref(0)
const selectedStatus = ref('')
const sortBy = ref('createdAt')
const sortDirection = ref('DESC')
const updatingStatus = ref(false)
const updateError = ref(null)
const updateSuccess = ref(null)

// Stats
const stats = computed(() => {
  const pending = reports.value.filter((r) => r.status === 'PENDING').length
  const resolved = reports.value.filter((r) => r.status === 'RESOLVED').length
  const dismissed = reports.value.filter((r) => r.status === 'DISMISSED').length
  const rejected = reports.value.filter((r) => r.status === 'REJECTED').length
  return { pending, resolved, dismissed, rejected }
})

// Fetch reports
const fetchReports = async () => {
  loading.value = true
  error.value = null

  try {
    const params = new URLSearchParams({
      page: currentPage.value.toString(),
      size: pageSize.value.toString(),
      sortBy: sortBy.value,
      sortDirection: sortDirection.value,
    })

    if (selectedStatus.value) {
      params.append('status', selectedStatus.value)
    }

    const response = await fetch(`${API_BASE_URL}/reports?${params}`, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
      },
    })

    if (!response.ok) {
      throw new Error(`Failed to fetch reports: ${response.status}`)
    }

    const data = await response.json()
    reports.value = data.content || []
    totalPages.value = data.totalPages || 0
    totalReports.value = data.totalElements || 0
  } catch (err) {
    error.value = err.message
    console.error('Error fetching reports:', err)
  } finally {
    loading.value = false
  }
}

// View report details
const viewReport = async (reportId) => {
  loading.value = true
  error.value = null

  try {
    const response = await fetch(`${API_BASE_URL}/reports/${reportId}`, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
      },
    })

    if (!response.ok) {
      throw new Error(`Failed to fetch report details: ${response.status}`)
    }

    selectedReport.value = await response.json()
    updateError.value = null
    updateSuccess.value = null
  } catch (err) {
    error.value = err.message
    console.error('Error fetching report details:', err)
  } finally {
    loading.value = false
  }
}

// Update report status
const updateStatus = async (newStatus) => {
  if (!selectedReport.value) return

  updatingStatus.value = true
  updateError.value = null
  updateSuccess.value = null

  try {
    const response = await fetch(
      `${API_BASE_URL}/reports/${selectedReport.value.reportId}/status`,
      {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ status: newStatus }),
      }
    )

    if (!response.ok) {
      throw new Error(`Failed to update status: ${response.status}`)
    }

    const updatedReport = await response.json()
    selectedReport.value.status = updatedReport.status
    updateSuccess.value = `Status updated to ${newStatus} successfully!`

    // Refresh the reports list
    setTimeout(() => {
      fetchReports()
    }, 1000)
  } catch (err) {
    updateError.value = err.message
    console.error('Error updating status:', err)
  } finally {
    updatingStatus.value = false
  }
}

// Close modal
const closeModal = () => {
  selectedReport.value = null
  updateError.value = null
  updateSuccess.value = null
}

// Change page
const changePage = (newPage) => {
  if (newPage >= 0 && newPage < totalPages.value) {
    currentPage.value = newPage
    fetchReports()
  }
}

// Format date
const formatDate = (dateString) => {
  if (!dateString) return 'N/A'
  const date = new Date(dateString)
  return date.toLocaleString('en-US', {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
  })
}

// Mount
onMounted(() => {
  fetchReports()
})
</script>

<style scoped>
.reports-view {
  padding: 2rem;
  max-width: 1400px;
  margin: 0 auto;
}

/* Header */
.header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 2rem;
  flex-wrap: wrap;
  gap: 1.5rem;
}

.header h1 {
  margin: 0;
  color: var(--text-primary);
}

.stats-summary {
  display: flex;
  gap: 1rem;
  flex-wrap: wrap;
}

.stat-card {
  background: var(--bg-white);
  padding: 1rem 1.5rem;
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-md);
  display: flex;
  flex-direction: column;
  align-items: center;
  min-width: 100px;
  border-left: 4px solid var(--brand-primary);
}

.stat-card.pending {
  border-left-color: var(--color-warning);
}

.stat-card.resolved {
  border-left-color: var(--color-success);
}

.stat-label {
  font-size: 0.875rem;
  color: var(--text-muted);
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.stat-value {
  font-size: 2rem;
  font-weight: 700;
  color: var(--text-primary);
  margin-top: 0.25rem;
}

/* Filters */
.filters {
  display: flex;
  gap: 1rem;
  margin-bottom: 2rem;
  padding: 1.5rem;
  background: var(--bg-white);
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-md);
  flex-wrap: wrap;
  align-items: flex-end;
}

.filter-group {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
  flex: 1;
  min-width: 150px;
}

.filter-group label {
  font-size: 0.875rem;
  font-weight: 500;
  color: var(--text-primary);
}

/* Loading & Error */
.loading-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 4rem;
  gap: 1rem;
}

.error-message {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 3rem;
  gap: 1rem;
  background: var(--bg-white);
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-md);
}

.error-message span {
  font-size: 3rem;
}

.error-message p {
  color: var(--color-error);
  font-weight: 500;
}

/* Table */
.user-cell {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.user-id {
  font-family: monospace;
  font-size: 0.875rem;
  color: var(--text-muted);
}

.reason-badge {
  display: inline-block;
  padding: 0.25rem 0.75rem;
  background: var(--neutral-100);
  border-radius: var(--radius-md);
  font-size: 0.875rem;
  color: var(--text-secondary);
}

.btn-action {
  padding: 0.5rem 1rem;
  border: none;
  border-radius: var(--radius-md);
  cursor: pointer;
  font-size: 0.875rem;
  transition: all 0.2s ease;
}

.btn-view {
  background: var(--brand-primary);
  color: var(--text-primary);
}

.btn-view:hover {
  background: var(--brand-primary-700);
  transform: translateY(-1px);
}

/* Pagination */
.pagination {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 1rem;
  margin-top: 2rem;
  padding: 1.5rem;
  background: var(--bg-white);
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-md);
}

.page-info {
  font-weight: 500;
  color: var(--text-primary);
}

/* Modal */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(15, 23, 42, 0.7);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  padding: 1rem;
  overflow-y: auto;
}

.modal {
  background: var(--bg-white);
  border-radius: var(--radius-xl);
  box-shadow: var(--shadow-xl);
  max-width: 900px;
  width: 100%;
  max-height: 90vh;
  overflow-y: auto;
  animation: slideUp 0.3s ease;
}

@keyframes slideUp {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1.5rem 2rem;
  border-bottom: 1px solid var(--divider);
  position: sticky;
  top: 0;
  background: var(--bg-white);
  z-index: 10;
}

.modal-header h2 {
  margin: 0;
  color: var(--text-primary);
}

.btn-close {
  background: none;
  border: none;
  font-size: 1.5rem;
  cursor: pointer;
  color: var(--text-muted);
  transition: color 0.2s ease;
  padding: 0.5rem;
}

.btn-close:hover {
  color: var(--color-error);
}

.modal-body {
  padding: 2rem;
}

.detail-section {
  margin-bottom: 2rem;
}

.detail-section h3 {
  color: var(--text-primary);
  margin-bottom: 1rem;
  font-size: 1.25rem;
}

.badge-large {
  font-size: 1rem;
  padding: 0.5rem 1rem;
}

.detail-date {
  margin-left: 1rem;
  color: var(--text-muted);
  font-size: 0.875rem;
}

.divider {
  height: 1px;
  background: var(--divider);
  margin: 2rem 0;
}

/* User Info */
.user-info {
  display: flex;
  gap: 1.5rem;
  padding: 1.5rem;
  background: var(--bg-surface);
  border-radius: var(--radius-lg);
}

.user-avatar {
  width: 80px;
  height: 80px;
  border-radius: 50%;
  object-fit: cover;
  border: 3px solid var(--brand-primary);
}

.user-avatar-placeholder {
  width: 80px;
  height: 80px;
  border-radius: 50%;
  background: var(--brand-primary);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 2rem;
  font-weight: 700;
  color: var(--text-primary);
}

.user-details {
  flex: 1;
}

.user-details p {
  margin-bottom: 0.5rem;
  color: var(--text-secondary);
}

/* Report Info */
.report-info {
  padding: 1.5rem;
  background: var(--bg-surface);
  border-radius: var(--radius-lg);
}

.report-info p {
  margin-bottom: 1rem;
}

.description-text {
  display: block;
  margin-top: 0.5rem;
  padding: 1rem;
  background: var(--bg-white);
  border-radius: var(--radius-md);
  color: var(--text-primary);
  white-space: pre-wrap;
  word-wrap: break-word;
}

/* Evidence Grid */
.evidence-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
  gap: 1rem;
}

.evidence-item {
  position: relative;
  aspect-ratio: 1;
  border-radius: var(--radius-lg);
  overflow: hidden;
  cursor: pointer;
  transition: transform 0.2s ease;
}

.evidence-item:hover {
  transform: scale(1.05);
}

.evidence-item img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.evidence-overlay {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  opacity: 0;
  transition: opacity 0.2s ease;
  color: white;
  font-weight: 500;
}

.evidence-item:hover .evidence-overlay {
  opacity: 1;
}

/* Status Actions */
.status-actions {
  display: flex;
  gap: 1rem;
  flex-wrap: wrap;
}

/* Responsive */
@media (max-width: 768px) {
  .reports-view {
    padding: 1rem;
  }

  .header {
    flex-direction: column;
    align-items: stretch;
  }

  .stats-summary {
    width: 100%;
  }

  .stat-card {
    flex: 1;
  }

  .filters {
    flex-direction: column;
  }

  .filter-group {
    width: 100%;
  }

  .modal {
    margin: 1rem;
    max-height: calc(100vh - 2rem);
  }

  .modal-body {
    padding: 1rem;
  }

  .user-info {
    flex-direction: column;
    align-items: center;
    text-align: center;
  }

  .evidence-grid {
    grid-template-columns: repeat(2, 1fr);
  }

  .status-actions {
    flex-direction: column;
  }

  .status-actions .btn {
    width: 100%;
  }

  .table-container {
    font-size: 0.875rem;
  }

  th,
  td {
    padding: 0.5rem;
  }
}
</style>
