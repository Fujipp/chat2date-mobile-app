<script setup>
import {
  AlertTriangle,
  ArrowUpDown,
  Badge,
  Calendar,
  CheckCircle,
  Eye,
  Filter,
  Hash,
  Loader2,
  Mail,
  Pencil,
  Phone,
  RefreshCw,
  RotateCw,
  Save,
  Search,
  Shield,
  ShieldOff,
  Trash2,
  Undo2,
  UserCircle,
  Users,
  X,
} from 'lucide-vue-next'
import { computed, onMounted, ref } from 'vue'
import { userApi } from '../services/api'

const users = ref([])
const loading = ref(false)
const error = ref(null)
const searchQuery = ref('')
const roleFilter = ref('')
const statusFilter = ref('')
const blacklistFilter = ref('')
const deletionFilter = ref('')
const sortField = ref('name')
const sortDirection = ref('ASC')

const selectedUser = ref(null)
const selectedUserLoading = ref(false)
const selectedUserError = ref(null)
const selectedUserNotice = ref(null)
const selectedUserNoticeTone = ref('success')
const editForm = ref(null)
const originalSnapshot = ref(null)
const userDeletionStatus = ref(null)
const saving = ref(false)

const showConfirmModal = ref(false)
const pendingAction = ref(null)
const actionLoading = ref(false)
const actionError = ref(null)

const roleOptions = ['USER', 'ADMIN']
const statusOptions = ['ACTIVE', 'SUSPENDED', 'PENDING']
const providerOptions = ['GOOGLE', 'OTP']
const sexOptions = ['MALE', 'FEMALE']

const normalizeUser = (user) => ({
  ...user,
  isBlacklist: Boolean(user?.isBlacklist),
  deleteFlag: Boolean(user?.deleteFlag),
  birthday: user?.birthday ? String(user.birthday).slice(0, 10) : '',
  deletedAt: user?.deletedAt || null,
})

const makeEditForm = (user) => {
  if (!user) return null
  return {
    ...normalizeUser(user),
  }
}

const formatDateTime = (value) => {
  if (!value) return '—'
  const date = new Date(value)
  if (Number.isNaN(date.getTime())) return value
  return date.toLocaleString('en-GB', {
    timeZone: 'Asia/Bangkok',
    year: 'numeric',
    month: 'short',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit',
    hour12: false,
  })
}

const formatDateOnly = (value) => {
  if (!value) return '—'
  const date = new Date(`${String(value).slice(0, 10)}T00:00:00`)
  if (Number.isNaN(date.getTime())) return value
  return date.toLocaleDateString('en-GB', {
    timeZone: 'Asia/Bangkok',
    year: 'numeric',
    month: 'short',
    day: '2-digit',
  })
}

const fullName = (user) => {
  if (!user) return '—'
  return [user.firstname, user.lastname].filter(Boolean).join(' ') || user.nickname || '—'
}

const roleLabel = (role) => (role ? role.toLowerCase() : '—')
const providerLabel = (provider) => (provider ? provider.toLowerCase() : '—')

const getRoleClass = (role) => {
  if (role === 'ADMIN') return 'badge-admin'
  return 'badge-user'
}

const getStatusClass = (status) => {
  const map = {
    ACTIVE: 'badge-success',
    SUSPENDED: 'badge-error',
    PENDING: 'badge-pending',
  }
  return map[status] || 'badge-info'
}

const getBinaryClass = (value) => (value ? 'badge-success' : 'badge-dismissed')

const stats = computed(() => {
  const total = users.value.length
  const admins = users.value.filter((user) => user.role === 'ADMIN').length
  const active = users.value.filter((user) => user.accountStatus === 'ACTIVE').length
  const suspended = users.value.filter((user) => user.accountStatus === 'SUSPENDED').length
  const deleted = users.value.filter((user) => user.deleteFlag).length
  const blacklisted = users.value.filter((user) => user.isBlacklist).length
  return { total, admins, active, suspended, deleted, blacklisted }
})

const filteredUsers = computed(() => {
  const query = searchQuery.value.trim().toLowerCase()

  const matchesText = (user) => {
    if (!query) return true
    const haystack = [
      user.userId,
      user.firstname,
      user.lastname,
      user.nickname,
      user.email,
      user.phoneNumber,
      user.cardId,
      user.provider,
      user.role,
      user.accountStatus,
      user.sex,
    ]
      .filter(Boolean)
      .join(' ')
      .toLowerCase()
    return haystack.includes(query)
  }

  const matchesRole = (user) => !roleFilter.value || user.role === roleFilter.value
  const matchesStatus = (user) => !statusFilter.value || user.accountStatus === statusFilter.value
  const matchesBlacklist = (user) => {
    if (!blacklistFilter.value) return true
    return blacklistFilter.value === 'true' ? user.isBlacklist : !user.isBlacklist
  }
  const matchesDeletion = (user) => {
    if (!deletionFilter.value) return true
    return deletionFilter.value === 'true' ? user.deleteFlag : !user.deleteFlag
  }

  const sortValue = (user) => {
    switch (sortField.value) {
      case 'score':
        return Number(user.behaviorScore ?? 0)
      case 'role':
        return user.role || ''
      case 'status':
        return user.accountStatus || ''
      case 'name':
      default:
        return `${user.firstname || ''} ${user.lastname || ''}`.trim().toLowerCase()
    }
  }

  return [...users.value]
    .filter(matchesText)
    .filter(matchesRole)
    .filter(matchesStatus)
    .filter(matchesBlacklist)
    .filter(matchesDeletion)
    .sort((a, b) => {
      const av = sortValue(a)
      const bv = sortValue(b)
      if (av === bv) return 0
      const direction = sortDirection.value === 'ASC' ? 1 : -1
      if (typeof av === 'number' && typeof bv === 'number') {
        return av > bv ? direction : -direction
      }
      return String(av).localeCompare(String(bv), 'en', { sensitivity: 'base' }) * direction
    })
})

