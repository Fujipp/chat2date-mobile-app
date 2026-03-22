<template>
  <div class="reports-view">
    <!-- Header -->
    <div class="header">
      <div class="header-text">
        <div class="header-title">
          <div class="header-icon-wrap">
            <ClipboardList :size="28" :stroke-width="2" />
          </div>
          <div>
            <h1>Report Management</h1>
            <p class="text-muted" style="margin:0;font-size:0.9rem">Manage and review user reports</p>
          </div>
        </div>
      </div>
      <div class="stats-summary">
        <div class="stat-card stat-total">
          <div class="stat-icon">
            <FileStack :size="20" :stroke-width="2" />
          </div>
          <div class="stat-content">
            <span class="stat-label">Total</span>
            <span class="stat-value">{{ totalReports }}</span>
          </div>
        </div>
        <div class="stat-card stat-pending">
          <div class="stat-icon">
            <Clock :size="20" :stroke-width="2" />
          </div>
          <div class="stat-content">
            <span class="stat-label">Pending</span>
            <span class="stat-value">{{ stats.pending }}</span>
          </div>
        </div>
        <div class="stat-card stat-resolved">
          <div class="stat-icon">
            <CheckCircle :size="20" :stroke-width="2" />
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
          <Filter :size="14" />
          Status
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
          <ArrowUpDown :size="14" />
          Sort By
        </label>
        <select id="sort-filter" v-model="sortBy" @change="fetchReports">
          <option value="createdAt">Date Created</option>
          <option value="reportId">Report ID</option>
          <option value="status">Status</option>
        </select>
      </div>
      <div class="filter-group">
        <label for="direction-filter">
          <ListOrdered :size="14" />
          Order
        </label>
        <select id="direction-filter" v-model="sortDirection" @change="fetchReports">
          <option value="DESC">Newest First</option>
          <option value="ASC">Oldest First</option>
        </select>
      </div>
      <button class="btn btn-primary filter-btn" @click="fetchReports">
        <RotateCw :size="16" />
        Refresh
      </button>
    </div>

    <!-- Loading State -->
    <div v-if="loading" class="loading-container">
      <Loader2 :size="40" :stroke-width="2" class="spinner-icon" />
      <p>Loading reports...</p>
    </div>

    <!-- Error State -->
    <div v-else-if="error" class="error-message">
      <AlertTriangle :size="40" :stroke-width="2" class="error-icon" />
      <p>{{ error }}</p>
      <button class="btn btn-outline" @click="fetchReports">
        <RotateCw :size="16" />
        Try Again
      </button>
    </div>

    <!-- Reports Table -->
    <div v-else class="table-container">
      <table>
        <thead>
          <tr>
            <th><Hash :size="14" /> ID</th>
            <th><UserCircle :size="14" /> Reporter</th>
            <th><UserX :size="14" /> Target</th>
            <th><Tag :size="14" /> Reason</th>
            <th><Badge :size="14" /> Status</th>
            <th><Calendar :size="14" /> Date</th>
            <th><Settings :size="14" /> Actions</th>
          </tr>
        </thead>
        <tbody>
          <tr v-if="reports.length === 0">
            <td colspan="7" class="text-center text-muted">
              <div class="empty-state">
                <InboxIcon :size="40" :stroke-width="1.5" />
                <p>No reports found</p>
              </div>
            </td>
          </tr>
          <tr v-for="report in reports" :key="report.reportId">
            <td>
              <div class="id-cell">
                <strong class="mono">#{{ report.reportId }}</strong>
              </div>
            </td>
            <td>
              <div class="user-cell">
                <UserCircle :size="15" class="user-icon" />
                <span class="user-id mono">{{ report.reporterId }}</span>
              </div>
            </td>
            <td>
              <div class="user-cell">
                <UserX :size="15" class="user-icon target" />
                <span class="user-id mono">{{ report.targetUserId }}</span>
              </div>
            </td>
            <td>
              <span class="reason-badge">{{ report.reason }}</span>
            </td>
            <td>
              <span :class="['badge', `badge-${report.status.toLowerCase()}`]">
                <component :is="getStatusIcon(report.status)" :size="12" />
                {{ report.status }}
              </span>
            </td>
            <td>
              <span class="date-cell">{{ formatDate(report.createdAt) }}</span>
            </td>
            <td>
              <button class="btn-action" @click="viewReport(report.reportId)">
                <Eye :size="15" />
                View
              </button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- Pagination -->
    <div v-if="!loading && !error && totalPages > 0" class="pagination">
      <button class="btn btn-outline btn-sm" :disabled="currentPage === 0" @click="changePage(currentPage - 1)">
        <ChevronLeft :size="16" />
        Prev
      </button>
      <span class="page-info mono">
        {{ currentPage + 1 }} / {{ totalPages }}
        <span class="page-total">({{ totalReports }})</span>
      </span>
      <button class="btn btn-outline btn-sm" :disabled="currentPage >= totalPages - 1" @click="changePage(currentPage + 1)">
        Next
        <ChevronRight :size="16" />
      </button>
    </div>

    <!-- Report Detail Modal -->
    <div v-if="selectedReport" class="modal-overlay" @click.self="closeModal">
      <div class="modal">
        <div class="modal-header">
          <div class="modal-title">
            <FileText :size="22" />
            <h2>Report #{{ selectedReport.reportId }}</h2>
          </div>
          <button class="btn-close" @click="closeModal">
            <X :size="22" />
          </button>
        </div>

        <div class="modal-body">
          <!-- Status & Date -->
          <div class="detail-section detail-top">
            <span :class="['badge', 'badge-large', `badge-${selectedReport.status.toLowerCase()}`]">
              <component :is="getStatusIcon(selectedReport.status)" :size="16" />
              {{ selectedReport.status }}
            </span>
            <span class="detail-date">
              <Clock :size="14" />
              {{ formatDate(selectedReport.createdAt) }}
            </span>
          </div>

          <!-- Reporter -->
          <div class="detail-section">
            <h3><UserCircle :size="20" /> Reporter</h3>
            <div v-if="selectedReport.reporter" class="user-info">
              <img v-if="selectedReport.reporter.profilePhotoUrl" :src="selectedReport.reporter.profilePhotoUrl" alt="Profile" class="user-avatar" />
              <div class="user-avatar-placeholder" v-else><User :size="28" /></div>
              <div class="user-details">
                <p><strong>ID:</strong> <span class="mono">{{ selectedReport.reporterId }}</span></p>
                <p><strong>Name:</strong> {{ selectedReport.reporter.firstname }} {{ selectedReport.reporter.lastname }}</p>
                <p><strong>Nickname:</strong> {{ selectedReport.reporter.nickname }}</p>
                <p><strong>Email:</strong> {{ selectedReport.reporter.email }}</p>
                <p><strong>Phone:</strong> {{ selectedReport.reporter.phoneNumber }}</p>
                <p><strong>Age:</strong> {{ selectedReport.reporter.age }} · <strong>Sex:</strong> {{ selectedReport.reporter.sex }}</p>
                <p><strong>Score:</strong> {{ selectedReport.reporter.behaviorScore }}</p>
                <p v-if="selectedReport.reporter.isBlacklist" class="text-error"><AlertTriangle :size="14" /> BLACKLISTED</p>
              </div>
            </div>
            <p v-else class="text-muted"><Info :size="14" /> Not available</p>
          </div>

          <div class="divider"></div>

          <!-- Target -->
          <div class="detail-section">
            <h3><UserX :size="20" /> Target User</h3>
            <div v-if="selectedReport.targetUser" class="user-info">
              <img v-if="selectedReport.targetUser.profilePhotoUrl" :src="selectedReport.targetUser.profilePhotoUrl" alt="Profile" class="user-avatar" />
              <div class="user-avatar-placeholder" v-else><User :size="28" /></div>
              <div class="user-details">
                <p><strong>ID:</strong> <span class="mono">{{ selectedReport.targetUserId }}</span></p>
                <p><strong>Name:</strong> {{ selectedReport.targetUser.firstname }} {{ selectedReport.targetUser.lastname }}</p>
                <p><strong>Nickname:</strong> {{ selectedReport.targetUser.nickname }}</p>
                <p><strong>Email:</strong> {{ selectedReport.targetUser.email }}</p>
                <p><strong>Phone:</strong> {{ selectedReport.targetUser.phoneNumber }}</p>
                <p><strong>Age:</strong> {{ selectedReport.targetUser.age }} · <strong>Sex:</strong> {{ selectedReport.targetUser.sex }}</p>
                <p><strong>Score:</strong> {{ selectedReport.targetUser.behaviorScore }}</p>
                <p v-if="selectedReport.targetUser.isBlacklist" class="text-error"><AlertTriangle :size="14" /> BLACKLISTED</p>
              </div>
            </div>
            <p v-else class="text-muted"><Info :size="14" /> Not available</p>
          </div>

          <div class="divider"></div>

          <!-- Report Info -->
          <div class="detail-section">
            <h3><FileText :size="20" /> Details</h3>
            <div class="report-info">
              <p><strong>Reason:</strong> <span class="reason-badge">{{ selectedReport.reason }}</span></p>
              <p v-if="selectedReport.anotherReason"><strong>Additional:</strong> {{ selectedReport.anotherReason }}</p>
              <p v-if="selectedReport.description">
                <strong>Description:</strong><br />
                <span class="description-text">{{ selectedReport.description }}</span>
              </p>
              <p><strong>Notified:</strong> {{ selectedReport.isNotified ? 'Yes' : 'No' }}</p>
            </div>
          </div>

          <!-- Evidence -->
          <div v-if="selectedReport.evidenceUrls && selectedReport.evidenceUrls.length > 0" class="detail-section">
            <h3><ImageIcon :size="20" /> Evidence ({{ selectedReport.evidenceUrls.length }})</h3>
            <div class="evidence-grid">
              <a v-for="(url, index) in selectedReport.evidenceUrls" :key="index" :href="url" target="_blank" class="evidence-item">
                <img :src="url" :alt="`Evidence ${index + 1}`" />
                <div class="evidence-overlay"><ZoomIn :size="28" /></div>
              </a>
            </div>
          </div>

          <!-- Update Status -->
          <div class="detail-section">
            <h3><Settings :size="20" /> Update Status</h3>
            <div class="status-actions">
              <button v-if="selectedReport.status !== 'RESOLVED'" class="btn btn-success btn-sm" @click="updateStatus('RESOLVED')" :disabled="updatingStatus">
                <CheckCircle :size="16" /> Resolve
              </button>
              <button v-if="selectedReport.status !== 'DISMISSED'" class="btn btn-secondary btn-sm" @click="updateStatus('DISMISSED')" :disabled="updatingStatus">
                <XCircle :size="16" /> Dismiss
              </button>
              <button v-if="selectedReport.status !== 'REJECTED'" class="btn btn-danger btn-sm" @click="updateStatus('REJECTED')" :disabled="updatingStatus">
                <Ban :size="16" /> Reject
              </button>
              <button v-if="selectedReport.status !== 'PENDING'" class="btn btn-outline btn-sm" @click="updateStatus('PENDING')" :disabled="updatingStatus">
                <RotateCcw :size="16" /> Pending
              </button>
            </div>
            <p v-if="updateError" class="text-error mt-2"><AlertTriangle :size="14" /> {{ updateError }}</p>
            <p v-if="updateSuccess" class="text-success mt-2"><CheckCircle :size="14" /> {{ updateSuccess }}</p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import {
  AlertCircle,
  AlertTriangle,
  ArrowUpDown,
  Badge,
  Ban,
  Calendar,
  CheckCircle,
  ChevronLeft,
  ChevronRight,
  ClipboardList,
  Clock,
  Eye,
  FileStack,
  FileText,
  Filter,
  Hash,
  ImageIcon,
  InboxIcon,
  Info,
  ListOrdered,
  Loader2,
  RotateCcw,
  RotateCw,
  Settings,
  Tag,
  User,
  UserCircle,
  UserX,
  X,
  XCircle,
  ZoomIn
} from 'lucide-vue-next'
import { computed, onMounted, ref } from 'vue'
import { useAuthStore } from '../stores/auth'
// API Configuration
const API_BASE_URL = import.meta.env.VITE_API_BASE_URL + '/admin'
const authStore = useAuthStore()

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

