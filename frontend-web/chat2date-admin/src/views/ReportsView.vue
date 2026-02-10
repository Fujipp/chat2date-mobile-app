<template>
  <div class="reports-view">
    <!-- Header -->
    <div class="header">
      <div class="header-text">
        <div class="header-title">
          <ClipboardList :size="36" :stroke-width="2" class="header-icon" />
          <div>
            <h1>Report Management</h1>
            <p class="text-muted">Manage and review user reports</p>
          </div>
        </div>
      </div>
      <div class="stats-summary">
        <div class="stat-card">
          <div class="stat-icon">
            <FileStack :size="24" :stroke-width="2" />
          </div>
          <div class="stat-content">
            <span class="stat-label">Total</span>
            <span class="stat-value">{{ totalReports }}</span>
          </div>
        </div>
        <div class="stat-card pending">
          <div class="stat-icon pending-icon">
            <Clock :size="24" :stroke-width="2" />
          </div>
          <div class="stat-content">
            <span class="stat-label">Pending</span>
            <span class="stat-value">{{ stats.pending }}</span>
          </div>
        </div>
        <div class="stat-card resolved">
          <div class="stat-icon resolved-icon">
            <CheckCircle :size="24" :stroke-width="2" />
          </div>
          <div class="stat-content">
            <span class="stat-label">Resolved</span>
            <span class="stat-value">{{ stats.resolved }}</span>
          </div>
        </div>
      </div>
    </div>

    <!-- Filters -->
    <div class="filters">
      <div class="filter-group">
        <label for="status-filter">
          <Filter :size="16" />
          Filter by Status:
        </label>
        <select id="status-filter" v-model="selectedStatus" @change="fetchReports">
          <option value="">All Status</option>
          <option value="PENDING">Pending</option>
          <option value="RESOLVED">Resolved</option>
          <option value="DISMISSED">Dismissed</option>
          <option value="REJECTED">Rejected</option>
        </select>
      </div>
      <div class="filter-group">
        <label for="sort-filter">
          <ArrowUpDown :size="16" />
          Sort by:
        </label>
        <select id="sort-filter" v-model="sortBy" @change="fetchReports">
          <option value="createdAt">Date Created</option>
          <option value="reportId">Report ID</option>
          <option value="status">Status</option>
        </select>
      </div>
      <div class="filter-group">
        <label for="direction-filter">
          <ListOrdered :size="16" />
          Order:
        </label>
        <select id="direction-filter" v-model="sortDirection" @change="fetchReports">
          <option value="DESC">Descending</option>
          <option value="ASC">Ascending</option>
        </select>
      </div>
      <button class="btn btn-primary" @click="fetchReports">
        <RotateCw :size="18" />
        Refresh
      </button>
    </div>

    <!-- Loading State -->
    <div v-if="loading" class="loading-container">
      <Loader2 :size="48" :stroke-width="2" class="spinner-icon" />
      <p>Loading reports...</p>
    </div>

    <!-- Error State -->
    <div v-else-if="error" class="error-message">
      <AlertTriangle :size="48" :stroke-width="2" class="error-icon" />
      <p>{{ error }}</p>
      <button class="btn btn-outline" @click="fetchReports">
        <RotateCw :size="18" />
        Try Again
      </button>
    </div>

    <!-- Reports Table -->
    <div v-else class="table-container">
      <table>
        <thead>
          <tr>
            <th><Hash :size="16" /> ID</th>
            <th><UserCircle :size="16" /> Reporter</th>
            <th><UserX :size="16" /> Target User</th>
            <th><Tag :size="16" /> Reason</th>
            <th><Badge :size="16" /> Status</th>
            <th><Calendar :size="16" /> Created At</th>
            <th><Settings :size="16" /> Actions</th>
          </tr>
        </thead>
        <tbody>
          <tr v-if="reports.length === 0">
            <td colspan="7" class="text-center text-muted">
              <div class="empty-state">
                <InboxIcon :size="48" :stroke-width="1.5" />
                <p>No reports found</p>
              </div>
            </td>
          </tr>
          <tr v-for="report in reports" :key="report.reportId">
            <td>
              <div class="id-cell">
                <Hash :size="14" />
                <strong>{{ report.reportId }}</strong>
              </div>
            </td>
            <td>
              <div class="user-cell">
                <UserCircle :size="16" class="user-icon" />
                <span class="user-id">{{ report.reporterId }}</span>
              </div>
            </td>
            <td>
              <div class="user-cell">
                <UserX :size="16" class="user-icon" />
                <span class="user-id">{{ report.targetUserId }}</span>
              </div>
            </td>
            <td>
              <span class="reason-badge">
                <AlertCircle :size="14" />
                {{ report.reason }}
              </span>
            </td>
            <td>
              <span :class="['badge', `badge-${report.status.toLowerCase()}`]">
                <component :is="getStatusIcon(report.status)" :size="14" />
                {{ report.status }}
              </span>
            </td>
            <td>
              <div class="date-cell">
                <Calendar :size="14" />
                {{ formatDate(report.createdAt) }}
              </div>
            </td>
            <td>
              <button class="btn-action btn-view" @click="viewReport(report.reportId)">
                <Eye :size="16" />
                View
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
        <ChevronLeft :size="18" />
        Previous
      </button>
      <span class="page-info">
        <FileText :size="16" />
        Page {{ currentPage + 1 }} of {{ totalPages }} ({{ totalReports }} total)
      </span>
      <button
        class="btn btn-outline"
        :disabled="currentPage >= totalPages - 1"
        @click="changePage(currentPage + 1)"
      >
        Next
        <ChevronRight :size="18" />
      </button>
    </div>

    <!-- Report Detail Modal -->
    <div v-if="selectedReport" class="modal-overlay" @click.self="closeModal">
      <div class="modal">
        <div class="modal-header">
          <div class="modal-title">
            <FileText :size="24" />
            <h2>Report Details #{{ selectedReport.reportId }}</h2>
          </div>
          <button class="btn-close" @click="closeModal">
            <X :size="24" />
          </button>
        </div>

        <div class="modal-body">
          <!-- Status Badge -->
          <div class="detail-section">
            <span :class="['badge', 'badge-large', `badge-${selectedReport.status.toLowerCase()}`]">
              <component :is="getStatusIcon(selectedReport.status)" :size="18" />
              {{ selectedReport.status }}
            </span>
            <span class="detail-date">
              <Clock :size="16" />
              {{ formatDate(selectedReport.createdAt) }}
            </span>
          </div>

          <!-- Reporter Info -->
          <div class="detail-section">
            <h3>
              <UserCircle :size="24" />
              Reporter Information
            </h3>
            <div v-if="selectedReport.reporter" class="user-info">
              <img
                v-if="selectedReport.reporter.profilePhotoUrl"
                :src="selectedReport.reporter.profilePhotoUrl"
                alt="Profile"
                class="user-avatar"
              />
              <div class="user-avatar-placeholder" v-else>
                <User :size="32" />
              </div>
              <div class="user-details">
                <p><UserCircle :size="16" /> <strong>User ID:</strong> {{ selectedReport.reporterId }}</p>
                <p><User :size="16" /> <strong>Name:</strong> {{ selectedReport.reporter.firstname }} {{ selectedReport.reporter.lastname }}</p>
                <p><AtSign :size="16" /> <strong>Nickname:</strong> {{ selectedReport.reporter.nickname }}</p>
                <p><Mail :size="16" /> <strong>Email:</strong> {{ selectedReport.reporter.email }}</p>
                <p><Phone :size="16" /> <strong>Phone:</strong> {{ selectedReport.reporter.phoneNumber }}</p>
                <p><Cake :size="16" /> <strong>Age:</strong> {{ selectedReport.reporter.age }} | <strong>Sex:</strong> {{ selectedReport.reporter.sex }}</p>
                <p><TrendingUp :size="16" /> <strong>Behavior Score:</strong> {{ selectedReport.reporter.behaviorScore }}</p>
                <p v-if="selectedReport.reporter.isBlacklist" class="text-error">
                  <AlertTriangle :size="16" /> <strong>BLACKLISTED</strong>
                </p>
              </div>
            </div>
            <p v-else class="text-muted">
              <Info :size="16" />
              Reporter information not available
            </p>
          </div>

          <div class="divider"></div>

          <!-- Target User Info -->
          <div class="detail-section">
            <h3>
              <UserX :size="24" />
              Target User Information
            </h3>
            <div v-if="selectedReport.targetUser" class="user-info">
              <img
                v-if="selectedReport.targetUser.profilePhotoUrl"
                :src="selectedReport.targetUser.profilePhotoUrl"
                alt="Profile"
                class="user-avatar"
              />
              <div class="user-avatar-placeholder" v-else>
                <User :size="32" />
              </div>
              <div class="user-details">
                <p><UserCircle :size="16" /> <strong>User ID:</strong> {{ selectedReport.targetUserId }}</p>
                <p><User :size="16" /> <strong>Name:</strong> {{ selectedReport.targetUser.firstname }} {{ selectedReport.targetUser.lastname }}</p>
                <p><AtSign :size="16" /> <strong>Nickname:</strong> {{ selectedReport.targetUser.nickname }}</p>
                <p><Mail :size="16" /> <strong>Email:</strong> {{ selectedReport.targetUser.email }}</p>
                <p><Phone :size="16" /> <strong>Phone:</strong> {{ selectedReport.targetUser.phoneNumber }}</p>
                <p><Cake :size="16" /> <strong>Age:</strong> {{ selectedReport.targetUser.age }} | <strong>Sex:</strong> {{ selectedReport.targetUser.sex }}</p>
                <p><TrendingUp :size="16" /> <strong>Behavior Score:</strong> {{ selectedReport.targetUser.behaviorScore }}</p>
                <p v-if="selectedReport.targetUser.isBlacklist" class="text-error">
                  <AlertTriangle :size="16" /> <strong>BLACKLISTED</strong>
                </p>
              </div>
            </div>
            <p v-else class="text-muted">
              <Info :size="16" />
              Target user information not available
            </p>
          </div>

          <div class="divider"></div>

          <!-- Report Details -->
          <div class="detail-section">
            <h3>
              <FileText :size="24" />
              Report Information
            </h3>
            <div class="report-info">
              <p>
                <Tag :size="16" />
                <strong>Reason:</strong>
                <span class="reason-badge">{{ selectedReport.reason }}</span>
              </p>
              <p v-if="selectedReport.anotherReason">
                <MessageSquare :size="16" />
                <strong>Additional Reason:</strong> {{ selectedReport.anotherReason }}
              </p>
              <p v-if="selectedReport.description">
                <AlignLeft :size="16" />
                <strong>Description:</strong><br />
                <span class="description-text">{{ selectedReport.description }}</span>
              </p>
              <p>
                <Bell :size="16" />
                <strong>Notified:</strong> {{ selectedReport.isNotified ? 'Yes' : 'No' }}
              </p>
            </div>
          </div>

          <!-- Evidence -->
          <div v-if="selectedReport.evidenceUrls && selectedReport.evidenceUrls.length > 0" class="detail-section">
            <h3>
              <ImageIcon :size="24" />
              Evidence ({{ selectedReport.evidenceUrls.length }})
            </h3>
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
                  <ZoomIn :size="32" />
                  <span>View Full Size</span>
                </div>
              </a>
            </div>
          </div>

          <!-- Update Status -->
          <div class="detail-section">
            <h3>
              <Settings :size="24" />
              Update Status
            </h3>
            <div class="status-actions">
              <button
                v-if="selectedReport.status !== 'RESOLVED'"
                class="btn btn-success"
                @click="updateStatus('RESOLVED')"
                :disabled="updatingStatus"
              >
                <CheckCircle :size="18" />
                Mark as Resolved
              </button>
              <button
                v-if="selectedReport.status !== 'DISMISSED'"
                class="btn btn-secondary"
                @click="updateStatus('DISMISSED')"
                :disabled="updatingStatus"
              >
                <XCircle :size="18" />
                Dismiss
              </button>
              <button
                v-if="selectedReport.status !== 'REJECTED'"
                class="btn btn-danger"
                @click="updateStatus('REJECTED')"
                :disabled="updatingStatus"
              >
                <Ban :size="18" />
                Reject
              </button>
              <button
                v-if="selectedReport.status !== 'PENDING'"
                class="btn btn-outline"
                @click="updateStatus('PENDING')"
                :disabled="updatingStatus"
              >
                <RotateCcw :size="18" />
                Back to Pending
              </button>
            </div>
            <p v-if="updateError" class="text-error mt-2">
              <AlertTriangle :size="16" />
              {{ updateError }}
            </p>
            <p v-if="updateSuccess" class="text-success mt-2">
              <CheckCircle :size="16" />
              {{ updateSuccess }}
            </p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import {
  ClipboardList,
  FileStack,
  Clock,
  CheckCircle,
  Filter,
  ArrowUpDown,
  ListOrdered,
  RotateCw,
  Loader2,
  AlertTriangle,
  Hash,
  UserCircle,
  UserX,
  Tag,
  Badge,
  Calendar,
  Settings,
  InboxIcon,
  Eye,
  ChevronLeft,
  ChevronRight,
  FileText,
  X,
  User,
  AtSign,
  Mail,
  Phone,
  Cake,
  TrendingUp,
  Info,
  MessageSquare,
  AlignLeft,
  Bell,
  ImageIcon,
  ZoomIn,
  XCircle,
  Ban,
  RotateCcw,
  AlertCircle
} from 'lucide-vue-next'

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