const hasEditChanges = computed(() => {
  if (!editForm.value || !originalSnapshot.value) return false
  const fieldsToCompare = [
    'firstname',
    'lastname',
    'nickname',
    'email',
    'phoneNumber',
    'cardId',
    'birthday',
    'provider',
    'sex',
    'role',
    'accountStatus',
    'isBlacklist',
    'isTutorial',
  ]

  return fieldsToCompare.some((field) => String(editForm.value[field] ?? '') !== String(originalSnapshot.value[field] ?? ''))
})

const canSaveUser = computed(() => {
  if (!selectedUser.value || !editForm.value) return false
  if (selectedUser.value.deleteFlag) return false
  return hasEditChanges.value && !saving.value && !selectedUserLoading.value
})

const confirmActionTitle = computed(() => {
  if (!pendingAction.value) return ''
  return pendingAction.value.type === 'delete' ? 'Delete user account?' : 'Restore user account?'
})

const confirmActionDescription = computed(() => {
  if (!pendingAction.value?.user) return ''
  const user = pendingAction.value.user
  if (pendingAction.value.type === 'delete') {
    if (user.role === 'ADMIN') {
      return 'This is an ADMIN account. Deleting it will permanently remove the account from the system.'
    }
    return 'This account will be soft-deleted. It can still be restored later if it is within the restore window.'
  }

  if (userDeletionStatus.value?.canRestore === false) {
    return 'This deleted account is outside the restore window and may no longer be recoverable.'
  }

  return 'This will restore the deleted account and make it active again.'
})

const confirmActionLabel = computed(() => {
  if (!pendingAction.value) return 'Confirm'
  return pendingAction.value.type === 'delete' ? 'Delete' : 'Restore'
})

const confirmActionClass = computed(() => {
  if (!pendingAction.value) return 'btn-primary'
  return pendingAction.value.type === 'delete' ? 'btn-danger' : 'btn-primary'
})

const fetchUsers = async () => {
  loading.value = true
  error.value = null
  try {
    const data = await userApi.getAll()
    users.value = Array.isArray(data) ? data.map(normalizeUser) : []
  } catch (err) {
    error.value = err.message || 'Failed to load users'
  } finally {
    loading.value = false
  }
}

const loadUserDetail = async (userId) => {
  selectedUserLoading.value = true
  selectedUserError.value = null
  selectedUserNotice.value = null
  actionError.value = null
  try {
    const data = await userApi.getById(userId)
    const normalized = normalizeUser(data)
    selectedUser.value = normalized
    editForm.value = makeEditForm(normalized)
    originalSnapshot.value = makeEditForm(normalized)
    userDeletionStatus.value = normalized.deleteFlag ? await userApi.getDeletionStatus(userId) : null
  } catch (err) {
    selectedUserError.value = err.message || 'Failed to load user detail'
  } finally {
    selectedUserLoading.value = false
  }
}

const openUserDetail = async (userId) => {
  const current = users.value.find((user) => user.userId === userId)
  selectedUser.value = current ? normalizeUser(current) : { userId }
  editForm.value = current ? makeEditForm(current) : null
  originalSnapshot.value = current ? makeEditForm(current) : null
  userDeletionStatus.value = current?.deleteFlag ? null : null
  selectedUserLoading.value = true
  selectedUserError.value = null
  selectedUserNotice.value = null
  await loadUserDetail(userId)
}

const closeUserModal = () => {
  selectedUser.value = null
  editForm.value = null
  originalSnapshot.value = null
  userDeletionStatus.value = null
  selectedUserLoading.value = false
  selectedUserError.value = null
  selectedUserNotice.value = null
  saving.value = false
}

const saveUserChanges = async () => {
  if (!selectedUser.value || !editForm.value || !canSaveUser.value) return

  saving.value = true
  selectedUserError.value = null
  selectedUserNotice.value = null

  try {
    const payload = {
      ...editForm.value,
      birthday: editForm.value.birthday || null,
    }

    const updated = normalizeUser(await userApi.updateById(selectedUser.value.userId, payload))
    selectedUser.value = updated
    editForm.value = makeEditForm(updated)
    originalSnapshot.value = makeEditForm(updated)
    selectedUserNoticeTone.value = 'success'
    selectedUserNotice.value = 'User profile updated successfully.'
    await fetchUsers()
  } catch (err) {
    selectedUserNoticeTone.value = 'error'
    selectedUserNotice.value = err.message || 'Failed to update user'
  } finally {
    saving.value = false
  }
}