const stats = computed(() => {
  const pending = reports.value.filter((r) => r.status === 'PENDING').length
  const resolved = reports.value.filter((r) => r.status === 'RESOLVED').length
  const dismissed = reports.value.filter((r) => r.status === 'DISMISSED').length
  const rejected = reports.value.filter((r) => r.status === 'REJECTED').length
  return { pending, resolved, dismissed, rejected }
})

const getStatusIcon = (status) => {
  const icons = { PENDING: Clock, RESOLVED: CheckCircle, DISMISSED: XCircle, REJECTED: Ban }
  return icons[status] || AlertCircle
}

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
    if (selectedStatus.value) params.append('status', selectedStatus.value)

    const response = await fetch(`${API_BASE_URL}/reports?${params}`, {
      method: 'GET', headers: { 'Content-Type': 'application/json', ...authStore.getAuthHeaders() },
    })
    if (!response.ok) throw new Error(`Failed to fetch reports: ${response.status}`)
    const data = await response.json()
    reports.value = data.content || []
    totalPages.value = data.totalPages || 0
    totalReports.value = data.totalElements || 0
  } catch (err) {
    error.value = err.message
    console.error('Error fetching reports:', err)
  } finally { loading.value = false }
}

const viewReport = async (reportId) => {
  loading.value = true
  error.value = null
  try {
    const response = await fetch(`${API_BASE_URL}/reports/${reportId}`, {
      method: 'GET', headers: { 'Content-Type': 'application/json', ...authStore.getAuthHeaders() },
    })
    if (!response.ok) throw new Error(`Failed to fetch report details: ${response.status}`)
    selectedReport.value = await response.json()
    updateError.value = null
    updateSuccess.value = null
  } catch (err) {
    error.value = err.message
    console.error('Error fetching report details:', err)
  } finally { loading.value = false }
}

