import { apiClient } from '../apiClient'
import { ADMIN_API_URL, handleResponse } from './shared'

export const contactApi = {
  getAllContactMessages: async () => {
    const res = await apiClient(`${ADMIN_API_URL}/contact`, {
      method: 'GET',
    })
    return handleResponse(res)
  },

  replyContactMessage: async (contactId, payload) => {
    const res = await apiClient(`${ADMIN_API_URL}/contact/${contactId}/reply`, {
      method: 'POST',
      body: JSON.stringify(payload),
    })
    return handleResponse(res)
  },
}