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
            <p class="text-muted" style="margin: 0; font-size: 0.9rem">
              Manage and review user reports
            </p>
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
            <th>
              <Hash :size="14" /> ID
            </th>
            <th>
              <UserCircle :size="14" /> Reporter
            </th>
            <th>
              <UserX :size="14" /> Target
            </th>
            <th>
              <Tag :size="14" /> Reason
            </th>
            <th>
              <Badge :size="14" /> Status
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
      <button class="btn btn-outline btn-sm" :disabled="currentPage >= totalPages - 1"
        @click="changePage(currentPage + 1)">
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
            <h3>
              <UserCircle :size="20" /> Reporter
            </h3>
            <div v-if="selectedReport.reporter" class="user-info">
              <img v-if="selectedReport.reporter.profilePhotoUrl" :src="selectedReport.reporter.profilePhotoUrl"
                alt="Profile" class="user-avatar" />
              <div class="user-avatar-placeholder" v-else>
                <User :size="28" />
              </div>
              <div class="user-details">
                <p>
                  <strong>ID:</strong> <span class="mono">{{ selectedReport.reporterId }}</span>
                </p>
                <p>
                  <strong>Name:</strong> {{ selectedReport.reporter.firstname }}
                  {{ selectedReport.reporter.lastname }}
                </p>
                <p><strong>Nickname:</strong> {{ selectedReport.reporter.nickname }}</p>
                <p><strong>Email:</strong> {{ selectedReport.reporter.email }}</p>
                <p><strong>Phone:</strong> {{ selectedReport.reporter.phoneNumber }}</p>
                <p>
                  <strong>Age:</strong> {{ selectedReport.reporter.age }} · <strong>Sex:</strong>
                  {{ selectedReport.reporter.sex }}
                </p>
                <p><strong>Score:</strong> {{ selectedReport.reporter.behaviorScore }}</p>
                <p v-if="selectedReport.reporter.isBlacklist" class="text-error">
                  <AlertTriangle :size="14" /> BLACKLISTED
                </p>
              </div>
            </div>
            <p v-else class="text-muted">
              <Info :size="14" /> Not available
            </p>
          </div>

          <div class="divider"></div>

          <!-- Target -->
          <div class="detail-section">
            <h3>
              <UserX :size="20" /> Target User
            </h3>
            <div v-if="selectedReport.targetUser" class="user-info">
              <img v-if="selectedReport.targetUser.profilePhotoUrl" :src="selectedReport.targetUser.profilePhotoUrl"
                alt="Profile" class="user-avatar" />
              <div class="user-avatar-placeholder" v-else>
                <User :size="28" />
              </div>
              <div class="user-details">
                <p>
                  <strong>ID:</strong> <span class="mono">{{ selectedReport.targetUserId }}</span>
                </p>
                <p>
                  <strong>Name:</strong> {{ selectedReport.targetUser.firstname }}
                  {{ selectedReport.targetUser.lastname }}
                </p>
                <p><strong>Nickname:</strong> {{ selectedReport.targetUser.nickname }}</p>
                <p><strong>Email:</strong> {{ selectedReport.targetUser.email }}</p>
                <p><strong>Phone:</strong> {{ selectedReport.targetUser.phoneNumber }}</p>
                <p>
                  <strong>Age:</strong> {{ selectedReport.targetUser.age }} · <strong>Sex:</strong>
                  {{ selectedReport.targetUser.sex }}
                </p>
                <p class="score-row">
                  <span class="score-label">Score:</span>

                  <transition name="score-fade" mode="out-in">
                    <span v-if="finalPmScore <= 0 || finalPmScore == null" key="current" class="current-score mono">
                      {{ selectedReport.targetUser.behaviorScore }}
                    </span>

                    <div v-else key="preview" class="score-preview-wrap">
                      <span :class="[
                        'new-score mono',
                        `text-${confirmedPenalty ? confirmedPenalty.severity : isCustomReason ? customSeverity : pmSelectedCase?.severity}`,
                      ]">
                        {{ previewTargetScore }}
                      </span>

                      <span class="score-reference-hint">
                        (จากเดิม {{ selectedReport.targetUser.behaviorScore }} หัก -{{
                          finalPmScore
                        }})
                      </span>
                    </div>
                  </transition>
                </p>
                <p v-if="selectedReport.targetUser.isBlacklist" class="text-error">
                  <AlertTriangle :size="14" /> BLACKLISTED
                </p>
              </div>
            </div>
            <p v-else class="text-muted">
              <Info :size="14" /> Not available
            </p>
          </div>

          <div class="divider"></div>

          <!-- Report Info -->
          <div class="detail-section">
            <h3>
              <FileText :size="20" /> Details
            </h3>
            <div class="report-info">
              <p>
                <strong>Reason:</strong>
                <span class="reason-badge">{{ selectedReport.reason }}</span>
              </p>
              <p v-if="selectedReport.anotherReason">
                <strong>Additional:</strong> {{ selectedReport.anotherReason }}
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
            <h3>
              <ImageIcon :size="20" /> Evidence ({{ selectedReport.evidenceUrls.length }})
            </h3>
            <div class="evidence-grid">
              <a v-for="(url, index) in selectedReport.evidenceUrls" :key="index" :href="url" target="_blank"
                class="evidence-item">
                <img :src="url" :alt="`Evidence ${index + 1}`" />
                <div class="evidence-overlay">
                  <ZoomIn :size="28" />
                </div>
              </a>
            </div>
          </div>

          <!-- Update Status -->
          <div class="detail-section">
            <h3>
              <Settings :size="20" /> Update Status
            </h3>

            <!-- Confirmed penalty chip — แสดงหลังจากยืนยัน penalty แล้ว -->
            <div v-if="confirmedPenalty" class="confirmed-penalty-chip">
              <Gavel :size="14" />
              <span>Penalty:</span>
              <span :class="['chip-severity', `chip-${confirmedPenalty.severity}`]">
                {{ confirmedPenalty.severityLabel }}
              </span>
              <strong class="chip-score">{{ confirmedPenalty.score }} คะแนน</strong>
              <button class="chip-change" @click="openPenaltyModal">
                <Pencil :size="12" /> เปลี่ยน
              </button>
            </div>

            <div class="status-actions">
              <template v-if="selectedReport.status === 'PENDING'">
                <button :class="[
                  'btn btn-success btn-sm',
                  { 'btn-needs-penalty': hasPenaltyConfig && !confirmedPenalty },
                ]" @click="onClickResolve(selectedReport.reportId)" :disabled="updatingStatus">
                  <CheckCircle :size="16" />
                  Resolve
                  <span v-if="hasPenaltyConfig && !confirmedPenalty" class="needs-penalty-hint">
                    <AlertCircle :size="12" /> เลือก penalty ก่อน
                  </span>
                </button>

                <button class="btn btn-danger btn-sm" @click="updateStatus('REJECTED')" :disabled="updatingStatus">
                  <Ban :size="16" /> Reject
                </button>
              </template>

              <p v-else class="status-locked-notice">
                <Lock :size="14" />
                <span>รายงานนี้ถูกสรุปผลแล้ว ไม่สามารถเปลี่ยนสถานะได้อีก</span>
              </p>
            </div>

            <p v-if="updateError" class="text-error mt-2">
              <AlertTriangle :size="14" /> {{ updateError }}
            </p>
            <p v-if="updateSuccess" class="text-success mt-2">
              <CheckCircle :size="14" /> {{ updateSuccess }}
            </p>
          </div>
        </div>
      </div>
    </div>

    <div v-if="showPenaltyModal" class="modal-overlay penalty-overlay" @click.self="closePenaltyModal">
      <div class="modal penalty-modal">
        <!-- Header -->
        <div class="modal-header">
          <div class="modal-title">
            <Gavel :size="20" />
            <h2>กำหนด Penalty Score</h2>
          </div>
          <button class="btn-close" @click="closePenaltyModal">
            <X :size="22" />
          </button>
        </div>

        <div class="modal-body penalty-modal-body">
          <!-- Reason pill -->
          <div class="pm-reason-chip">
            <Tag :size="13" />
            <span>Reason:</span>
            <strong>{{ selectedReport?.reason }}</strong>
          </div>

          <!-- ── Step 1: เลือก severity ── -->
          <div class="pm-step">
            <div class="pm-step-label">
              <span class="pm-step-num">1</span>
              เลือกระดับความรุนแรง
            </div>

            <!-- Case buttons (preset reasons) -->
            <div v-if="!isCustomReason" class="pm-severity-grid">
              <button v-for="c in penaltyCases" :key="c.key" :class="[
                'pm-severity-btn',
                `sev-${c.severity}`,
                { active: pmSelectedCase?.key === c.key },
              ]" @click="selectCase(c)">
                <div class="pm-sev-left">
                  <span :class="['sev-badge', `sev-badge-${c.severity}`]">
                    <component :is="getSeverityIcon(c.severity)" :size="11" />
                    {{ c.severityLabel }}
                  </span>
                  <ul class="pm-examples">
                    <li v-for="ex in c.examples" :key="ex">{{ ex }}</li>
                  </ul>
                </div>
                <div class="pm-sev-right">
                  <span :class="['pm-range-pill', `range-pill-${c.severity}`]">{{
                    c.scoreLabel
                    }}</span>
                </div>
              </button>
            </div>

            <!-- Custom slider (อื่น ๆ) -->
            <div v-if="isCustomReason" class="pm-custom-block">
              <div class="pm-custom-header">
                <span class="pm-custom-label">กำหนดคะแนนเอง</span>
                <div class="pm-custom-score-row">
                  <span :class="['pm-score-big', `score-color-${customSeverity}`]">{{
                    pmCustomScore
                    }}</span>
                  <span class="pm-score-unit">คะแนน</span>
                </div>
              </div>
              <input type="range" min="1" max="100" step="1" v-model.number="pmCustomScore"
                :class="['penalty-slider', `slider-${customSeverity}`]" />
              <div class="slider-ticks">
                <span>1</span><span>25</span><span>50</span><span>75</span><span>100</span>
              </div>
              <div class="custom-severity-tags">
                <span class="csev-tag csev-light">1–10 เบา</span>
                <span class="csev-tag csev-mid">11–50 กลาง</span>
                <span class="csev-tag csev-heavy">51–100 หนัก</span>
              </div>
            </div>
          </div>

          <!-- ── Step 2: เลือกคะแนนในช่วง (มีเฉพาะ case ที่ scoreMin ≠ scoreMax) ── -->
          <transition name="step2">
            <div v-if="pmSelectedCase && pmSelectedCase.scoreMin !== pmSelectedCase.scoreMax" class="pm-step">
              <div class="pm-step-label">
                <span class="pm-step-num">2</span>
                เลือกคะแนนในช่วง
                <span :class="['pm-range-hint', `hint-${pmSelectedCase.severity}`]">
                  {{ pmSelectedCase.scoreMin }} – {{ pmSelectedCase.scoreMax }}
                </span>
              </div>

              <div :class="['pm-score-slider-wrap', `slider-wrap-${pmSelectedCase.severity}`]">
                <div class="pm-score-display-row">
                  <span :class="['pm-score-big', `score-color-${pmSelectedCase.severity}`]">
                    {{ pmScoreInRange }}
                  </span>
                  <span class="pm-score-unit">คะแนน</span>
                </div>
                <input type="range" :min="pmSelectedCase.scoreMin" :max="pmSelectedCase.scoreMax" step="1"
                  v-model.number="pmScoreInRange" :class="['penalty-slider', `slider-${pmSelectedCase.severity}`]" />
                <div class="pm-score-tick-row">
                  <span>{{ pmSelectedCase.scoreMin }}</span>
                  <span>{{ pmSelectedCase.scoreMax }}</span>
                </div>
              </div>

              <!-- Quick score buttons -->
              <div class="pm-quick-scores">
                <button v-for="qs in quickScores" :key="qs" :class="[
                  'pm-qs-btn',
                  `qs-${pmSelectedCase.severity}`,
                  { active: pmScoreInRange === qs },
                ]" @click="pmScoreInRange = qs">
                  {{ qs }}
                </button>
              </div>
            </div>
          </transition>

          <!-- ── Step 2 fixed (100 คะแนน) ── -->
          <transition name="step2">
            <div v-if="pmSelectedCase && pmSelectedCase.scoreMin === pmSelectedCase.scoreMax" class="pm-step">
              <div class="pm-step-label">
                <span class="pm-step-num">2</span>
                คะแนนที่กำหนด
              </div>
              <div :class="['pm-fixed-score-box', `fixed-${pmSelectedCase.severity}`]">
                <span :class="['pm-score-big', `score-color-${pmSelectedCase.severity}`]">
                  {{ pmSelectedCase.score }}
                </span>
                <span class="pm-score-unit">คะแนน</span>
                <span class="pm-fixed-label">fixed</span>
              </div>
            </div>
          </transition>

          <!-- ── Preview banner ── -->
          <transition name="preview-fade">
            <div v-if="canConfirmPenalty" :class="[
              'pm-preview',
              `preview-${isCustomReason ? customSeverity : pmSelectedCase?.severity}`,
            ]">
              <component :is="getSeverityIcon(isCustomReason ? customSeverity : pmSelectedCase?.severity)" :size="15" />
              <span>จะหักคะแนน</span>
              <strong class="pm-preview-score">{{ finalPmScore }}</strong>
              <span>คะแนนจาก behavior score ของผู้ถูกรายงาน</span>
            </div>
          </transition>

          <!-- ── Footer ── -->
          <div class="pm-footer">
            <button class="btn btn-secondary btn-sm" @click="closePenaltyModal">
              <X :size="15" /> ยกเลิก
            </button>
            <button class="btn btn-primary btn-sm" :disabled="!canConfirmPenalty" @click="confirmPenalty">
              <CheckCircle :size="15" /> ยืนยัน Penalty
            </button>
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
  Flame,
  Gavel,
  Hash,
  ImageIcon,
  InboxIcon,
  Info,
  ListOrdered,
  Loader2,
  Lock,
  Pencil,
  RotateCw,
  Settings,
  ShieldAlert,
  Tag,
  User,
  UserCircle,
  UserX,
  Wind,
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

