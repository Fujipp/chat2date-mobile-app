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
  updateById: async (userId, user) => {
    const response = await fetch(`${API_BASE_URL}/users/${userId}`, {
      method: 'PUT',
      headers: getHeaders(),
      body: JSON.stringify(user),
    })
    return handleResponse(response)
  },
  deleteById: async (userId) => {
    const response = await fetch(`${API_BASE_URL}/users/${userId}`, {
      method: 'DELETE',
      headers: getHeaders(),
    })
    return handleResponse(response)
  },
  restoreById: async (userId) => {
    const response = await fetch(`${API_BASE_URL}/users/${userId}/restore`, {
      method: 'POST',
      headers: getHeaders(),
    })
    return handleResponse(response)
  },
  getDeletionStatus: async (userId) => {
    const response = await fetch(`${API_BASE_URL}/users/${userId}/deletion-status`, {
      method: 'GET',
      headers: getHeaders(),
    })
    return handleResponse(response)
  },
}
