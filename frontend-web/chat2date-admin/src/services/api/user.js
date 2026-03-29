import { apiClient } from '../apiClient'
import { API_BASE_URL, handleResponse } from './shared'

export const userApi = {
  getAll: async () => {
    const res = await apiClient(`${API_BASE_URL}/users`, {
      method: 'GET',
    })
    return handleResponse(res)
  },

  getById: async (userId) => {
    const res = await apiClient(`${API_BASE_URL}/users/${userId}`, {
      method: 'GET',
    })
    return handleResponse(res)
  },

  updateById: async (userId, user) => {
    const res = await apiClient(`${API_BASE_URL}/users/${userId}`, {
      method: 'PUT',
      body: JSON.stringify(user),
    })
    return handleResponse(res)
  },

  deleteById: async (userId) => {
    const res = await apiClient(`${API_BASE_URL}/users/${userId}`, {
      method: 'DELETE',
    })
    return handleResponse(res)
  },

  restoreById: async (userId) => {
    const res = await apiClient(`${API_BASE_URL}/users/${userId}/restore`, {
      method: 'POST',
    })
    return handleResponse(res)
  },

  getDeletionStatus: async (userId) => {
    const res = await apiClient(`${API_BASE_URL}/users/${userId}/deletion-status`, {
      method: 'GET',
    })
    return handleResponse(res)
  },
}