// ─── Penalty Modal state ──────────────────────────────────────────────────────
const showPenaltyModal = ref(false)
const pmSelectedCase = ref(null)
const pmScoreInRange = ref(null)
const pmCustomScore = ref(50)
const confirmedPenalty = ref(null)

// ─── Penalty Config ────────────────────────────────────────────────────────────
const PENALTY_CONFIG = {
  สแปม: {
    cases: [
      {
        key: 'spam_mid',
        severity: 'mid',
        severityLabel: 'เคสกลาง',
        examples: ['ส่งข้อความซ้ำๆ', 'โฆษณาพนัน / ขายของ'],
        score: 40,
        scoreMin: 30,
        scoreMax: 50,
        scoreLabel: '30 – 50',
      },
    ],
  },
  โปรไฟล์ปลอม: {
    cases: [
      {
        key: 'fake_heavy',
        severity: 'heavy',
        severityLabel: 'เคสหนัก',
        examples: ['ใช้รูปคนอื่น', 'แอบอ้างเป็นบุคคลอื่นเพื่อหลอกลวง'],
        score: 100,
        scoreMin: 100,
        scoreMax: 100,
        scoreLabel: '100',
      },
    ],
  },
  พฤติกรรมไม่เหมาะสม: {
    cases: [
      {
        key: 'behavior_light',
        severity: 'light',
        severityLabel: 'เคสเบา',
        examples: ['พูดจาแทะโลม', 'ตื๊อขอเบอร์ / ขอไลน์'],
        score: 7,
        scoreMin: 5,
        scoreMax: 10,
        scoreLabel: '5 – 10',
      },
      {
        key: 'behavior_heavy',
        severity: 'heavy',
        severityLabel: 'เคสหนัก',
        examples: ['ข่มขู่', 'คุกคามทางเพศ', 'หลอกลวงเชิงชู้สาว'],
        score: 100,
        scoreMin: 100,
        scoreMax: 100,
        scoreLabel: '100',
      },
    ],
  },
  ภาษาที่ไม่เหมาะสม: {
    cases: [
      {
        key: 'language_light',
        severity: 'light',
        severityLabel: 'เคสเบา',
        examples: ['พูดจาหยาบคายเล็กน้อย', 'คำสร้อย / คำด่าทั่วไป'],
        score: 7,
        scoreMin: 5,
        scoreMax: 10,
        scoreLabel: '5 – 10',
      },
      {
        key: 'language_mid',
        severity: 'mid',
        severityLabel: 'เคสกลาง',
        examples: ['พูดจาหยาบคายรุนแรง', 'ด่าทอ / เหยียดหยาม'],
        score: 40,
        scoreMin: 30,
        scoreMax: 50,
        scoreLabel: '30 – 50',
      },
    ],
  },
  'อื่น ๆ': { custom: true },
}

