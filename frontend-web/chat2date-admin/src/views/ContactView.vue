<script setup>
import {
  AlertTriangle,
  BadgeCheck as BadgeIcon,
  Calendar,
  CheckCircle,
  Clock,
  Eye,
  FileStack,
  Filter,
  Hash,
  InboxIcon,
  Loader2,
  Mail,
  Mail as MailIcon,
  MessageSquare,
  RotateCw,
  Send,
  Settings,
  Tag,
  UserCircle,
  X,
  XCircle,
} from 'lucide-vue-next'
import { computed, onMounted, ref } from 'vue'
import { contactApi } from '../services/api'

const contacts = ref([])
const selectedContact = ref(null)
const loading = ref(false)
const error = ref(null)
const selectedStatus = ref('')
const replyMessage = ref('')
const replying = ref(false)
const replyError = ref(null)
const replySuccess = ref(null)

const stats = computed(() => ({
  new: contacts.value.filter((c) => c.status === 'NEW').length,
  inProgress: contacts.value.filter((c) => c.status === 'IN_PROGRESS').length,
  resolved: contacts.value.filter((c) => c.status === 'RESOLVED').length,
}))

const filteredContacts = computed(() => {
  if (!selectedStatus.value) return contacts.value
  return contacts.value.filter((c) => c.status === selectedStatus.value)
})

const getStatusClass = (status) => {
  const map = { NEW: 'badge-pending', IN_PROGRESS: 'badge-info', RESOLVED: 'badge-resolved' }
  return map[status] || 'badge-dismissed'
}

const getStatusIcon = (status) => {
  const map = { NEW: Clock, IN_PROGRESS: MailIcon, RESOLVED: CheckCircle }
  return map[status] || XCircle
}

const fetchContacts = async () => {
  loading.value = true
  error.value = null
  try {
    contacts.value = await contactApi.getAllContactMessages()
  } catch (err) {
    error.value = err.message
  } finally {
    loading.value = false
  }
}

const viewContact = (contact) => {
  selectedContact.value = contact
  replyError.value = null
  replySuccess.value = null

  // ✅ เตรียมข้อความตั้งต้นให้แอดมิน ถ้าเป็นเรื่อง SOS
  if (contact.subject === 'ขอข้อมูล/หลักฐานเหตุฉุกเฉิน (SOS)') {
    replyMessage.value = 'สวัสดีครับ/ค่ะ\n\nทีมงานขอส่งมอบข้อมูลหลักฐานการแจ้งเหตุฉุกเฉิน (SOS) ของคุณ เพื่อนำไปใช้ประกอบการดำเนินการต่อไปตามรายละเอียดด้านล่างนี้ครับ/ค่ะ\n'
  } else {
    replyMessage.value = ''
  }
}

const sendReply = async () => {
  if (!replyMessage.value.trim()) return
  replying.value = true
  replyError.value = null
  replySuccess.value = null
  try {
    await contactApi.replyContactMessage(selectedContact.value.contactId, {
      replyMessage: replyMessage.value,
    })
    replySuccess.value = 'Reply sent successfully'
    selectedContact.value.status = 'RESOLVED'
    selectedContact.value.repliedAt = new Date().toISOString()
    replyMessage.value = ''
    // อัปเดต list ด้วย
    const idx = contacts.value.findIndex((c) => c.contactId === selectedContact.value.contactId)
    if (idx !== -1) {
      contacts.value[idx].status = 'RESOLVED'
      contacts.value[idx].repliedAt = selectedContact.value.repliedAt
    }
  } catch (err) {
    replyError.value = err.message
  } finally {
    replying.value = false
  }
}

const closeModal = () => {
  selectedContact.value = null
  replyMessage.value = ''
  replyError.value = null
  replySuccess.value = null
}

const formatDate = (d) => {
  if (!d) return 'N/A'
  return new Date(d).toLocaleString('en-US', {
    year: 'numeric', month: 'short', day: 'numeric',
    hour: '2-digit', minute: '2-digit',
  })
}

onMounted(fetchContacts)
</script>