const updateStatus = async (newStatus) => {
  if (!selectedReport.value) return
  updatingStatus.value = true
  updateError.value = null
  updateSuccess.value = null
  try {
    const response = await fetch(`${API_BASE_URL}/reports/${selectedReport.value.reportId}/status`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json', ...authStore.getAuthHeaders() },
      body: JSON.stringify({ status: newStatus }),
    })
    if (!response.ok) throw new Error(`Failed to update status: ${response.status}`)
    const updatedReport = await response.json()
    selectedReport.value.status = updatedReport.status
    updateSuccess.value = `Status updated to ${newStatus}`
    setTimeout(() => { fetchReports() }, 1000)
  } catch (err) {
    updateError.value = err.message
  } finally { updatingStatus.value = false }
}

const closeModal = () => { selectedReport.value = null; updateError.value = null; updateSuccess.value = null }
const changePage = (p) => { if (p >= 0 && p < totalPages.value) { currentPage.value = p; fetchReports() } }
const formatDate = (d) => {
  if (!d) return 'N/A'
  return new Date(d).toLocaleString('en-US', { year: 'numeric', month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit' })
}

onMounted(() => { fetchReports() })
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
  margin-bottom: 1.5rem;
  flex-wrap: wrap;
  gap: 1.5rem;
}
.header-text { flex: 1; }
.header-title { display: flex; align-items: center; gap: 1rem; }
.header-icon-wrap {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 52px;
  height: 52px;
  border-radius: var(--radius-xl);
  background: linear-gradient(135deg, rgba(96, 212, 255, 0.15) 0%, rgba(77, 216, 230, 0.08) 100%);
  color: var(--brand-primary);
  animation: fadeIn 0.5s ease;
}
.header h1 { margin: 0; animation: fadeIn 0.5s ease; }

/* Stats */
.stats-summary { display: flex; gap: 0.75rem; flex-wrap: wrap; }
.stat-card {
  background: var(--glass-bg);
  backdrop-filter: var(--glass-blur);
  padding: 1rem 1.25rem;
  border-radius: var(--radius-xl);
  border: 1px solid var(--glass-border);
  display: flex;
  align-items: center;
  gap: 0.875rem;
  min-width: 130px;
  transition: all var(--transition-base);
  animation: slideInRight 0.5s ease;
}
.stat-card:hover {
  transform: translateY(-3px);
  border-color: var(--glass-border-hover);
  box-shadow: var(--shadow-md);
}
.stat-total .stat-icon {
  background: linear-gradient(135deg, rgba(96, 212, 255, 0.15) 0%, rgba(77, 216, 230, 0.08) 100%);
  color: var(--brand-primary);
}
.stat-pending .stat-icon {
  background: linear-gradient(135deg, rgba(251, 191, 36, 0.15) 0%, rgba(245, 158, 11, 0.08) 100%);
  color: var(--color-warning);
}
.stat-resolved .stat-icon {
  background: linear-gradient(135deg, rgba(74, 222, 128, 0.15) 0%, rgba(34, 197, 94, 0.08) 100%);
  color: var(--color-success);
}
.stat-icon {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 40px;
  height: 40px;
  border-radius: var(--radius-lg);
}
.stat-content { display: flex; flex-direction: column; }
.stat-label {
  font-size: 0.6875rem;
  color: var(--text-muted);
  text-transform: uppercase;
  letter-spacing: 0.06em;
  font-weight: 600;
}
.stat-value {
  font-size: 1.625rem;
  font-weight: 700;
  color: var(--text-primary);
  line-height: 1;
  font-family: 'JetBrains Mono', monospace;
}

/* Filters */
.filters {
  display: flex;
  gap: 0.875rem;
  margin-bottom: 1.5rem;
  padding: 1.25rem;
  background: var(--glass-bg);
  backdrop-filter: var(--glass-blur);
  border-radius: var(--radius-xl);
  border: 1px solid var(--glass-border);
  flex-wrap: wrap;
  align-items: flex-end;
  animation: fadeIn 0.5s ease 0.1s backwards;
}
.filter-group {
  display: flex;
  flex-direction: column;
  gap: 0.375rem;
  flex: 1;
  min-width: 140px;
}
.filter-btn {
  align-self: flex-end;
  height: 40px;
  padding: 0 1.25rem;
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
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}

.error-message {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 3rem;
  gap: 1rem;
  background: var(--glass-bg);
  backdrop-filter: var(--glass-blur);
  border-radius: var(--radius-xl);
  border: 1px solid var(--glass-border);
}
.error-icon { color: var(--color-error); }
.error-message p { color: var(--color-error); font-weight: 500; }

/* Table */
.id-cell { font-family: 'JetBrains Mono', monospace; font-size: 0.875rem; color: var(--text-primary); }
.user-cell { display: flex; align-items: center; gap: 0.5rem; }
.user-icon { color: var(--brand-primary); flex-shrink: 0; }
.user-icon.target { color: var(--color-error); }
.user-id { font-family: 'JetBrains Mono', monospace; font-size: 0.8125rem; color: var(--text-secondary); }
.date-cell { color: var(--text-muted); font-size: 0.875rem; }
.reason-badge {
  display: inline-flex;
  padding: 0.25rem 0.625rem;
  background: rgba(99, 118, 148, 0.1);
  border: 1px solid rgba(99, 118, 148, 0.15);
  border-radius: var(--radius-md);
  font-size: 0.8125rem;
  color: var(--text-secondary);
  font-weight: 500;
}
.empty-state {
  padding: 3rem;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.75rem;
  color: var(--text-muted);
}

.btn-action {
  display: inline-flex;
  align-items: center;
  gap: 0.375rem;
  padding: 0.375rem 0.875rem;
  border: 1px solid rgba(96, 212, 255, 0.2);
  border-radius: var(--radius-md);
  cursor: pointer;
  font-size: 0.8125rem;
  font-weight: 500;
  transition: all 0.2s ease;
  background: rgba(96, 212, 255, 0.06);
  color: var(--brand-primary);
}
.btn-action:hover {
  background: rgba(96, 212, 255, 0.12);
  border-color: rgba(96, 212, 255, 0.35);
  transform: translateY(-1px);
  box-shadow: 0 0 12px rgba(96, 212, 255, 0.15);
}

.btn-sm { padding: 0.5rem 1rem; font-size: 0.8125rem; }

/* Pagination */
.pagination {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 1rem;
  margin-top: 1.5rem;
  padding: 1rem;
  background: var(--glass-bg);
  backdrop-filter: var(--glass-blur);
  border-radius: var(--radius-xl);
  border: 1px solid var(--glass-border);
}
.page-info {
  font-weight: 500;
  color: var(--text-primary);
  font-size: 0.875rem;
}
.page-total { color: var(--text-muted); font-size: 0.8125rem; }

/* Modal */
.modal-overlay {
  position: fixed;
  top: 0; left: 0; right: 0; bottom: 0;
  background: rgba(5, 8, 15, 0.85);
  backdrop-filter: blur(8px);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  padding: 1rem;
  overflow-y: auto;
}
.modal {
  background: var(--bg-white);
  border: 1px solid var(--glass-border);
  border-radius: var(--radius-2xl);
  box-shadow: var(--shadow-2xl), var(--shadow-brand);
  max-width: 900px;
  width: 100%;
  max-height: 90vh;
  overflow-y: auto;
  animation: modalSlideUp 0.35s cubic-bezier(0.34, 1.56, 0.64, 1);
}
@keyframes modalSlideUp {
  from { opacity: 0; transform: translateY(30px) scale(0.97); }
  to { opacity: 1; transform: translateY(0) scale(1); }
}
.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1.25rem 1.5rem;
  border-bottom: 1px solid var(--divider);
  position: sticky;
  top: 0;
  background: var(--bg-white);
  z-index: 10;
}
.modal-title { display: flex; align-items: center; gap: 0.75rem; color: var(--brand-primary); }
.modal-title h2 { margin: 0; font-size: 1.25rem; color: var(--text-primary); }
.btn-close {
  display: flex;
  align-items: center;
  justify-content: center;
  background: none;
  border: 1px solid transparent;
  cursor: pointer;
  color: var(--text-muted);
  transition: all 0.2s ease;
  padding: 0.375rem;
  border-radius: var(--radius-md);
}
.btn-close:hover {
  color: var(--color-error);
  background: rgba(248, 113, 113, 0.08);
  border-color: rgba(248, 113, 113, 0.2);
}
.modal-body { padding: 1.5rem; }
.detail-section { margin-bottom: 1.75rem; }
.detail-top { display: flex; align-items: center; gap: 1rem; flex-wrap: wrap; }
.detail-section h3 {
  display: flex;
  align-items: center;
  gap: 0.625rem;
  color: var(--text-primary);
  margin-bottom: 0.875rem;
  font-size: 1.0625rem;
}
.badge-large { font-size: 0.875rem; padding: 0.5rem 1rem; }
.detail-date {
  display: flex;
  align-items: center;
  gap: 0.375rem;
  color: var(--text-muted);
  font-size: 0.8125rem;
}
.divider {
  height: 1px;
  background: var(--divider);
  margin: 1.75rem 0;
}