const penaltyConfig = computed(() => {
  const r = selectedReport.value?.reason ?? ''
  const key = Object.keys(PENALTY_CONFIG).find(
    (k) => k.trim().toLowerCase() === r.trim().toLowerCase(),
  )
  return key ? PENALTY_CONFIG[key] : null
})
const hasPenaltyConfig = computed(() => penaltyConfig.value !== null)
const penaltyCases = computed(() => penaltyConfig.value?.cases ?? [])
const isCustomReason = computed(() => penaltyConfig.value?.custom === true)

// severity ของ custom slider ตามช่วงคะแนน
const customSeverity = computed(() => {
  const s = pmCustomScore.value
  if (s <= 10) return 'light'
  if (s <= 50) return 'mid'
  return 'heavy'
})

// quick score presets 5 จุด spread ทั่วช่วง
const quickScores = computed(() => {
  if (!pmSelectedCase.value) return []
  const { scoreMin, scoreMax } = pmSelectedCase.value
  if (scoreMin === scoreMax) return []
  return Array.from({ length: 5 }, (_, i) => Math.round(scoreMin + (i / 4) * (scoreMax - scoreMin)))
})

const finalPmScore = computed(() => {
  if (isCustomReason.value) return pmCustomScore.value
  if (!pmSelectedCase.value) return null
  if (pmSelectedCase.value.scoreMin === pmSelectedCase.value.scoreMax)
    return pmSelectedCase.value.score
  return pmScoreInRange.value ?? pmSelectedCase.value.score
})