<template>
  <div class="contact-view">
    <!-- Header -->
    <div class="header">
      <div class="header-text">
        <div class="header-title">
          <div class="header-icon-wrap">
            <Mail :size="28" :stroke-width="2" />
          </div>
          <div>
            <h1>Contact Messages</h1>
            <p class="text-muted" style="margin:0;font-size:0.9rem">View and reply to user contact messages</p>
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
            <span class="stat-value">{{ contacts.length }}</span>
          </div>
        </div>
        <div class="stat-card stat-pending">
          <div class="stat-icon">
            <Clock :size="20" :stroke-width="2" />
          </div>
          <div class="stat-content">
            <span class="stat-label">New</span>
            <span class="stat-value">{{ stats.new }}</span>
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
        <label>
          <Filter :size="14" />
          Status
        </label>
        <select v-model="selectedStatus">
          <option value="">All Status</option>
          <option value="NEW">New</option>
          <option value="IN_PROGRESS">In Progress</option>
          <option value="RESOLVED">Resolved</option>
        </select>
      </div>
      <button class="btn btn-primary filter-btn" @click="fetchContacts">
        <RotateCw :size="16" />
        Refresh
      </button>
    </div>

    <!-- Loading State -->
    <div v-if="loading" class="loading-container">
      <Loader2 :size="40" :stroke-width="2" class="spinner-icon" />
      <p>Loading messages...</p>
    </div>

    <!-- Error State -->
    <div v-else-if="error" class="error-message">
      <AlertTriangle :size="40" :stroke-width="2" class="error-icon" />
      <p>{{ error }}</p>
      <button class="btn btn-outline" @click="fetchContacts">
        <RotateCw :size="16" />
        Try Again
      </button>
    </div>

    <!-- Table -->
    <div v-else class="table-container">
      <table>
        <thead>
          <tr>
            <th>
              <Hash :size="14" /> ID
            </th>
            <th>
              <UserCircle :size="14" /> Name
            </th>
            <th>
              <MailIcon :size="14" /> Email
            </th>
            <th>
              <Tag :size="14" /> Subject
            </th>
            <th>
              <BadgeIcon :size="14" /> Status
            </th>
            <th>
              <Calendar :size="14" /> Date
            </th>
            <th>
              <Settings :size="14" /> Actions
            </th>
          </tr>
        </thead>
        <tbody>
          <tr v-if="filteredContacts.length === 0">
            <td colspan="7" class="text-center text-muted">
              <div class="empty-state">
                <InboxIcon :size="40" :stroke-width="1.5" />
                <p>No contact messages found</p>
              </div>
            </td>
          </tr>
          <tr v-for="contact in filteredContacts" :key="contact.contactId">
            <td>
              <strong class="mono">#{{ contact.contactId }}</strong>
            </td>
            <td>
              <div class="user-cell">
                <UserCircle :size="15" class="user-icon" />
                <span>{{ contact.contactName }}</span>
              </div>
            </td>
            <td>
              <span class="mono email-cell">{{ contact.contactEmail }}</span>
            </td>
            <td>
              <span class="reason-badge">{{ contact.subject }}</span>
            </td>
            <td>
              <span :class="['badge', getStatusClass(contact.status)]">
                <component :is="getStatusIcon(contact.status)" :size="12" />
                {{ contact.status }}
              </span>
            </td>
            <td>
              <span class="date-cell">
                {{ formatDate(new Date(new Date(contact.createdAt).getTime() + 7 * 60 * 60 * 1000)) }}
              </span>
            </td>
            <td>
              <button class="btn-action" @click="viewContact(contact)">
                <Eye :size="15" />
                View
              </button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- Detail + Reply Modal -->
    <div v-if="selectedContact" class="modal-overlay" @click.self="closeModal">
      <div class="modal">
        <div class="modal-header">
          <div class="modal-title">
            <MessageSquare :size="22" />
            <h2>Contact #{{ selectedContact.contactId }}</h2>
          </div>
          <button class="btn-close" @click="closeModal">
            <X :size="22" />
          </button>
        </div>

        <div class="modal-body">
          <!-- Status & Date -->
          <div class="detail-section detail-top">
            <span :class="['badge', 'badge-large', getStatusClass(selectedContact.status)]">
              <component :is="getStatusIcon(selectedContact.status)" :size="16" />
              {{ selectedContact.status }}
            </span>
            <span class="detail-date">
              <Clock :size="14" />
              {{ formatDate(selectedContact.createdAt) }}
            </span>
            <span v-if="selectedContact.repliedAt" class="detail-date replied">
              <CheckCircle :size="14" />
              Replied: {{ formatDate(selectedContact.repliedAt) }}
            </span>
          </div>

          <!-- Sender Info -->
          <div class="detail-section">
            <h3>
              <UserCircle :size="20" /> Sender
            </h3>
            <div class="sender-info">
              <div class="sender-row">
                <span class="sender-label">Name</span>
                <span class="sender-value">{{ selectedContact.contactName }}</span>
              </div>
              <div class="sender-row">
                <span class="sender-label">Email</span>
                <span class="sender-value mono">{{ selectedContact.contactEmail }}</span>
              </div>
              <div class="sender-row">
                <span class="sender-label">User ID</span>
                <span class="sender-value mono text-muted">{{ selectedContact.userId }}</span>
              </div>
            </div>
          </div>

          <div class="divider"></div>

          <!-- Message -->
          <div class="detail-section">
            <h3>
              <MessageSquare :size="20" /> Message
            </h3>
            <div class="message-box">
              <div class="message-subject">
                <Tag :size="14" />
                {{ selectedContact.subject }}
              </div>
              <div class="message-body">{{ selectedContact.message }}</div>
            </div>
          </div>

          <!-- Reply (only if not resolved) -->
          <div class="detail-section" v-if="selectedContact.status !== 'RESOLVED'">
            <h3>
              <Send :size="20" /> Reply via Email
            </h3>
            <div class="reply-box">
              <div class="reply-to">
                <MailIcon :size="14" />
                <span>To: <strong>{{ selectedContact.contactEmail }}</strong></span>
              </div>

              <div v-if="selectedContact.subject === 'ขอข้อมูล/หลักฐานเหตุฉุกเฉิน (SOS)'"
                style="padding: 10px 15px; background: rgba(251, 191, 36, 0.1); border-bottom: 1px solid var(--glass-border); color: #d97706; font-size: 0.85rem; display: flex; align-items: center; gap: 8px;">
                <AlertTriangle :size="16" />
                <span><strong>หมายเหตุ:</strong> ระบบจะดึง "ข้อมูลพิกัด วันเวลา และคู่เดต (SOS)" ล่าสุด
                  มาต่อท้ายข้อความนี้ให้อัตโนมัติ แอดมินสามารถกดส่งได้เลย</span>
              </div>

              <textarea v-model="replyMessage" placeholder="Type your reply here..." rows="5"
                :disabled="replying"></textarea>
              <div class="reply-actions">
                <span v-if="replyError" class="text-error">
                  <AlertTriangle :size="14" /> {{ replyError }}
                </span>
                <span v-if="replySuccess" class="text-success">
                  <CheckCircle :size="14" /> {{ replySuccess }}
                </span>
                <button class="btn btn-primary" @click="sendReply" :disabled="replying || !replyMessage.trim()">
                  <Loader2 v-if="replying" :size="16" class="spinner-icon-sm" />
                  <Send v-else :size="16" />
                  {{ replying ? 'Sending...' : 'Send Reply' }}
                </button>
              </div>
            </div>
          </div>

          <!-- Already resolved notice -->
          <div class="detail-section" v-else>
            <div class="resolved-notice">
              <CheckCircle :size="18" />
              <span>This message has been replied and marked as resolved.</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>


