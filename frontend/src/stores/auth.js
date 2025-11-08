import { defineStore } from 'pinia'
import { ref } from 'vue'
import api from '@/utils/api'

export const useAuthStore = defineStore('auth', () => {
    const token = ref(localStorage.getItem('token') || '')
    const user = ref(JSON.parse(localStorage.getItem('user') || 'null'))

    const login = async (username, password, captchaId, captchaCode) => {
        const response = await api.post('/auth/login', {
            username,
            password,
            captcha_id: captchaId,
            captcha_code: captchaCode
        })

        token.value = response.data.token
        user.value = response.data.user
        localStorage.setItem('token', token.value)
        localStorage.setItem('user', JSON.stringify(user.value))
        api.defaults.headers.common['Authorization'] = `Bearer ${token.value}`

        return response
    }

    const logout = () => {
        token.value = ''
        user.value = null
        localStorage.removeItem('token')
        localStorage.removeItem('user')
        delete api.defaults.headers.common['Authorization']
    }

    const getCurrentUser = async () => {
        const response = await api.get('/auth/me')
        user.value = response.data
        localStorage.setItem('user', JSON.stringify(user.value))
        return response
    }

    return {
        token,
        user,
        login,
        logout,
        getCurrentUser
    }
})

