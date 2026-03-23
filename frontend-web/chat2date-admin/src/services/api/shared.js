export const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || '/api/v1'
export const ADMIN_API_URL = `${API_BASE_URL}/admin`

export const getHeaders = () => {
  const headers = { 'Content-Type': 'application/json' }
  const token = localStorage.getItem('accessToken')
  if (token) headers['Authorization'] = `Bearer ${token}`
  return headers
}

export const handleResponse = async (response) => {
  if (!response.ok) {
    const errorData = await response.json().catch(() => ({}))
    throw new Error(errorData.message || `API Error: ${response.status} ${response.statusText}`)
  }
  return response.json()
}
