<script setup lang="ts">
import { useAuthStore } from 'src/stores/auth';
import { useI18n } from 'vue-i18n';
const auth = useAuthStore();
const { t } = useI18n();

function handleLogin() {
  // Aquí simulas la respuesta del backend con usuario y token
  const userData = {
    user: { id: '123', username: 'alejandro', email: 'jp041922@gmail.com' },
    token: 'token-jwt-ejemplo'
  };
  auth.login(userData);
}
</script>

<template>
  <div>
    <button @click="handleLogin">{{ t('login.button') }}</button>
    <p v-if="auth.isLoggedIn">{{ t('login.userLabel') }} {{ auth.user?.username }}</p>
  </div>
</template>