<style scoped>
.contact-view {
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

.header-text {
  flex: 1;
}

.header-title {
  display: flex;
  align-items: center;
  gap: 1rem;
}

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

.header h1 {
  margin: 0;
  animation: fadeIn 0.5s ease;
}

/* Stats */
.stats-summary {
  display: flex;
  gap: 0.75rem;
  flex-wrap: wrap;
}

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

.stat-content {
  display: flex;
  flex-direction: column;
}

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
  min-width: 160px;
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
  background: var(--glass-bg);
  backdrop-filter: var(--glass-blur);
  border-radius: var(--radius-xl);
  border: 1px solid var(--glass-border);
}

.error-icon {
  color: var(--color-error);
}

.error-message p {
  color: var(--color-error);
  font-weight: 500;
}

/* Table */
.user-cell {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.user-icon {
  color: var(--brand-primary);
  flex-shrink: 0;
}

.email-cell {
  font-size: 0.8125rem;
  color: var(--text-secondary);
}

.date-cell {
  color: var(--text-muted);
  font-size: 0.875rem;
}

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

/* Modal */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
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
  max-width: 700px;
  width: 100%;
  max-height: 90vh;
  overflow-y: auto;
  animation: modalSlideUp 0.35s cubic-bezier(0.34, 1.56, 0.64, 1);
}