const openDeleteConfirm = (user) => {
  pendingAction.value = { type: 'delete', user: normalizeUser(user) }
  actionError.value = null
  showConfirmModal.value = true
}

const openRestoreConfirm = (user) => {
  pendingAction.value = { type: 'restore', user: normalizeUser(user) }
  actionError.value = null
  showConfirmModal.value = true
}

const closeConfirmModal = () => {
  if (actionLoading.value) return
  showConfirmModal.value = false
  pendingAction.value = null
  actionError.value = null
}

const refreshSelectedUserAfterAction = async (userId) => {
  if (!selectedUser.value || selectedUser.value.userId !== userId) return
  await loadUserDetail(userId)
}

const confirmPendingAction = async () => {
  if (!pendingAction.value) return

  actionLoading.value = true
  actionError.value = null
  try {
    const { type, user } = pendingAction.value
    if (type === 'delete') {
      await userApi.deleteById(user.userId)
    } else {
      await userApi.restoreById(user.userId)
    }

    showConfirmModal.value = false
    pendingAction.value = null
    await fetchUsers()
    await refreshSelectedUserAfterAction(user.userId)

    if (selectedUser.value?.userId === user.userId) {
      selectedUserNoticeTone.value = 'success'
      selectedUserNotice.value =
        type === 'delete'
          ? 'User account has been deleted.'
          : 'User account has been restored.'
    }
  } catch (err) {
    actionError.value = err.message || 'Action failed'
  } finally {
    actionLoading.value = false
  }
}

onMounted(fetchUsers)
</script>

