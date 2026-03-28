import { defineStore } from 'pinia'
import { computed, ref } from 'vue'
import { jwtDecode } from 'jwt-decode'

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || '/api/v1'

export const useAuthStore = defineStore('auth', () => {
  const accessToken = ref(localStorage.getItem('accessToken') || null)
  const refreshToken = ref(localStorage.getItem('refreshToken') || null)
  const user = ref(JSON.parse(localStorage.getItem('user') || 'null'))
  const loading = ref(false)
  const error = ref(null)

  const isAuthenticated = computed(() => !!accessToken.value)
  const userEmail = computed(() => user.value?.email || user.value?.identifier || '')

  const tokenExpiryTime = computed(() => {
    if (!accessToken.value) return 0
    try {
      const decoded = jwtDecode(accessToken.value)
      return decoded.exp * 1000
    } catch (e) {
      console.error('Failed to decode token:', e)
      return 0
    }
  })

  const isTokenExpired = computed(() => {
    if (!tokenExpiryTime.value) return true
    return Date.now() > tokenExpiryTime.value - 5000
  })

  const setAuthData = (token, refresh, userData) => {
    accessToken.value = token
    localStorage.setItem('accessToken', token)

    try {
      const decoded = jwtDecode(token)
      const expireTimeMs = decoded.exp * 1000

      tokenExpiryTime.value = expireTimeMs
      localStorage.setItem('tokenExpireTime', expireTimeMs.toString())
    } catch (e) {
      console.error('Failed to decode token:', e)
      tokenExpiryTime.value = 0
      localStorage.setItem('tokenExpireTime', '0')
    }

    if (refresh) {
      refreshToken.value = refresh
      localStorage.setItem('refreshToken', refresh)
    }

    if (userData) {
      user.value = userData
      localStorage.setItem('user', JSON.stringify(userData))
    }
  }

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
      const token = tokenData.token || tokenData.accessToken
      const refresh = tokenData.refreshToken

      if (!token) throw new Error('No token received from server')

      const userData = { email: identifier, identifier }
      setAuthData(token, refresh, userData)

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

      if (!tokenResponse.ok) {
        const errData = await tokenResponse.json().catch(() => ({}))
        throw new Error(errData.message || 'Token refresh failed')
      }

      const tokenData = await tokenResponse.json()
      const newToken = tokenData.accessToken || tokenData.token

      if (!newToken) throw new Error('No token received from server')

      setAuthData(newToken, null, null)

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
      error.value = null

      localStorage.removeItem('accessToken')
      localStorage.removeItem('refreshToken')
      localStorage.removeItem('user')
      localStorage.removeItem('tokenExpireTime')
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
    tokenExpiryTime,
    isTokenExpired,
    loginWithEmail,
    refreshAccessToken,
    logout,
    getAuthHeaders,
  }
})