const canConfirmPenalty = computed(() => {
  if (isCustomReason.value) return true
  if (!pmSelectedCase.value) return false
  if (pmSelectedCase.value.scoreMin !== pmSelectedCase.value.scoreMax)
    return pmScoreInRange.value !== null
  return true
})

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

const getSeverityIcon = (s) => (s === 'light' ? Wind : s === 'mid' ? ShieldAlert : Flame)

const selectCase = (c) => {
  pmSelectedCase.value = c
}

const resetPenaltyModal = () => {
  pmSelectedCase.value = null
  pmScoreInRange.value = null
  pmCustomScore.value = 50
}

const openPenaltyModal = () => {
  resetPenaltyModal()
  showPenaltyModal.value = true
}
const closePenaltyModal = () => {
  showPenaltyModal.value = false
}

const confirmPenalty = () => {
  confirmedPenalty.value = {
    severity: isCustomReason.value ? customSeverity.value : pmSelectedCase.value.severity,
    severityLabel: isCustomReason.value ? 'กำหนดเอง' : pmSelectedCase.value.severityLabel,
    score: finalPmScore.value,
  }
  showPenaltyModal.value = false
}

const onClickResolve = (reportId) => {
  // ถ้า reason มี penalty config แต่ยังไม่ยืนยัน → เปิด penalty modal ก่อน
  if (hasPenaltyConfig.value && !confirmedPenalty.value) {
    openPenaltyModal()
    return
  }
  updateStatus('RESOLVED')
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
      method: 'GET',
      headers: { 'Content-Type': 'application/json', ...authStore.getAuthHeaders() },
    })
    if (!response.ok) throw new Error(`Failed to fetch reports: ${response.status}`)
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

