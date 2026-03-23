import { API_BASE_URL, getHeaders, handleResponse } from './shared'

export const userApi = {
  getAll: async () => {
    const response = await fetch(`${API_BASE_URL}/users`, {
      method: 'GET',
      headers: getHeaders(),
    })
    return handleResponse(response)
  },
  getById: async (userId) => {
    const response = await fetch(`${API_BASE_URL}/users/${userId}`, {
      method: 'GET',
      headers: getHeaders(),
    })
    return handleResponse(response)
  },
}