// Get status icon
const getStatusIcon = (status) => {
  const icons = {
    PENDING: Clock,
    RESOLVED: CheckCircle,
    DISMISSED: XCircle,
    REJECTED: Ban
  }
  return icons[status] || AlertCircle
}

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

.header-text {
  flex: 1;
}

.header-title {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.header-icon {
  color: var(--brand-primary);
  animation: slideInLeft 0.5s ease;
}

@keyframes slideInLeft {
  from {
    opacity: 0;
    transform: translateX(-20px);
  }
  to {
    opacity: 1;
    transform: translateX(0);
  }
}

.header h1 {
  margin: 0;
  color: var(--text-primary);
  animation: fadeIn 0.5s ease;
}

@keyframes fadeIn {
  from {
    opacity: 0;
  }
  to {
    opacity: 1;
  }
}

.stats-summary {
  display: flex;
  gap: 1rem;
  flex-wrap: wrap;
}

.stat-card {
  background: var(--bg-white);
  padding: 1.25rem 1.5rem;
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-md);
  display: flex;
  align-items: center;
  gap: 1rem;
  min-width: 140px;
  border-left: 4px solid var(--brand-primary);
  transition: all 0.3s ease;
  animation: slideInRight 0.5s ease;
}

@keyframes slideInRight {
  from {
    opacity: 0;
    transform: translateX(20px);
  }
  to {
    opacity: 1;
    transform: translateX(0);
  }
}

