import { ADMIN_API_URL, API_BASE_URL, handleResponse } from './shared'

export const authApi = {
  login: async (identifier, password) => {
    const response = await fetch(`${API_BASE_URL}/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ identifier, password }),
    })
    return handleResponse(response)
  },
  refreshToken: async (refreshToken) => {
    const response = await fetch(`${ADMIN_API_URL}/request-refresh`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ refreshToken }),
    })
    return handleResponse(response)
  },
  logout: () => {
    localStorage.removeItem('adminToken')
    localStorage.removeItem('refreshToken')
  },
}
