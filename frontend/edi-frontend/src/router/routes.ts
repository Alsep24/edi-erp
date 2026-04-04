import { RouteRecordRaw } from 'vue-router';

const routes: RouteRecordRaw[] = [
  {
    path: '/',
    component: () => import('layouts/MainLayout.vue'),
    children: [
      { path: '', redirect: '/dashboard' },
      {
        path: 'dashboard',
        component: () => import('pages/Dashboard.vue'),
        meta: { requiresAuth: true },
      },
      {
        path: 'login',
        component: () => import('pages/Login.vue'),
      },
      // Administración
      {
        path: 'users',
        component: () => import('pages/UsersPage.vue'),
        meta: { requiresAuth: true },
      },
      {
        path: 'roles',
        component: () => import('pages/RolesPage.vue'),
        meta: { requiresAuth: true },
      },
      // Core
      {
        path: 'companies',
        component: () => import('pages/CompaniesPage.vue'),
        meta: { requiresAuth: true },
      },
      {
        path: 'branches',
        component: () => import('pages/BranchesPage.vue'),
        meta: { requiresAuth: true },
      },
      // Inventario
      {
        path: 'products',
        component: () => import('pages/ProductsPage.vue'),
        meta: { requiresAuth: true },
      },
      // Ventas
      {
        path: 'customers',
        component: () => import('pages/CustomersPage.vue'),
        meta: { requiresAuth: true },
      },
      {
        path: 'invoices',
        component: () => import('pages/InvoicesPage.vue'),
        meta: { requiresAuth: true },
      },
    ],
  },

  // Página 404
  {
    path: '/:catchAll(.*)*',
    component: () => import('pages/ErrorNotFound.vue'),
  },
];

export default routes;
