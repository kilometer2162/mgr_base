import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const routes = [
    {
        path: '/login',
        name: 'Login',
        component: () => import('@/views/Login.vue'),
        meta: { requiresAuth: false }
    },
    {
        path: '/',
        component: () => import('@/layouts/MainLayout.vue'),
        redirect: '/dashboard',
        meta: { requiresAuth: true },
        children: [
            {
                path: 'dashboard',
                name: 'Dashboard',
                component: () => import('@/views/Dashboard.vue'),
                meta: { requiresAuth: true }
            },
            {
                path: 'users',
                name: 'Users',
                component: () => import('@/views/Users.vue'),
                meta: { requiresAuth: true }
            },
            {
                path: 'roles',
                name: 'Roles',
                component: () => import('@/views/Roles.vue'),
                meta: { requiresAuth: true }
            },
            {
                path: 'permissions',
                name: 'Permissions',
                component: () => import('@/views/Permissions.vue'),
                meta: { requiresAuth: true }
            },
            {
                path: 'resources',
                name: 'Resources',
                component: () => import('@/views/Resources.vue'),
                meta: { requiresAuth: true }
            },
            {
                path: 'logs',
                name: 'Logs',
                component: () => import('@/views/Logs.vue'),
                meta: { requiresAuth: true }
            },
            {
                path: 'system-monitor',
                name: 'SystemMonitor',
                component: () => import('@/views/SystemMonitor.vue'),
                meta: { requiresAuth: true }
            },
            {
                path: 'ip-statistics',
                name: 'IPStatistics',
                component: () => import('@/views/IPStatistics.vue'),
                meta: { requiresAuth: true }
            },
            {
                path: 'dicts',
                name: 'Dicts',
                component: () => import('@/views/Dicts.vue'),
                meta: { requiresAuth: true }
            },
            {
                path: 'configs',
                name: 'Configs',
                component: () => import('@/views/Configs.vue'),
                meta: { requiresAuth: true }
            },
            {
                path: 'notices',
                name: 'Notices',
                component: () => import('@/views/Notices.vue'),
                meta: { requiresAuth: true }
            }
        ]
    }
]

const router = createRouter({
    history: createWebHistory(),
    routes
})

router.beforeEach((to, from, next) => {
    const authStore = useAuthStore()
    if (to.meta.requiresAuth && !authStore.token) {
        next('/login')
    } else if (to.path === '/login' && authStore.token) {
        next('/')
    } else {
        next()
    }
})

export default router

