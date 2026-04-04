import { boot } from 'quasar/wrappers';
import axios, { AxiosError } from 'axios';
import type { App } from 'vue';

const api = axios.create({
  baseURL: import.meta.env.VITE_API_URL || 'http://localhost:3000/api',
  timeout: 15000,
});

// Interceptor de petición: inyectar token de autenticación
api.interceptors.request.use((config) => {
  try {
    const raw = localStorage.getItem('edi_erp_auth');
    if (raw) {
      const { token } = JSON.parse(raw) as { token?: string };
      if (token) {
        config.headers = config.headers ?? {};
        config.headers['Authorization'] = `Bearer ${token}`;
      }
    }
  } catch {
    // ignore
  }
  return config;
});

// Interceptor de respuesta: manejar 401 globalmente
api.interceptors.response.use(
  (response) => response,
  (error: AxiosError) => {
    if (error.response?.status === 401) {
      localStorage.removeItem('edi_erp_auth');
      window.location.hash = '#/login';
    }
    return Promise.reject(error);
  },
);

export default boot(({ app }: { app: App }) => {
  app.config.globalProperties.$axios = axios;
  app.config.globalProperties.$api = api;
});

export { api };