<template>
  <div class="user-management-view">
    <div class="page-header">
      <div class="header-text">
        <div class="header-title">
          <div class="header-icon-wrap">
            <Users :size="28" :stroke-width="2" />
          </div>
          <div>
            <h1>User Management</h1>
            <p class="text-muted" style="margin: 0; font-size: 0.9rem">
              Manage users through the backend <code>/users</code> API.
            </p>
          </div>
        </div>
      </div>

      <div class="header-actions">
        <button class="btn btn-outline" :disabled="loading" @click="fetchUsers">
          <RotateCw :size="16" />
          Refresh
        </button>
      </div>
    </div>

    <div class="stats-grid">
      <div class="stat-card stat-total">
        <div class="stat-icon">
          <Users :size="20" :stroke-width="2" />
        </div>
        <div class="stat-content">
          <span class="stat-label">Total</span>
          <span class="stat-value">{{ stats.total }}</span>
        </div>
      </div>

      <div class="stat-card stat-active">
        <div class="stat-icon">
          <CheckCircle :size="20" :stroke-width="2" />
        </div>
        <div class="stat-content">
          <span class="stat-label">Active</span>
          <span class="stat-value">{{ stats.active }}</span>
        </div>
      </div>

      <div class="stat-card stat-suspended">
        <div class="stat-icon">
          <ShieldOff :size="20" :stroke-width="2" />
        </div>
        <div class="stat-content">
          <span class="stat-label">Suspended</span>
          <span class="stat-value">{{ stats.suspended }}</span>
        </div>
      </div>

      <div class="stat-card stat-admin">
        <div class="stat-icon">
          <Shield :size="20" :stroke-width="2" />
        </div>
        <div class="stat-content">
          <span class="stat-label">Admins</span>
          <span class="stat-value">{{ stats.admins }}</span>
        </div>
      </div>

      <div class="stat-card stat-deleted">
        <div class="stat-icon">
          <Trash2 :size="20" :stroke-width="2" />
        </div>
        <div class="stat-content">
          <span class="stat-label">Deleted</span>
          <span class="stat-value">{{ stats.deleted }}</span>
        </div>
      </div>

      <div class="stat-card stat-blacklist">
        <div class="stat-icon">
          <AlertTriangle :size="20" :stroke-width="2" />
        </div>
        <div class="stat-content">
          <span class="stat-label">Blacklisted</span>
          <span class="stat-value">{{ stats.blacklisted }}</span>
        </div>
      </div>
    </div>

    <div class="filters-card">
      <div class="filter-grid">
        <div class="filter-group search-group">
          <label>
            <Search :size="14" />
            Search
          </label>
          <input
            v-model="searchQuery"
            type="text"
            placeholder="Search by name, email, phone, user ID..."
          />
        </div>

        <div class="filter-group">
          <label>
            <Filter :size="14" />
            Role
          </label>
          <select v-model="roleFilter">
            <option value="">All roles</option>
            <option v-for="role in roleOptions" :key="role" :value="role">
              {{ role }}
            </option>
          </select>
        </div>

        <div class="filter-group">
          <label>
            <Badge :size="14" />
            Status
          </label>
          <select v-model="statusFilter">
            <option value="">All statuses</option>
            <option v-for="status in statusOptions" :key="status" :value="status">
              {{ status }}
            </option>
          </select>
        </div>

        <div class="filter-group">
          <label>
            <Shield :size="14" />
            Blacklist
          </label>
          <select v-model="blacklistFilter">
            <option value="">All users</option>
            <option value="false">Not blacklisted</option>
            <option value="true">Blacklisted</option>
          </select>
        </div>

        <div class="filter-group">
          <label>
            <Trash2 :size="14" />
            Deleted
          </label>
          <select v-model="deletionFilter">
            <option value="">All users</option>
            <option value="false">Not deleted</option>
            <option value="true">Deleted</option>
          </select>
        </div>

        <div class="filter-group">
          <label>
            <ArrowUpDown :size="14" />
            Sort
          </label>
          <div class="sort-row">
            <select v-model="sortField">
              <option value="name">Name</option>
              <option value="role">Role</option>
              <option value="status">Status</option>
              <option value="score">Behavior Score</option>
            </select>
            <button class="btn btn-outline sort-direction-btn" type="button" @click="sortDirection = sortDirection === 'ASC' ? 'DESC' : 'ASC'">
              {{ sortDirection === 'ASC' ? 'ASC' : 'DESC' }}
            </button>
          </div>
        </div>
      </div>
    </div>

    <div v-if="loading" class="loading-state">
      <Loader2 :size="42" :stroke-width="2" class="spinner" />
      <p>Loading users...</p>
    </div>

    <div v-else-if="error" class="error-state">
      <AlertTriangle :size="42" :stroke-width="2" class="error-icon" />
      <p>{{ error }}</p>
      <button class="btn btn-outline" @click="fetchUsers">
        <RefreshCw :size="16" />
        Try Again
      </button>
    </div>

    <div v-else class="table-container user-table-container">
      <table>
        <thead>
          <tr>
            <th><Hash :size="14" /> ID</th>
            <th><UserCircle :size="14" /> User</th>
            <th><Mail :size="14" /> Contact</th>
            <th><Badge :size="14" /> Role</th>
            <th><Shield :size="14" /> Status</th>
            <th><AlertTriangle :size="14" /> Flags</th>
            <th><CheckCircle :size="14" /> Score</th>
            <th><Calendar :size="14" /> Deleted</th>
            <th><Eye :size="14" /> Actions</th>
          </tr>
        </thead>
        <tbody>
          <tr v-if="filteredUsers.length === 0">
            <td colspan="9" class="text-center text-muted">
              <div class="empty-state">
                <Users :size="40" :stroke-width="1.5" />
                <p>No users found</p>
              </div>
            </td>
          </tr>

          <tr v-for="user in filteredUsers" :key="user.userId">
            <td>
              <strong class="mono">#{{ user.userId.slice(0, 8) }}</strong>
            </td>
            <td>
              <div class="user-cell">
                <div class="avatar-circle">
                  <UserCircle :size="16" />
                </div>
                <div>
                  <div class="user-name">{{ fullName(user) }}</div>
                  <div class="user-subtext">{{ user.nickname || '—' }}</div>
                </div>
              </div>
            </td>
            <td>
              <div class="contact-cell">
                <span class="mono">{{ user.email || '—' }}</span>
                <span class="muted-line">{{ user.phoneNumber || '—' }}</span>
              </div>
            </td>
            <td>
              <span :class="['badge', getRoleClass(user.role)]">{{ roleLabel(user.role) }}</span>
            </td>
            <td>
              <span :class="['badge', getStatusClass(user.accountStatus)]">
                {{ user.accountStatus }}
              </span>
            </td>
            <td>
              <div class="flag-stack">
                <span :class="['badge', getBinaryClass(user.isBlacklist)]">
                  {{ user.isBlacklist ? 'Blacklisted' : 'Normal' }}
                </span>
                <span :class="['badge', getBinaryClass(user.isTutorial)]">
                  Tutorial {{ user.isTutorial ? 'On' : 'Off' }}
                </span>
              </div>
            </td>
            <td>
              <span class="score-pill">{{ user.behaviorScore ?? 0 }}</span>
            </td>
            <td>
              <div class="deleted-cell">
                <span :class="['badge', user.deleteFlag ? 'badge-error' : 'badge-dismissed']">
                  {{ user.deleteFlag ? 'Deleted' : 'Active' }}
                </span>
                <span class="deleted-meta">{{ user.deleteFlag ? formatDateTime(user.deletedAt) : '—' }}</span>
              </div>
            </td>
            <td>
              <div class="row-actions">
                <button class="btn btn-outline btn-sm" @click="openUserDetail(user.userId)">
                  <Eye :size="14" />
                  View
                </button>
                <button class="btn btn-outline btn-sm" @click="openUserDetail(user.userId)">
                  <Pencil :size="14" />
                  Edit
                </button>
                <button
                  v-if="!user.deleteFlag"
                  class="btn btn-danger btn-sm"
                  @click="openDeleteConfirm(user)"
                >
                  <Trash2 :size="14" />
                  Delete
                </button>
                <button
                  v-else
                  class="btn btn-primary btn-sm"
                  @click="openRestoreConfirm(user)"
                >
                  <Undo2 :size="14" />
                  Restore
                </button>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <div v-if="selectedUser" class="modal-overlay" @click.self="closeUserModal">
      <div class="modal user-modal">
        <div class="modal-header">
          <div class="modal-title">
            <Users :size="22" />
            <h2>User Detail · {{ selectedUser.userId?.slice(0, 8) }}</h2>
          </div>
          <button class="btn-close" @click="closeUserModal">
            <X :size="22" />
          </button>
        </div>

        <div class="modal-body user-modal-body">
          <div v-if="selectedUserLoading" class="detail-loading">
            <Loader2 :size="36" :stroke-width="2" class="spinner" />
            <p>Loading user detail...</p>
          </div>

          <div v-else>
            <p v-if="selectedUserError" class="text-error modal-message">
              <AlertTriangle :size="14" /> {{ selectedUserError }}
            </p>
            <p
              v-if="selectedUserNotice"
              :class="['modal-message', selectedUserNoticeTone === 'success' ? 'text-success' : 'text-error']"
            >
              <CheckCircle v-if="selectedUserNoticeTone === 'success'" :size="14" />
              <AlertTriangle v-else :size="14" />
              {{ selectedUserNotice }}
            </p>

            <div class="user-detail-grid">
              <section class="detail-card overview-card">
                <div class="detail-card-header">
                  <h3>Overview</h3>
                  <div class="detail-badges">
                    <span :class="['badge', getRoleClass(selectedUser.role)]">
                      {{ roleLabel(selectedUser.role) }}
                    </span>
                    <span :class="['badge', getStatusClass(selectedUser.accountStatus)]">
                      {{ selectedUser.accountStatus }}
                    </span>
                  </div>
                </div>

                <div class="info-list">
                  <div class="info-item">
                    <span class="info-label">Name</span>
                    <span class="info-value">{{ fullName(selectedUser) }}</span>
                  </div>
                  <div class="info-item">
                    <span class="info-label">Nickname</span>
                    <span class="info-value">{{ selectedUser.nickname || '—' }}</span>
                  </div>
                  <div class="info-item">
                    <span class="info-label">Email</span>
                    <span class="info-value">{{ selectedUser.email || '—' }}</span>
                  </div>
                  <div class="info-item">
                    <span class="info-label">Phone</span>
                    <span class="info-value">{{ selectedUser.phoneNumber || '—' }}</span>
                  </div>
                  <div class="info-item">
                    <span class="info-label">Provider</span>
                    <span class="info-value">{{ providerLabel(selectedUser.provider) }}</span>
                  </div>
                  <div class="info-item">
                    <span class="info-label">Sex</span>
                    <span class="info-value">{{ selectedUser.sex || '—' }}</span>
                  </div>
                  <div class="info-item">
                    <span class="info-label">Birthday</span>
                    <span class="info-value">{{ formatDateOnly(selectedUser.birthday) }}</span>
                  </div>
                  <div class="info-item">
                    <span class="info-label">Behavior score</span>
                    <span class="info-value score-pill inline">{{ selectedUser.behaviorScore ?? 0 }}</span>
                  </div>
                  <div class="info-item">
                    <span class="info-label">Card ID</span>
                    <span class="info-value mono">{{ selectedUser.cardId || '—' }}</span>
                  </div>
                  <div class="info-item">
                    <span class="info-label">Version</span>
                    <span class="info-value mono">{{ selectedUser.version ?? '—' }}</span>
                  </div>
                </div>

                <div class="deletion-summary" v-if="selectedUser.deleteFlag">
                  <div class="deletion-summary-title">
                    <Trash2 :size="16" />
                    Deleted account
                  </div>
                  <p>
                    Deleted at: <strong>{{ formatDateTime(selectedUser.deletedAt) }}</strong>
                  </p>
                  <p v-if="userDeletionStatus">
                    Restore window:
                    <strong>
                      {{ userDeletionStatus.canRestore ? `${userDeletionStatus.daysRemaining} day(s) left` : 'Expired' }}
                    </strong>
                  </p>
                </div>
              </section>

              <section class="detail-card edit-card">
                <div class="detail-card-header">
                  <h3>Edit Profile</h3>
                  <span v-if="hasEditChanges" class="changes-pill">Unsaved changes</span>
                </div>

                <form class="edit-form" @submit.prevent="saveUserChanges">
                  <div class="form-grid">
                    <label>
                      First name
                      <input v-model="editForm.firstname" type="text" />
                    </label>
                    <label>
                      Last name
                      <input v-model="editForm.lastname" type="text" />
                    </label>
                    <label>
                      Nickname
                      <input v-model="editForm.nickname" type="text" />
                    </label>
                    <label>
                      Email
                      <input v-model="editForm.email" type="email" />
                    </label>
                    <label>
                      Phone number
                      <input v-model="editForm.phoneNumber" type="text" />
                    </label>
                    <label>
                      Card ID
                      <input v-model="editForm.cardId" type="text" />
                    </label>
                    <label>
                      Birthday
                      <input v-model="editForm.birthday" type="date" />
                    </label>
                    <label>
                      Provider
                      <select v-model="editForm.provider">
                        <option v-for="provider in providerOptions" :key="provider" :value="provider">
                          {{ provider }}
                        </option>
                      </select>
                    </label>
                    <label>
                      Sex
                      <select v-model="editForm.sex">
                        <option v-for="sex in sexOptions" :key="sex" :value="sex">
                          {{ sex }}
                        </option>
                      </select>
                    </label>
                    <label>
                      Role
                      <select v-model="editForm.role">
                        <option v-for="role in roleOptions" :key="role" :value="role">
                          {{ role }}
                        </option>
                      </select>
                    </label>
                    <label>
                      Account status
                      <select v-model="editForm.accountStatus">
                        <option v-for="status in statusOptions" :key="status" :value="status">
                          {{ status }}
                        </option>
                      </select>
                    </label>
                  </div>

                  <div class="toggle-grid">
                    <label class="toggle-item">
                      <input v-model="editForm.isBlacklist" type="checkbox" />
                      <span>
                        <strong>Blacklist</strong>
                        <small>Block the user from matchmaking</small>
                      </span>
                    </label>
                    <label class="toggle-item">
                      <input v-model="editForm.isTutorial" type="checkbox" />
                      <span>
                        <strong>Tutorial completed</strong>
                        <small>Mark onboarding as finished</small>
                      </span>
                    </label>
                  </div>

                  <p v-if="selectedUser.deleteFlag" class="warning-note">
                    <AlertTriangle :size="14" />
                    Deleted accounts should be restored before editing.
                  </p>

                  <div class="form-actions">
                    <button class="btn btn-outline" type="button" @click="closeUserModal">
                      Close
                    </button>
                    <button
                      v-if="!selectedUser.deleteFlag"
                      class="btn btn-primary"
                      type="submit"
                      :disabled="!canSaveUser"
                    >
                      <Save :size="16" />
                      {{ saving ? 'Saving...' : 'Save changes' }}
                    </button>
                  </div>
                </form>
              </section>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div v-if="showConfirmModal && pendingAction" class="modal-overlay" @click.self="closeConfirmModal">
      <div class="modal confirm-modal">
        <div class="modal-header">
          <div class="modal-title">
            <AlertTriangle :size="22" />
            <h2>{{ confirmActionTitle }}</h2>
          </div>
          <button class="btn-close" @click="closeConfirmModal">
            <X :size="22" />
          </button>
        </div>

        <div class="modal-body">
          <p class="confirm-description">
            {{ confirmActionDescription }}
          </p>

          <div v-if="actionError" class="confirm-error text-error">
            <AlertTriangle :size="14" />
            {{ actionError }}
          </div>

          <div class="confirm-meta">
            <div>
              <span class="confirm-label">Target user</span>
              <strong>{{ fullName(pendingAction.user) }}</strong>
            </div>
            <div>
              <span class="confirm-label">Account</span>
              <strong>{{ pendingAction.user.role }} · {{ pendingAction.user.accountStatus }}</strong>
            </div>
          </div>
        </div>

        <div class="modal-footer">
          <button class="btn btn-outline" type="button" :disabled="actionLoading" @click="closeConfirmModal">
            Cancel
          </button>
          <button
            :class="['btn', confirmActionClass]"
            type="button"
            :disabled="actionLoading"
            @click="confirmPendingAction"
          >
            <Loader2 v-if="actionLoading" :size="16" class="spinner-inline" />
            <component :is="pendingAction.type === 'delete' ? Trash2 : Undo2" :size="16" />
            {{ actionLoading ? 'Processing...' : confirmActionLabel }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.user-management-view {
  padding: 2rem;
  max-width: 1480px;
  margin: 0 auto;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 1.5rem;
  margin-bottom: 1.5rem;
  flex-wrap: wrap;
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
  box-shadow: var(--shadow-glow-sm);
}

.header-actions {
  display: flex;
  gap: 0.75rem;
  align-items: center;
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(6, minmax(0, 1fr));
  gap: 0.75rem;
  margin-bottom: 1rem;
}

.stat-card {
  background: var(--glass-bg);
  backdrop-filter: var(--glass-blur);
  padding: 1rem 1.1rem;
  border-radius: var(--radius-xl);
  border: 1px solid var(--glass-border);
  display: flex;
  align-items: center;
  gap: 0.875rem;
  transition: all var(--transition-base);
}

.stat-card:hover {
  transform: translateY(-2px);
  border-color: var(--glass-border-hover);
}

.stat-icon {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 38px;
  height: 38px;
  border-radius: 12px;
}

.stat-content {
  display: flex;
  flex-direction: column;
}

.stat-label {
  font-size: 0.75rem;
  color: var(--text-muted);
  text-transform: uppercase;
  letter-spacing: 0.08em;
}

.stat-value {
  font-size: 1.25rem;
  font-weight: 700;
  color: var(--text-primary);
}

.stat-total .stat-icon {
  background: rgba(96, 212, 255, 0.12);
  color: var(--brand-primary);
}

.stat-active .stat-icon {
  background: rgba(74, 222, 128, 0.12);
  color: #4ade80;
}

.stat-suspended .stat-icon {
  background: rgba(251, 191, 36, 0.12);
  color: #fbbf24;
}

.stat-admin .stat-icon {
  background: rgba(168, 114, 255, 0.12);
  color: #a872ff;
}

.stat-deleted .stat-icon {
  background: rgba(248, 113, 113, 0.12);
  color: #f87171;
}

.stat-blacklist .stat-icon {
  background: rgba(248, 113, 113, 0.12);
  color: #f87171;
}

.filters-card {
  background: var(--glass-bg);
  backdrop-filter: var(--glass-blur);
  border: 1px solid var(--glass-border);
  border-radius: var(--radius-2xl);
  padding: 1rem;
  margin-bottom: 1rem;
}

.filter-grid {
  display: grid;
  grid-template-columns: 2fr repeat(5, minmax(0, 1fr));
  gap: 0.75rem;
}

.filter-group {
  display: flex;
  flex-direction: column;
  gap: 0.45rem;
}

.filter-group label {
  display: flex;
  align-items: center;
  gap: 0.375rem;
  font-size: 0.75rem;
  color: var(--text-muted);
  text-transform: uppercase;
  letter-spacing: 0.08em;
}

.filter-group input,
.filter-group select,
.edit-form input,
.edit-form select {
  width: 100%;
  border-radius: var(--radius-lg);
  border: 1px solid var(--glass-border);
  background: var(--bg-surface-muted);
  color: var(--text-primary);
  padding: 0.75rem 0.875rem;
  outline: none;
  transition: all var(--transition-fast);
}

.filter-group input:focus,
.filter-group select:focus,
.edit-form input:focus,
.edit-form select:focus {
  border-color: var(--brand-primary);
  box-shadow: 0 0 0 3px rgba(96, 212, 255, 0.12);
}

.sort-row {
  display: flex;
  gap: 0.5rem;
}

.sort-row select {
  flex: 1;
}

.sort-direction-btn {
  white-space: nowrap;
}

.loading-state,
.error-state,
.detail-loading {
  min-height: 280px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 1rem;
  background: var(--glass-bg);
  backdrop-filter: var(--glass-blur);
  border: 1px solid var(--glass-border);
  border-radius: var(--radius-2xl);
}

.spinner {
  animation: spin 1s linear infinite;
}

.spinner-inline {
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

.error-state {
  color: var(--text-primary);
}

.error-icon {
  color: var(--color-error);
}

.user-table-container {
  margin-bottom: 1rem;
}

.user-cell {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.avatar-circle {
  width: 34px;
  height: 34px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  background: rgba(96, 212, 255, 0.12);
  color: var(--brand-primary);
  flex-shrink: 0;
}

.user-name {
  font-weight: 600;
  color: var(--text-primary);
}

.user-subtext,
.muted-line,
.deleted-meta {
  color: var(--text-muted);
  font-size: 0.8rem;
}

.contact-cell,
.deleted-cell {
  display: flex;
  flex-direction: column;
  gap: 0.35rem;
}

.flag-stack {
  display: flex;
  flex-wrap: wrap;
  gap: 0.4rem;
}

.score-pill {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  min-width: 52px;
  padding: 0.35rem 0.75rem;
  border-radius: var(--radius-full);
  background: rgba(96, 212, 255, 0.12);
  color: var(--brand-primary);
  font-weight: 700;
}

.score-pill.inline {
  min-width: auto;
}

.row-actions {
  display: flex;
  flex-wrap: wrap;
  gap: 0.5rem;
}

.modal-overlay {
  position: fixed;
  inset: 0;
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
  width: 100%;
  max-height: 92vh;
  overflow-y: auto;
  animation: modalSlideUp 0.35s cubic-bezier(0.34, 1.56, 0.64, 1);
}

.user-modal,
.confirm-modal {
  max-width: 1180px;
}

.confirm-modal {
  max-width: 560px;
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
  font-size: 1.15rem;
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

.user-modal-body {
  min-height: 320px;
}

.modal-footer {
  display: flex;
  justify-content: flex-end;
  gap: 0.75rem;
  padding: 1rem 1.5rem 1.5rem;
  border-top: 1px solid var(--divider);
}

.modal-message {
  display: flex;
  align-items: center;
  gap: 0.45rem;
  padding: 0.75rem 0.9rem;
  border-radius: var(--radius-lg);
  margin-bottom: 1rem;
}

.text-success {
  color: #4ade80;
}

.text-error {
  color: #f87171;
}

.modal-message.text-success {
  background: rgba(74, 222, 128, 0.08);
  border: 1px solid rgba(74, 222, 128, 0.2);
}

.modal-message.text-error {
  background: rgba(248, 113, 113, 0.08);
  border: 1px solid rgba(248, 113, 113, 0.2);
}

.user-detail-grid {
  display: grid;
  grid-template-columns: 1fr 1.05fr;
  gap: 1rem;
}

.detail-card {
  background: var(--bg-surface-muted);
  border: 1px solid var(--glass-border);
  border-radius: var(--radius-2xl);
  padding: 1rem;
}

.detail-card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 0.75rem;
  margin-bottom: 1rem;
}

.detail-card-header h3 {
  margin: 0;
  font-size: 1rem;
}

.detail-badges {
  display: flex;
  flex-wrap: wrap;
  gap: 0.5rem;
}

.info-list {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 0.75rem;
}

.info-item {
  padding: 0.75rem;
  background: rgba(17, 24, 39, 0.28);
  border: 1px solid var(--glass-border);
  border-radius: var(--radius-lg);
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.info-label {
  font-size: 0.72rem;
  text-transform: uppercase;
  letter-spacing: 0.08em;
  color: var(--text-muted);
}

.info-value {
  color: var(--text-primary);
  font-weight: 500;
  word-break: break-word;
}

.deletion-summary {
  margin-top: 1rem;
  padding: 0.9rem 1rem;
  border-radius: var(--radius-lg);
  border: 1px solid rgba(248, 113, 113, 0.22);
  background: rgba(248, 113, 113, 0.06);
  color: var(--text-primary);
}

.deletion-summary-title {
  display: flex;
  align-items: center;
  gap: 0.45rem;
  color: #f87171;
  font-weight: 700;
  margin-bottom: 0.4rem;
}

.edit-form {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.form-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 0.75rem;
}

.form-grid label {
  display: flex;
  flex-direction: column;
  gap: 0.45rem;
  font-size: 0.82rem;
  color: var(--text-muted);
}

.toggle-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 0.75rem;
}

.toggle-item {
  display: flex;
  gap: 0.75rem;
  align-items: flex-start;
  padding: 0.85rem;
  border-radius: var(--radius-lg);
  border: 1px solid var(--glass-border);
  background: rgba(17, 24, 39, 0.28);
}

.toggle-item input {
  margin-top: 0.25rem;
  width: 18px;
  height: 18px;
  accent-color: var(--brand-primary);
}

.toggle-item span {
  display: flex;
  flex-direction: column;
  gap: 0.2rem;
}

.toggle-item small {
  color: var(--text-muted);
}

.warning-note {
  display: flex;
  align-items: center;
  gap: 0.45rem;
  padding: 0.75rem 0.9rem;
  border-radius: var(--radius-lg);
  background: rgba(251, 191, 36, 0.08);
  border: 1px solid rgba(251, 191, 36, 0.2);
  color: #fbbf24;
}

.form-actions {
  display: flex;
  justify-content: flex-end;
  gap: 0.75rem;
  flex-wrap: wrap;
}

.changes-pill {
  display: inline-flex;
  align-items: center;
  gap: 0.35rem;
  padding: 0.4rem 0.75rem;
  border-radius: var(--radius-full);
  background: rgba(96, 212, 255, 0.1);
  border: 1px solid rgba(96, 212, 255, 0.22);
  color: var(--brand-primary);
  font-size: 0.8rem;
  font-weight: 600;
}

.confirm-description {
  margin-bottom: 1rem;
  color: var(--text-secondary);
  line-height: 1.6;
}

.confirm-error {
  display: flex;
  align-items: center;
  gap: 0.4rem;
  padding: 0.75rem 0.9rem;
  border-radius: var(--radius-lg);
  background: rgba(248, 113, 113, 0.08);
  border: 1px solid rgba(248, 113, 113, 0.2);
  margin-bottom: 1rem;
}

.confirm-meta {
  display: grid;
  gap: 0.75rem;
}

.confirm-meta > div {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
  padding: 0.85rem 1rem;
  border-radius: var(--radius-lg);
  background: var(--bg-surface-muted);
  border: 1px solid var(--glass-border);
}

.confirm-label {
  font-size: 0.72rem;
  text-transform: uppercase;
  letter-spacing: 0.08em;
  color: var(--text-muted);
}

.badge-user {
  background: rgba(96, 212, 255, 0.12);
  color: var(--brand-primary);
  border: 1px solid rgba(96, 212, 255, 0.22);
}

.badge-admin {
  background: rgba(168, 114, 255, 0.12);
  color: #a872ff;
  border: 1px solid rgba(168, 114, 255, 0.22);
}

.badge-pending {
  background: rgba(251, 191, 36, 0.12);
  color: #fbbf24;
  border: 1px solid rgba(251, 191, 36, 0.25);
}

.badge-success {
  background: rgba(74, 222, 128, 0.12);
  color: #4ade80;
  border: 1px solid rgba(74, 222, 128, 0.25);
}

.badge-error {
  background: rgba(248, 113, 113, 0.12);
  color: #f87171;
  border: 1px solid rgba(248, 113, 113, 0.25);
}

.badge-dismissed,
.badge-info {
  background: rgba(148, 163, 184, 0.1);
  color: var(--neutral-600);
  border: 1px solid rgba(148, 163, 184, 0.2);
}

@media (max-width: 1280px) {
  .stats-grid {
    grid-template-columns: repeat(3, minmax(0, 1fr));
  }

  .filter-grid {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }

  .user-detail-grid {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 768px) {
  .user-management-view {
    padding: 1rem;
  }

  .page-header {
    flex-direction: column;
  }

  .stats-grid,
  .filter-grid,
  .info-list,
  .form-grid,
  .toggle-grid {
    grid-template-columns: 1fr;
  }

  .row-actions {
    flex-direction: column;
    align-items: stretch;
  }

  .modal-header,
  .modal-body,
  .modal-footer {
    padding-left: 1rem;
    padding-right: 1rem;
  }

  .modal-footer {
    flex-direction: column-reverse;
  }
}
</style>