const viewReport = async (reportId) => {
  loading.value = true
  error.value = null
  try {
    const response = await fetch(`${API_BASE_URL}/reports/${reportId}`, {
      method: 'GET',
      headers: { 'Content-Type': 'application/json', ...authStore.getAuthHeaders() },
    })
    if (!response.ok) throw new Error(`Failed to fetch report details: ${response.status}`)
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

const updateStatus = async (newStatus) => {
  if (!selectedReport.value) return
  updatingStatus.value = true
  updateError.value = null
  updateSuccess.value = null
  try {
    const pointToDecrease =
      newStatus === 'RESOLVED' && confirmedPenalty.value ? confirmedPenalty.value.score : null

    const response = await fetch(
      `${API_BASE_URL}/reports/${selectedReport.value.reportId}/status`,
      {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json', ...authStore.getAuthHeaders() },
        body: JSON.stringify({
          status: newStatus,
          decreasePoint: pointToDecrease,
        }),
      },
    )
    if (!response.ok) throw new Error(`Failed to update status: ${response.status}`)
    const updatedReport = await response.json()
    if (newStatus === 'RESOLVED' && pointToDecrease !== null) {
      if (selectedReport.value.targetUser) {
        selectedReport.value.targetUser.behaviorScore = Math.max(
          0,
          selectedReport.value.targetUser.behaviorScore - pointToDecrease,
        )
      }
    }
    confirmedPenalty.value = null
    resetPenaltyModal()
    selectedReport.value.status = updatedReport.status
    updateSuccess.value =
      pointToDecrease !== null
        ? `สำเร็จ! ยืนยันรายงานและหัก ${pointToDecrease} คะแนน`
        : `สำเร็จ! อัปเดตสถานะเป็น ${newStatus}`
    confirmedPenalty.value = null
    previewTargetScore.value == null
    setTimeout(() => {
      fetchReports()
    }, 1000)
  } catch (err) {
    updateError.value = err.message
  } finally {
    updatingStatus.value = false
  }
}

const closeModal = () => {
  selectedReport.value = null
  confirmedPenalty.value = null
  updateError.value = null
  updateSuccess.value = null
  previewTargetScore.value = null
}

const changePage = (p) => {
  if (p >= 0 && p < totalPages.value) {
    currentPage.value = p
    fetchReports()
  }
}
const formatDate = (d) => {
  if (!d) return 'N/A'
  return new Date(d).toLocaleString('en-US', {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
  })
}

const previewTargetScore = computed(() => {
  if (!selectedReport.value?.targetUser) return 0

  const currentScore = selectedReport.value.targetUser.behaviorScore
  const penalty = finalPmScore.value || 0

  return Math.max(0, currentScore - penalty)
})

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
.id-cell {
  font-family: 'JetBrains Mono', monospace;
  font-size: 0.875rem;
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

.user-icon.target {
  color: var(--color-error);
}

.user-id {
  font-family: 'JetBrains Mono', monospace;
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

.btn-sm {
  padding: 0.5rem 1rem;
  font-size: 0.8125rem;
}

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

.page-total {
  color: var(--text-muted);
  font-size: 0.8125rem;
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
  max-width: 900px;
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

.user-details {
  flex: 1;
}

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
  background: rgba(10, 15, 30, 0.7);
  display: flex;
  align-items: center;
  justify-content: center;
  opacity: 0;
  transition: opacity 0.3s ease;
  color: var(--brand-primary);
}

.evidence-item:hover .evidence-overlay {
  opacity: 1;
}

/* Status Actions */
.status-actions {
  display: flex;
  gap: 0.75rem;
  flex-wrap: wrap;
}

.mono {
  font-family: 'JetBrains Mono', monospace;
}

/* ===== Responsive ===== */
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

  .pagination {
    flex-direction: column;
  }

  .modal {
    margin: 0.5rem;
    max-height: calc(100vh - 1rem);
    border-radius: var(--radius-xl);
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
}

/* ── Confirmed penalty chip ──────────────────────────────── */
.confirmed-penalty-chip {
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.5rem 0.875rem;
  background: rgba(96, 212, 255, 0.06);
  border: 1px solid rgba(96, 212, 255, 0.2);
  border-radius: var(--radius-full);
  font-size: 0.8125rem;
  color: var(--text-secondary);
  margin-bottom: 0.875rem;
  flex-wrap: wrap;
}

.chip-severity {
  font-size: 0.6875rem;
  font-weight: 700;
  padding: 0.2rem 0.5rem;
  border-radius: var(--radius-full);
  text-transform: uppercase;
  letter-spacing: 0.04em;
}

.chip-light {
  background: rgba(74, 222, 128, 0.12);
  color: #4ade80;
  border: 1px solid rgba(74, 222, 128, 0.25);
}

.chip-mid {
  background: rgba(251, 191, 36, 0.12);
  color: #fbbf24;
  border: 1px solid rgba(251, 191, 36, 0.25);
}

.chip-heavy {
  background: rgba(248, 113, 113, 0.12);
  color: #f87171;
  border: 1px solid rgba(248, 113, 113, 0.25);
}

.chip-custom {
  background: rgba(96, 212, 255, 0.12);
  color: var(--brand-primary);
  border: 1px solid rgba(96, 212, 255, 0.25);
}

.chip-score {
  font-family: 'JetBrains Mono', monospace;
  color: var(--text-primary);
  font-size: 0.9375rem;
}

.chip-change {
  display: inline-flex;
  align-items: center;
  gap: 0.25rem;
  background: none;
  border: 1px solid rgba(96, 212, 255, 0.2);
  border-radius: var(--radius-md);
  color: var(--brand-primary);
  font-size: 0.75rem;
  cursor: pointer;
  padding: 0.2rem 0.5rem;
  transition: all 0.15s ease;
}

.chip-change:hover {
  background: rgba(96, 212, 255, 0.08);
}

/* resolve needs penalty */
.btn-needs-penalty {
  background: linear-gradient(135deg, rgba(74, 222, 128, 0.1), rgba(34, 197, 94, 0.05)) !important;
  border: 1px dashed rgba(74, 222, 128, 0.4) !important;
  color: #4ade80 !important;
  box-shadow: none !important;
}

.needs-penalty-hint {
  display: inline-flex;
  align-items: center;
  gap: 0.25rem;
  font-size: 0.7rem;
  opacity: 0.85;
}

/* ══════════════════════════════════════════════
   Penalty Modal
══════════════════════════════════════════════ */
.penalty-overlay {
  z-index: 1100;
  background: rgba(2, 4, 10, 0.92);
}

.penalty-modal {
  max-width: 540px;
  background: var(--bg-surface);
  border-color: rgba(96, 212, 255, 0.15);
}

.penalty-modal-body {
  padding: 1.25rem 1.5rem 1.5rem;
}

/* reason pill */
.pm-reason-chip {
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.375rem 0.875rem;
  background: rgba(96, 212, 255, 0.07);
  border: 1px solid rgba(96, 212, 255, 0.18);
  border-radius: var(--radius-full);
  font-size: 0.8125rem;
  color: var(--text-secondary);
  margin-bottom: 1.25rem;
}

.pm-reason-chip strong {
  color: var(--text-primary);
}

/* steps */
.pm-step {
  margin-bottom: 1.375rem;
}

.pm-step-label {
  display: flex;
  align-items: center;
  gap: 0.625rem;
  font-size: 0.75rem;
  font-weight: 600;
  color: var(--text-muted);
  text-transform: uppercase;
  letter-spacing: 0.06em;
  margin-bottom: 0.75rem;
}

.pm-step-num {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 20px;
  height: 20px;
  border-radius: 50%;
  background: rgba(96, 212, 255, 0.15);
  color: var(--brand-primary);
  font-size: 0.6875rem;
  font-weight: 700;
  flex-shrink: 0;
}

.pm-range-hint {
  font-weight: 700;
  letter-spacing: 0;
  text-transform: none;
}

.hint-light {
  color: #4ade80;
}

.hint-mid {
  color: #fbbf24;
}

.hint-heavy {
  color: #f87171;
}

/* severity buttons */
.pm-severity-grid {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.pm-severity-btn {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 0.875rem;
  width: 100%;
  padding: 0.875rem 1rem;
  border-radius: var(--radius-lg);
  border: 1px solid rgba(99, 118, 148, 0.15);
  background: rgba(20, 30, 46, 0.5);
  cursor: pointer;
  transition: all var(--transition-fast);
  text-align: left;
}

.pm-severity-btn:hover {
  background: rgba(30, 41, 59, 0.7);
  border-color: rgba(99, 118, 148, 0.3);
}

.pm-severity-btn.sev-light:hover {
  border-color: rgba(74, 222, 128, 0.3);
}

.pm-severity-btn.sev-light.active {
  background: rgba(74, 222, 128, 0.07);
  border-color: rgba(74, 222, 128, 0.45);
  box-shadow: 0 0 18px rgba(74, 222, 128, 0.07);
}

.pm-severity-btn.sev-mid:hover {
  border-color: rgba(251, 191, 36, 0.3);
}

.pm-severity-btn.sev-mid.active {
  background: rgba(251, 191, 36, 0.07);
  border-color: rgba(251, 191, 36, 0.45);
  box-shadow: 0 0 18px rgba(251, 191, 36, 0.07);
}

.pm-severity-btn.sev-heavy:hover {
  border-color: rgba(248, 113, 113, 0.3);
}

.pm-severity-btn.sev-heavy.active {
  background: rgba(248, 113, 113, 0.07);
  border-color: rgba(248, 113, 113, 0.45);
  box-shadow: 0 0 18px rgba(248, 113, 113, 0.07);
}

.pm-sev-left {
  display: flex;
  flex-direction: column;
  gap: 0.35rem;
  flex: 1;
  min-width: 0;
}

.pm-sev-right {
  flex-shrink: 0;
}

.sev-badge {
  display: inline-flex;
  align-items: center;
  gap: 0.3rem;
  align-self: flex-start;
  padding: 0.2rem 0.625rem;
  border-radius: var(--radius-full);
  font-size: 0.6875rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.04em;
}

.sev-badge-light {
  background: rgba(74, 222, 128, 0.12);
  color: #4ade80;
  border: 1px solid rgba(74, 222, 128, 0.25);
}

.sev-badge-mid {
  background: rgba(251, 191, 36, 0.12);
  color: #fbbf24;
  border: 1px solid rgba(251, 191, 36, 0.25);
}

.sev-badge-heavy {
  background: rgba(248, 113, 113, 0.12);
  color: #f87171;
  border: 1px solid rgba(248, 113, 113, 0.25);
}

.pm-examples {
  list-style: none;
  padding: 0;
  margin: 0;
  display: flex;
  flex-direction: column;
  gap: 0.15rem;
}

.pm-examples li {
  font-size: 0.8125rem;
  color: var(--text-secondary);
  padding-left: 0.75rem;
  position: relative;
}

.pm-examples li::before {
  content: '·';
  position: absolute;
  left: 0;
  color: var(--text-muted);
}

.pm-range-pill {
  font-size: 0.8rem;
  font-weight: 700;
  padding: 0.3rem 0.75rem;
  border-radius: var(--radius-full);
  font-family: 'JetBrains Mono', monospace;
  transition: all var(--transition-fast);
}

.range-pill-light {
  background: rgba(74, 222, 128, 0.1);
  color: #4ade80;
  border: 1px solid rgba(74, 222, 128, 0.2);
}

.range-pill-mid {
  background: rgba(251, 191, 36, 0.1);
  color: #fbbf24;
  border: 1px solid rgba(251, 191, 36, 0.2);
}

.range-pill-heavy {
  background: rgba(248, 113, 113, 0.1);
  color: #f87171;
  border: 1px solid rgba(248, 113, 113, 0.2);
}

.pm-severity-btn.active .pm-range-pill {
  filter: brightness(1.2);
}

.pm-score-slider-wrap {
  border-radius: var(--radius-lg);
  padding: 1.25rem;
  border: 1px solid transparent;
  align-items: stretch;
}

.slider-wrap-light {
  background: rgba(74, 222, 128, 0.05);
  border-color: rgba(74, 222, 128, 0.15);
}

.slider-wrap-mid {
  background: rgba(251, 191, 36, 0.05);
  border-color: rgba(251, 191, 36, 0.15);
}

.slider-wrap-heavy {
  background: rgba(248, 113, 113, 0.05);
  border-color: rgba(248, 113, 113, 0.15);
}

.pm-score-display-row {
  display: flex;
  align-items: baseline;
  gap: 0.5rem;
  margin-bottom: 0.875rem;
}

.pm-score-big {
  font-size: 2.75rem;
  font-weight: 700;
  font-family: 'JetBrains Mono', monospace;
  line-height: 1;
  transition: color 0.2s ease;
}

.pm-score-unit {
  font-size: 0.875rem;
  color: var(--text-muted);
}

.score-color-light {
  color: #4ade80;
}

.score-color-mid {
  color: #fbbf24;
}

.score-color-heavy {
  color: #f87171;
}

.score-color-custom {
  color: var(--brand-primary);
}

.score-diff-badge {
  font-size: 0.75rem;
  padding: 0.1rem 0.4rem;
  background: rgba(248, 113, 113, 0.1);
  color: #f87171;
  border-radius: 4px;
  font-weight: 600;
  margin-left: 0.25rem;
}

.score-preview-text {
  display: inline-flex;
  align-items: center;
  gap: 0.25rem;
  margin-left: 0.5rem;
  font-weight: 700;
  animation: fadeIn 0.3s ease;
}

.score-preview-wrap {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.new-score {
  font-size: 1.15rem;
  font-weight: 800;
  border-bottom: 2px solid currentColor;
  padding-bottom: 1px;
}

.text-light {
  color: #4ade80;
}

.text-mid {
  color: #fbbf24;
}

.text-heavy {
  color: #f87171;
}

.preview-fade-enter-active,
.preview-fade-leave-active {
  transition: all 0.2s ease;
}

.preview-fade-enter-from,
.preview-fade-leave-to {
  opacity: 0;
  transform: translateX(-5px);
}

.pm-score-tick-row {
  display: flex;
  justify-content: space-between;
  margin-top: 0.375rem;
  font-size: 0.6875rem;
  color: var(--text-muted);
  font-family: 'JetBrains Mono', monospace;
  width: 100%;
  margin-top: -0.5rem;
}

.pm-quick-scores {
  display: flex;
  gap: 0.375rem;
  margin-top: 0.75rem;
  flex-wrap: wrap;
}

.pm-qs-btn {
  padding: 0.3rem 0.75rem;
  border-radius: var(--radius-md);
  font-size: 0.8125rem;
  font-family: 'JetBrains Mono', monospace;
  cursor: pointer;
  transition: all 0.15s ease;
  background: rgba(30, 41, 59, 0.4);
  border: 1px solid rgba(99, 118, 148, 0.2);
  color: var(--text-secondary);
}

.pm-qs-btn:hover {
  border-color: rgba(99, 118, 148, 0.4);
  color: var(--text-primary);
}

.qs-light.active {
  background: rgba(74, 222, 128, 0.1);
  border-color: rgba(74, 222, 128, 0.4);
  color: #4ade80;
  font-weight: 600;
}

.qs-mid.active {
  background: rgba(251, 191, 36, 0.1);
  border-color: rgba(251, 191, 36, 0.4);
  color: #fbbf24;
  font-weight: 600;
}

.qs-heavy.active {
  background: rgba(248, 113, 113, 0.1);
  border-color: rgba(248, 113, 113, 0.4);
  color: #f87171;
  font-weight: 600;
}

.pm-fixed-score-box {
  display: inline-flex;
  align-items: baseline;
  gap: 0.625rem;
  padding: 0.875rem 1.25rem;
  border-radius: var(--radius-lg);
  border: 1px solid transparent;
}

.fixed-heavy {
  background: rgba(248, 113, 113, 0.07);
  border-color: rgba(248, 113, 113, 0.2);
}

.fixed-mid {
  background: rgba(251, 191, 36, 0.07);
  border-color: rgba(251, 191, 36, 0.2);
}

.fixed-light {
  background: rgba(74, 222, 128, 0.07);
  border-color: rgba(74, 222, 128, 0.2);
}

.pm-fixed-label {
  font-size: 0.6875rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.06em;
  color: var(--text-muted);
  margin-left: 0.25rem;
}

.pm-custom-block {
  background: rgba(15, 22, 36, 0.5);
  border: 1px solid rgba(96, 212, 255, 0.1);
  border-radius: var(--radius-lg);
  padding: 1rem 1.125rem;
}

.pm-custom-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 0.875rem;
}

.pm-custom-label {
  font-size: 0.8125rem;
  color: var(--text-muted);
}

.pm-custom-score-row {
  display: flex;
  align-items: baseline;
  gap: 0.375rem;
}

.slider-ticks {
  display: flex;
  justify-content: space-between;
  margin-top: 0.375rem;
  font-size: 0.6875rem;
  color: var(--text-muted);
  font-family: 'JetBrains Mono', monospace;
}

.custom-severity-tags {
  display: flex;
  gap: 0.375rem;
  margin-top: 0.75rem;
  flex-wrap: wrap;
}

.csev-tag {
  font-size: 0.6875rem;
  font-weight: 600;
  padding: 0.2rem 0.625rem;
  border-radius: var(--radius-full);
}

.csev-light {
  background: rgba(74, 222, 128, 0.1);
  color: #4ade80;
  border: 1px solid rgba(74, 222, 128, 0.2);
}

.csev-mid {
  background: rgba(251, 191, 36, 0.1);
  color: #fbbf24;
  border: 1px solid rgba(251, 191, 36, 0.2);
}

.csev-heavy {
  background: rgba(248, 113, 113, 0.1);
  color: #f87171;
  border: 1px solid rgba(248, 113, 113, 0.2);
}

.penalty-slider {
  width: 100%;
  appearance: none;
  -webkit-appearance: none;
  /* สำหรับ Chrome/Safari */
  height: 6px;
  border-radius: 3px;
  background: rgba(99, 118, 148, 0.25);
  outline: none;
  cursor: pointer;

  border: none !important;
  padding: 0 !important;
  margin: 1.5rem 0 1rem 0;
  box-shadow: none !important;
}

.penalty-slider::-webkit-slider-thumb {
  appearance: none;
  width: 18px;
  height: 18px;
  border-radius: 50%;
  background: var(--brand-primary);
  border: 2px solid var(--bg-surface);
  box-shadow: 0 0 8px rgba(96, 212, 255, 0.4);
  cursor: pointer;
  transition: transform 0.1s ease;
}

.penalty-slider::-webkit-slider-thumb:hover {
  transform: scale(1.15);
}

.slider-light::-webkit-slider-thumb {
  background: #4ade80;
  box-shadow: 0 0 8px rgba(74, 222, 128, 0.5);
}

.slider-mid::-webkit-slider-thumb {
  background: #fbbf24;
  box-shadow: 0 0 8px rgba(251, 191, 36, 0.5);
}

.slider-heavy::-webkit-slider-thumb {
  background: #f87171;
  box-shadow: 0 0 8px rgba(248, 113, 113, 0.5);
}

.slider-light::-moz-range-thumb {
  background: #4ade80;
}

.slider-mid::-moz-range-thumb {
  background: #fbbf24;
}

.slider-heavy::-moz-range-thumb {
  background: #f87171;
}

.pm-preview {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.75rem 1rem;
  border-radius: var(--radius-lg);
  border: 1px solid transparent;
  font-size: 0.8125rem;
  flex-wrap: wrap;
  margin-top: 0.25rem;
}

.preview-light {
  background: rgba(74, 222, 128, 0.07);
  border-color: rgba(74, 222, 128, 0.2);
  color: #4ade80;
}

.preview-mid {
  background: rgba(251, 191, 36, 0.07);
  border-color: rgba(251, 191, 36, 0.2);
  color: #fbbf24;
}

.preview-heavy {
  background: rgba(248, 113, 113, 0.07);
  border-color: rgba(248, 113, 113, 0.2);
  color: #f87171;
}

.preview-custom {
  background: rgba(96, 212, 255, 0.06);
  border-color: rgba(96, 212, 255, 0.15);
  color: var(--brand-primary);
}

.pm-preview-score {
  font-size: 1.125rem;
  font-weight: 700;
  font-family: 'JetBrains Mono', monospace;
}

.step2-enter-active,
.step2-leave-active {
  transition:
    opacity 0.25s ease,
    transform 0.25s ease;
}

.step2-enter-from,
.step2-leave-to {
  opacity: 0;
  transform: translateY(-8px);
}

.preview-fade-enter-active,
.preview-fade-leave-active {
  transition: opacity 0.2s ease;
}

.preview-fade-enter-from,
.preview-fade-leave-to {
  opacity: 0;
}

.pm-footer {
  display: flex;
  justify-content: flex-end;
  gap: 0.625rem;
  padding-top: 1rem;
  border-top: 1px solid var(--divider);
  margin-top: 0.75rem;
}

.status-locked-notice {
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.625rem 1rem;
  background: rgba(248, 113, 113, 0.08);
  /* สีแดงอ่อนๆ บางๆ */
  border: 1px solid rgba(248, 113, 113, 0.2);
  border-radius: var(--radius-md);
  color: #f87171;
  font-size: 0.8125rem;
  font-style: italic;
  animation: fadeIn 0.4s ease;
}

.status-locked-notice span {
  font-weight: 500;
}

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

  .pagination {
    flex-direction: column;
  }

  .modal {
    margin: 0.5rem;
    max-height: calc(100vh - 1rem);
    border-radius: var(--radius-xl);
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

  .penalty-modal {
    max-width: 100%;
  }

  .pm-severity-btn {
    flex-direction: column;
    align-items: flex-start;
    gap: 0.5rem;
  }

  .pm-footer .btn {
    flex: 1;
  }
}
</style>