/* User Info (Modal) */
.user-info {
  display: flex;
  gap: 1.25rem;
  padding: 1.25rem;
  background: var(--bg-surface-muted);
  border-radius: var(--radius-xl);
  border: 1px solid var(--glass-border);
}
.user-avatar {
  width: 72px;
  height: 72px;
  border-radius: 50%;
  object-fit: cover;
  border: 2px solid var(--brand-primary);
  box-shadow: 0 0 15px rgba(96, 212, 255, 0.15);
}
.user-avatar-placeholder {
  width: 72px;
  height: 72px;
  border-radius: 50%;
  background: linear-gradient(135deg, rgba(96, 212, 255, 0.15) 0%, rgba(77, 216, 230, 0.08) 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--brand-primary);
  border: 2px solid rgba(96, 212, 255, 0.25);
  flex-shrink: 0;
}
.user-details { flex: 1; }
.user-details p {
  display: flex;
  align-items: center;
  gap: 0.375rem;
  margin-bottom: 0.5rem;
  color: var(--text-secondary);
  font-size: 0.9rem;
}

.report-info {
  padding: 1.25rem;
  background: var(--bg-surface-muted);
  border-radius: var(--radius-xl);
  border: 1px solid var(--glass-border);
}
.report-info p {
  display: flex;
  align-items: flex-start;
  gap: 0.375rem;
  margin-bottom: 0.75rem;
  font-size: 0.9rem;
}
.description-text {
  display: block;
  margin-top: 0.375rem;
  padding: 0.875rem;
  background: rgba(30, 41, 59, 0.5);
  border-radius: var(--radius-md);
  color: var(--text-primary);
  white-space: pre-wrap;
  word-wrap: break-word;
  border: 1px solid var(--glass-border);
  font-size: 0.875rem;
}

