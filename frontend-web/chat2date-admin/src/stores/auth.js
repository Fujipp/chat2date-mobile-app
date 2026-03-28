import { defineStore } from 'pinia'
import { computed, ref } from 'vue'

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || '/api/v1'

export const useAuthStore = defineStore('auth', () => {
  // State
  const accessToken = ref(localStorage.getItem('accessToken') || null)
  const refreshToken = ref(localStorage.getItem('refreshToken') || null)
  const user = ref(JSON.parse(localStorage.getItem('user') || 'null'))
  const loading = ref(false)
  const error = ref(null)

  // Getters
  const isAuthenticated = computed(() => !!accessToken.value)
  const userEmail = computed(() => user.value?.email || user.value?.identifier || '')

  // Actions
  const loginWithEmail = async (identifier, password) => {
    loading.value = true
    error.value = null

    try {
      const tokenResponse = await fetch(`${API_BASE_URL}/auth/admin-login`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ identifier, password }),
      })

      if (!tokenResponse.ok) {
        const errData = await tokenResponse.json().catch(() => ({}))
        throw new Error(errData.message || `Authentication failed: ${tokenResponse.status}`)
      }

      const tokenData = await tokenResponse.json()
      const token = tokenData.token
      const refresh = tokenData.refreshToken

      if (!token) throw new Error('No token received from server')

      accessToken.value = token
      refreshToken.value = refresh
      user.value = { email: identifier, identifier }

      localStorage.setItem('accessToken', token)
      localStorage.setItem('refreshToken', refresh)
      localStorage.setItem('user', JSON.stringify(user.value))

      loading.value = false
      return { token, refreshToken: refresh, user: user.value }
    } catch (err) {
      error.value = err.message
      loading.value = false
      throw err
    }
  }

  const refreshAccessToken = async () => {
    if (!refreshToken.value) {
      error.value = 'No refresh token available'
      return false
    }

    try {
      const tokenResponse = await fetch(`${API_BASE_URL}/auth/refresh-token`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ refreshToken: refreshToken.value }),
      })

      console.log(tokenResponse)

      if (!tokenResponse.ok) {
        const errData = await tokenResponse.json().catch(() => ({}))
        throw new Error(errData.message || 'Token refresh failed')
      }

      const tokenData = await tokenResponse.json()
      const newToken = tokenData.accessToken

      if (!newToken) throw new Error('No token received from server')

      accessToken.value = newToken
      localStorage.setItem('accessToken', newToken)

      error.value = null
      return true
    } catch (err) {
      error.value = err.message
      await logout()
      return false
    }
  }

  const logout = async () => {
    try {
      if (accessToken.value) {
        await fetch(`${API_BASE_URL}/auth/logout`, {
          method: 'POST',
          headers: {
            Authorization: `Bearer ${accessToken.value}`,
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({ refreshToken: refreshToken.value }),
        }).catch(() => {})
      }
    } finally {
      accessToken.value = null
      refreshToken.value = null
      user.value = null
      localStorage.removeItem('accessToken')
      localStorage.removeItem('refreshToken')
      localStorage.removeItem('user')
    }
  }

  const getAuthHeaders = () => {
    if (!accessToken.value) return {}
    return { Authorization: `Bearer ${accessToken.value}` }
  }

  return {
    accessToken,
    refreshToken,
    user,
    loading,
    error,
    isAuthenticated,
    userEmail,
    loginWithEmail,
    refreshAccessToken,
    logout,
    getAuthHeaders,
  }
})
