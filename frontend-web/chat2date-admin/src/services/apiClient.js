import { useAuthStore } from '@/stores/auth'

let isRefreshing = false
let pendingRequests = []

export const apiClient = async (url, options = {}) => {
    const authStore = useAuthStore()

    const makeRequest = () => {
        return fetch(url, {
            ...options,
            headers: {
                'Content-Type': 'application/json',
                ...options.headers,
                ...(authStore.accessToken && {
                    Authorization: `Bearer ${authStore.accessToken}`,
                }),
            },
        })
    }

    let response = await makeRequest()

    // 🔥 ถ้าโดน 401
    if (response.status === 401) {
        if (!isRefreshing) {
            isRefreshing = true

            const success = await authStore.refreshAccessToken()

            isRefreshing = false

            if (!success) {
                await authStore.logout()
                window.location.href = '/login'
                return
            }

            // ยิง request ที่รอทั้งหมด
            pendingRequests.forEach((cb) => cb())
            pendingRequests = []
        }

        // รอ refresh เสร็จ แล้ว retry
        return new Promise((resolve) => {
            pendingRequests.push(async () => {
                resolve(await makeRequest())
            })
        })
    }

    return response
}