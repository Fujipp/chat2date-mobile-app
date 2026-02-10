/**
 * API Service for Chat2Date Admin Dashboard
 * Centralized API calls and error handling
 */

// API Configuration
const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || '/api/v1'
const ADMIN_API_URL = `${API_BASE_URL}/admin`

/**
 * Default headers for API requests
 */
const getHeaders = () => {
  const headers = {
    'Content-Type': 'application/json',
  }

  // Add authorization token if available
  const token = localStorage.getItem('adminToken')
  if (token) {
    headers['Authorization'] = `Bearer ${token}`
  }

  return headers
}

/**
 * Handle API response errors
 */
const handleResponse = async (response) => {
  if (!response.ok) {
    const errorData = await response.json().catch(() => ({}))
    throw new Error(
      errorData.message || `API Error: ${response.status} ${response.statusText}`
    )
  }
  return response.json()
}

/**
 * Report API Service
 */
export const reportApi = {
  /**
   * Get all reports with pagination and filtering
   * @param {Object} params - Query parameters
   * @param {number} params.page - Page number (0-based)
   * @param {number} params.size - Items per page
   * @param {string} params.status - Filter by status (optional)
   * @param {string} params.sortBy - Sort field (default: createdAt)
   * @param {string} params.sortDirection - Sort direction (ASC/DESC)
   * @returns {Promise<Object>} Paginated reports data
   */
  getAll: async ({ page = 0, size = 20, status = '', sortBy = 'createdAt', sortDirection = 'DESC' }) => {
    const params = new URLSearchParams({
      page: page.toString(),
      size: size.toString(),
      sortBy,
      sortDirection,
    })

    if (status) {
      params.append('status', status)
    }

    const response = await fetch(`${ADMIN_API_URL}/reports?${params}`, {
      method: 'GET',
      headers: getHeaders(),
    })

    return handleResponse(response)
  },

  /**
   * Get report details by ID
   * @param {number} reportId - Report ID
   * @returns {Promise<Object>} Report details with user info and evidence
   */
  getById: async (reportId) => {
    const response = await fetch(`${ADMIN_API_URL}/reports/${reportId}`, {
      method: 'GET',
      headers: getHeaders(),
    })

    return handleResponse(response)
  },

  /**
   * Update report status
   * @param {number} reportId - Report ID
   * @param {string} status - New status (PENDING, RESOLVED, DISMISSED, REJECTED)
   * @returns {Promise<Object>} Updated report
   */
  updateStatus: async (reportId, status) => {
    const response = await fetch(`${ADMIN_API_URL}/reports/${reportId}/status`, {
      method: 'PUT',
      headers: getHeaders(),
      body: JSON.stringify({ status }),
    })

    return handleResponse(response)
  },
}

/**
 * User API Service
 */
export const userApi = {
  /**
   * Get all users
   * @returns {Promise<Array>} List of users
   */
  getAll: async () => {
    const response = await fetch(`${API_BASE_URL}/users`, {
      method: 'GET',
      headers: getHeaders(),
    })

    return handleResponse(response)
  },

  /**
   * Get user by ID
   * @param {string} userId - User ID
   * @returns {Promise<Object>} User details
   */
  getById: async (userId) => {
    const response = await fetch(`${API_BASE_URL}/users/${userId}`, {
      method: 'GET',
      headers: getHeaders(),
    })

    return handleResponse(response)
  },
}

/**
 * Auth API Service (for future implementation)
 */
export const authApi = {
  /**
   * Admin login
   * @param {string} identifier - Admin identifier
   * @param {string} password - Password
   * @returns {Promise<Object>} Authentication tokens
   */
  login: async (identifier, password) => {
    const response = await fetch(`${API_BASE_URL}/auth/login`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ identifier, password }),
    })

    return handleResponse(response)
  },

  /**
   * Refresh access token
   * @param {string} refreshToken - Refresh token
   * @returns {Promise<Object>} New tokens
   */
  refreshToken: async (refreshToken) => {
    const response = await fetch(`${ADMIN_API_URL}/request-refresh`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ refreshToken }),
    })

    return handleResponse(response)
  },

  /**
   * Logout
   */
  logout: () => {
    localStorage.removeItem('adminToken')
    localStorage.removeItem('refreshToken')
  },
}

/**
 * Export all APIs as default
 */
export default {
  report: reportApi,
  user: userApi,
  auth: authApi,
}
