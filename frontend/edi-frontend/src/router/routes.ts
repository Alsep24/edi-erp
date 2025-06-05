import { RouteRecordRaw } from 'vue-router';

const routes: RouteRecordRaw[] = [
  {
    path: '/',
    component: () => import('layouts/MainLayout.vue'),
    children: [
      { path: '', component: () => import('pages/IndexPage.vue') },
      { path: 'dashboard', component: () => import('pages/Dashboard.vue'), meta: { requiresAuth: true } },
      { path: 'login', component: () => import('pages/Login.vue') },
      { path: 'users', component: () => import('pages/UsersPage.vue'), meta: { requiresAuth: true } },
      { path: 'roles', component: () => import('pages/RolesPage.vue'), meta: { requiresAuth: true } },
    ],
  },

  // Página 404
  {
    path: '/:catchAll(.*)*',
    component: () => import('pages/ErrorNotFound.vue'),
  },
];

export default routes;
