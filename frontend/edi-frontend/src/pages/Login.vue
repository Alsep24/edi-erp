<script setup lang="ts">
import { useAuthStore } from 'src/stores/auth';
const auth = useAuthStore();

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
    <button @click="handleLogin">Login Simulado</button>
    <p v-if="auth.isLoggedIn">Usuario: {{ auth.user?.username }}</p>
  </div>
</template>

