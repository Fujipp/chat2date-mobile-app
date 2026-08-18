import { ADMIN_API_URL, getHeaders, handleResponse } from './shared'

export const reportApi = {
  getAll: async ({ page = 0, size = 20, status = '', sortBy = 'createdAt', sortDirection = 'DESC' }) => {
    const params = new URLSearchParams({
      page: page.toString(),
      size: size.toString(),
      sortBy,
      sortDirection,
    })
    if (status) params.append('status', status)
    const response = await fetch(`${ADMIN_API_URL}/reports?${params}`, {
      method: 'GET',
      headers: getHeaders(),
    })
    return handleResponse(response)
  },
  getById: async (reportId) => {
    const response = await fetch(`${ADMIN_API_URL}/reports/${reportId}`, {
      method: 'GET',
      headers: getHeaders(),
    })
    return handleResponse(response)
  },
  updateStatus: async (reportId, status) => {
    const response = await fetch(`${ADMIN_API_URL}/reports/${reportId}/status`, {
      method: 'PUT',
      headers: getHeaders(),
      body: JSON.stringify({ status }),
    })
    return handleResponse(response)
  },
}