.stat-card:hover {
  transform: translateY(-4px);
  box-shadow: var(--shadow-lg);
}

.stat-card.pending {
  border-left-color: var(--color-warning);
}

.stat-card.resolved {
  border-left-color: var(--color-success);
}

.stat-icon {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 48px;
  height: 48px;
  border-radius: var(--radius-md);
  background: var(--brand-primary-200);
  color: var(--brand-primary);
}

.stat-icon.pending-icon {
  background: rgba(255, 209, 102, 0.2);
  color: var(--color-warning);
}

.stat-icon.resolved-icon {
  background: rgba(159, 226, 191, 0.2);
  color: var(--color-success);
}

.stat-content {
  display: flex;
  flex-direction: column;
}

.stat-label {
  font-size: 0.875rem;
  color: var(--text-muted);
  text-transform: uppercase;
  letter-spacing: 0.05em;
  font-weight: 500;
}

.stat-value {
  font-size: 2rem;
  font-weight: 700;
  color: var(--text-primary);
  line-height: 1;
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
  animation: fadeIn 0.5s ease 0.2s backwards;
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
  display: flex;
  align-items: center;
  gap: 0.5rem;
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

.spinner-icon {
  color: var(--brand-primary);
  animation: spin 1s linear infinite;
}

@keyframes spin {
  from {
    transform: rotate(0deg);
  }
  to {
    transform: rotate(360deg);
  }
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

.error-icon {
  color: var(--color-error);
}

.error-message p {
  color: var(--color-error);
  font-weight: 500;
}

/* Table */
.table-container {
  animation: fadeIn 0.5s ease 0.3s backwards;
}

table th {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.id-cell {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  color: var(--text-primary);
}

.user-cell {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.user-icon {
  color: var(--brand-primary);
  flex-shrink: 0;
}

.user-id {
  font-family: monospace;
  font-size: 0.875rem;
  color: var(--text-secondary);
}

.date-cell {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  color: var(--text-secondary);
}

.reason-badge {
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.35rem 0.75rem;
  background: var(--neutral-100);
  border-radius: var(--radius-md);
  font-size: 0.875rem;
  color: var(--text-secondary);
  font-weight: 500;
}

.empty-state {
  padding: 3rem;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 1rem;
  color: var(--text-muted);
}

.badge {
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
}

.btn-action {
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.5rem 1rem;
  border: none;
  border-radius: var(--radius-md);
  cursor: pointer;
  font-size: 0.875rem;
  font-weight: 500;
  transition: all 0.2s ease;
}

.btn-view {
  background: var(--brand-primary);
  color: var(--text-primary);
}

.btn-view:hover {
  background: var(--brand-primary-700);
  transform: translateY(-2px);
  box-shadow: var(--shadow-md);
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
  animation: fadeIn 0.5s ease 0.4s backwards;
}

.page-info {
  display: flex;
  align-items: center;
  gap: 0.5rem;
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
  background: rgba(15, 23, 42, 0.75);
  backdrop-filter: blur(4px);
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

.modal-title {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.modal-title h2 {
  margin: 0;
  color: var(--text-primary);
}

.btn-close {
  display: flex;
  align-items: center;
  justify-content: center;
  background: none;
  border: none;
  cursor: pointer;
  color: var(--text-muted);
  transition: all 0.2s ease;
  padding: 0.5rem;
  border-radius: var(--radius-md);
}

.btn-close:hover {
  color: var(--color-error);
  background: var(--bg-surface);
}

.modal-body {
  padding: 2rem;
}

.detail-section {
  margin-bottom: 2rem;
}

.detail-section h3 {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  color: var(--text-primary);
  margin-bottom: 1rem;
  font-size: 1.25rem;
}

.badge-large {
  font-size: 1rem;
  padding: 0.5rem 1rem;
}

.detail-date {
  display: flex;
  align-items: center;
  gap: 0.5rem;
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
  border: 1px solid var(--divider);
}

.user-avatar {
  width: 80px;
  height: 80px;
  border-radius: 50%;
  object-fit: cover;
  border: 3px solid var(--brand-primary);
  box-shadow: var(--shadow-md);
}

.user-avatar-placeholder {
  width: 80px;
  height: 80px;
  border-radius: 50%;
  background: linear-gradient(135deg, var(--brand-primary) 0%, var(--btn-primary) 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--text-primary);
  box-shadow: var(--shadow-md);
}

.user-details {
  flex: 1;
}

.user-details p {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-bottom: 0.75rem;
  color: var(--text-secondary);
}

/* Report Info */
.report-info {
  padding: 1.5rem;
  background: var(--bg-surface);
  border-radius: var(--radius-lg);
  border: 1px solid var(--divider);
}

.report-info p {
  display: flex;
  align-items: flex-start;
  gap: 0.5rem;
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
  border: 1px solid var(--divider);
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
  transition: transform 0.3s ease;
  box-shadow: var(--shadow-md);
  border: 2px solid var(--divider);
}

.evidence-item:hover {
  transform: scale(1.05);
  box-shadow: var(--shadow-lg);
  border-color: var(--brand-primary);
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
  background: rgba(0, 0, 0, 0.7);
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  opacity: 0;
  transition: opacity 0.3s ease;
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
    gap: 1.5rem;
  }

  .header-title {
    flex-direction: column;
    align-items: flex-start;
    gap: 0.5rem;
  }

  .stats-summary {
    width: 100%;
    flex-direction: column;
  }

  .stat-card {
    width: 100%;
  }

  .filters {
    flex-direction: column;
  }

  .filter-group {
    width: 100%;
  }

  .pagination {
    flex-direction: column;
    gap: 1rem;
  }

  .modal {
    margin: 0.5rem;
    max-height: calc(100vh - 1rem);
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
    overflow-x: auto;
  }

  th,
  td {
    padding: 0.5rem;
    font-size: 0.875rem;
  }
}
</style>
