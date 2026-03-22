import { ADMIN_API_URL, API_BASE_URL, getHeaders, handleResponse } from './shared'

export const contactApi = {
  sendContactMessage: async (payload) => {
    const response = await fetch(`${API_BASE_URL}/contact`, {
      method: 'POST',
      headers: getHeaders(),
      body: JSON.stringify(payload),
    })
    return handleResponse(response)
  },

  getAllContactMessages: async () => {
    const response = await fetch(`${ADMIN_API_URL}/contact`, {
      method: 'GET',
      headers: getHeaders(),
    })
    return handleResponse(response)
  },

  replyContactMessage: async (contactId, payload) => {
    const response = await fetch(`${ADMIN_API_URL}/contact/${contactId}/reply`, {
      method: 'POST',
      headers: getHeaders(),
      body: JSON.stringify(payload),
    })
    return handleResponse(response)
  },
}