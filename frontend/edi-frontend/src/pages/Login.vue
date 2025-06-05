<script setup lang="ts">
import { useAuthStore } from 'src/stores/auth';
import { ref } from 'vue';

const auth = useAuthStore();

const form = ref({
  username: '',
  password: ''
});

const errors = ref<{ username: string; password: string }>({
  username: '',
  password: ''
});

function handleLogin() {
  errors.value = { username: '', password: '' };
  let firstInvalid: string | null = null;

  if (!form.value.username) {
    errors.value.username = 'El usuario es obligatorio';
    firstInvalid = 'username';
  }

  if (!form.value.password) {
    errors.value.password = 'La contraseña es obligatoria';
    if (!firstInvalid) {
      firstInvalid = 'password';
    }
  }

  if (firstInvalid) {
    const el = document.getElementById(firstInvalid);
    if (el) {
      (el as HTMLElement).focus();
    }
    return;
  }

  // Aquí simulas la respuesta del backend con usuario y token
  const userData = {
    user: { id: '123', username: form.value.username, email: 'jp041922@gmail.com' },
    token: 'token-jwt-ejemplo'
  };
  auth.login(userData);
}
</script>

<template>
  <div>
    <form @submit.prevent="handleLogin" novalidate>
      <div class="q-mb-sm">
        <label for="username">Usuario</label>
        <input
          id="username"
          v-model="form.username"
          required
          aria-required="true"
          :aria-invalid="errors.username ? 'true' : 'false'"
        />
        <p v-if="errors.username" role="alert">{{ errors.username }}</p>
      </div>
      <div class="q-mb-sm">
        <label for="password">Contraseña</label>
        <input
          id="password"
          type="password"
          v-model="form.password"
          required
          aria-required="true"
          :aria-invalid="errors.password ? 'true' : 'false'"
        />
        <p v-if="errors.password" role="alert">{{ errors.password }}</p>
      </div>
      <button type="submit">Iniciar Sesión</button>
    </form>
    <p v-if="auth.isLoggedIn">Usuario: {{ auth.user?.username }}</p>
  </div>
</template>

