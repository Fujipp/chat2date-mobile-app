import { ADMIN_API_URL, getHeaders, handleResponse } from './shared'

export const contactApi = {
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