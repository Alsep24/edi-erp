import { boot } from 'quasar/wrappers';
import axios from 'axios';
import type { App } from 'vue';

const api = axios.create({
  baseURL: 'http://localhost:3000/api'
});

export default boot(({ app }: { app: App }) => {
  app.config.globalProperties.$axios = axios;
  app.config.globalProperties.$api = api;
});