@keyframes modalSlideUp {
  from {
    opacity: 0;
    transform: translateY(30px) scale(0.97);
  }

  to {
    opacity: 1;
    transform: translateY(0) scale(1);
  }
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

.modal-title {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  color: var(--brand-primary);
}

.modal-title h2 {
  margin: 0;
  font-size: 1.25rem;
  color: var(--text-primary);
}

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

.modal-body {
  padding: 1.5rem;
}

.detail-section {
  margin-bottom: 1.75rem;
}

.detail-top {
  display: flex;
  align-items: center;
  gap: 1rem;
  flex-wrap: wrap;
}

.detail-section h3 {
  display: flex;
  align-items: center;
  gap: 0.625rem;
  color: var(--text-primary);
  margin-bottom: 0.875rem;
  font-size: 1.0625rem;
}

.badge-large {
  font-size: 0.875rem;
  padding: 0.5rem 1rem;
}

.detail-date {
  display: flex;
  align-items: center;
  gap: 0.375rem;
  color: var(--text-muted);
  font-size: 0.8125rem;
}

.detail-date.replied {
  color: var(--color-success);
}

.divider {
  height: 1px;
  background: var(--divider);
  margin: 1.75rem 0;
}

/* Sender Info */
.sender-info {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
  padding: 1.25rem;
  background: var(--bg-surface-muted);
  border-radius: var(--radius-xl);
  border: 1px solid var(--glass-border);
}

.sender-row {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  font-size: 0.9rem;
}

.sender-label {
  font-size: 0.75rem;
  color: var(--text-muted);
  text-transform: uppercase;
  letter-spacing: 0.06em;
  font-weight: 600;
  min-width: 60px;
}

.sender-value {
  color: var(--text-primary);
}

/* Message Box */
.message-box {
  background: var(--bg-surface-muted);
  border-radius: var(--radius-xl);
  border: 1px solid var(--glass-border);
  overflow: hidden;
}

.message-subject {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.875rem 1.25rem;
  background: rgba(96, 212, 255, 0.06);
  border-bottom: 1px solid var(--glass-border);
  color: var(--brand-primary);
  font-weight: 600;
  font-size: 0.9rem;
}

.message-body {
  padding: 1.25rem;
  color: var(--text-secondary);
  font-size: 0.9375rem;
  line-height: 1.7;
  white-space: pre-wrap;
  word-wrap: break-word;
}

/* Reply Box */
.reply-box {
  background: var(--bg-surface-muted);
  border-radius: var(--radius-xl);
  border: 1px solid var(--glass-border);
  overflow: hidden;
}

.reply-to {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.75rem 1.25rem;
  background: rgba(96, 212, 255, 0.04);
  border-bottom: 1px solid var(--glass-border);
  color: var(--text-muted);
  font-size: 0.8125rem;
}

.reply-to strong {
  color: var(--text-primary);
}

.reply-box textarea {
  border: none;
  border-radius: 0;
  background: transparent;
  padding: 1rem 1.25rem;
  resize: vertical;
  min-height: 120px;
  font-size: 0.9rem;
  line-height: 1.6;
}

.reply-box textarea:focus {
  box-shadow: none;
  background: rgba(96, 212, 255, 0.02);
}

.reply-actions {
  display: flex;
  align-items: center;
  justify-content: flex-end;
  gap: 0.75rem;
  padding: 0.875rem 1.25rem;
  border-top: 1px solid var(--glass-border);
  flex-wrap: wrap;
}

.reply-actions .text-error,
.reply-actions .text-success {
  display: flex;
  align-items: center;
  gap: 0.375rem;
  font-size: 0.8125rem;
  flex: 1;
}

.spinner-icon-sm {
  animation: spin 1s linear infinite;
}

/* Resolved Notice */
.resolved-notice {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  padding: 1rem 1.25rem;
  background: rgba(74, 222, 128, 0.06);
  border: 1px solid rgba(74, 222, 128, 0.2);
  border-radius: var(--radius-xl);
  color: var(--color-success);
  font-size: 0.9rem;
  font-weight: 500;
}

.mono {
  font-family: 'JetBrains Mono', monospace;
}

/* Responsive */
@media (max-width: 768px) {
  .contact-view {
    padding: 1rem;
  }

  .header {
    flex-direction: column;
    align-items: stretch;
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

  .filter-btn {
    width: 100%;
  }

  .modal {
    margin: 0.5rem;
    max-height: calc(100vh - 1rem);
    border-radius: var(--radius-xl);
  }

  .modal-body {
    padding: 1rem;
  }

  .reply-actions {
    flex-direction: column;
    align-items: stretch;
  }

  .reply-actions .btn {
    width: 100%;
  }
}
</style>