/* Evidence */
.evidence-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(140px, 1fr));
  gap: 0.75rem;
}
.evidence-item {
  position: relative;
  aspect-ratio: 1;
  border-radius: var(--radius-lg);
  overflow: hidden;
  cursor: pointer;
  transition: all 0.3s ease;
  border: 1px solid var(--glass-border);
}
.evidence-item:hover {
  transform: scale(1.03);
  border-color: var(--brand-primary);
  box-shadow: var(--shadow-glow-sm);
}
.evidence-item img { width: 100%; height: 100%; object-fit: cover; }
.evidence-overlay {
  position: absolute;
  top: 0; left: 0; right: 0; bottom: 0;
  background: rgba(10, 15, 30, 0.7);
  display: flex;
  align-items: center;
  justify-content: center;
  opacity: 0;
  transition: opacity 0.3s ease;
  color: var(--brand-primary);
}
.evidence-item:hover .evidence-overlay { opacity: 1; }

/* Status Actions */
.status-actions { display: flex; gap: 0.75rem; flex-wrap: wrap; }

.mono { font-family: 'JetBrains Mono', monospace; }

/* ===== Responsive ===== */
@media (max-width: 768px) {
  .reports-view { padding: 1rem; }
  .header { flex-direction: column; align-items: stretch; }
  .stats-summary { width: 100%; flex-direction: column; }
  .stat-card { width: 100%; }
  .filters { flex-direction: column; }
  .filter-group { width: 100%; }
  .filter-btn { width: 100%; }
  .pagination { flex-direction: column; }
  .modal { margin: 0.5rem; max-height: calc(100vh - 1rem); border-radius: var(--radius-xl); }
  .modal-body { padding: 1rem; }
  .user-info { flex-direction: column; align-items: center; text-align: center; }
  .evidence-grid { grid-template-columns: repeat(2, 1fr); }
  .status-actions { flex-direction: column; }
  .status-actions .btn { width: 100%; }
}
</style>
