import { apiClient } from '../apiClient'
import { ADMIN_API_URL, handleResponse } from './shared'

export const reportApi = {
  getAll: async ({ page = 0, size = 20, status = '', sortBy = 'createdAt', sortDirection = 'DESC' }) => {
    const params = new URLSearchParams({
      page: page.toString(),
      size: size.toString(),
      sortBy,
      sortDirection,
    })
    if (status) params.append('status', status)

    const res = await apiClient(`${ADMIN_API_URL}/reports?${params}`, {
      method: 'GET',
    })
    return handleResponse(res)
  },

  getById: async (reportId) => {
    const res = await apiClient(`${ADMIN_API_URL}/reports/${reportId}`, {
      method: 'GET',
    })
    return handleResponse(res)
  },

  updateStatus: async (reportId, status) => {
    const res = await apiClient(`${ADMIN_API_URL}/reports/${reportId}/status`, {
      method: 'PUT',
      body: JSON.stringify({ status }),
    })
    return handleResponse(res)
  },
}