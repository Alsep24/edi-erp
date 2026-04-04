<script setup lang="ts">
import { ref } from 'vue';
import { useRouter } from 'vue-router';
import { useAuthStore } from 'src/stores/auth';
import { api } from 'boot/axios';

const router = useRouter();
const auth = useAuthStore();

const username = ref('');
const password = ref('');
const loading = ref(false);
const error = ref('');
const showPassword = ref(false);

async function handleLogin() {
  if (!username.value || !password.value) {
    error.value = 'Por favor ingrese usuario y contraseña';
    return;
  }
  loading.value = true;
  error.value = '';
  try {
    const response = await api.post('/auth/login', {
      username: username.value,
      password: password.value,
    });
    auth.login(response.data);
    await router.push('/dashboard');
  } catch (err: unknown) {
    const e = err as { response?: { data?: { message?: string } } };
    error.value = e.response?.data?.message ?? 'Error al iniciar sesión. Verifique sus credenciales.';
  } finally {
    loading.value = false;
  }
}
</script>

<template>
  <q-page class="flex flex-center bg-grey-2">
    <q-card class="q-pa-lg shadow-4" style="width: 380px; max-width: 95vw">
      <q-card-section class="text-center q-pb-none">
        <q-icon name="inventory_2" size="48px" color="primary" />
        <div class="text-h5 q-mt-sm text-weight-bold text-primary">EDI-ERP</div>
        <div class="text-caption text-grey-6">Sistema de Gestión Empresarial</div>
      </q-card-section>

      <q-card-section>
        <q-form @submit.prevent="handleLogin" class="q-gutter-md">
          <q-input
            v-model="username"
            label="Usuario"
            dense
            outlined
            prepend-icon="person"
            autocomplete="username"
          >
            <template #prepend>
              <q-icon name="person" />
            </template>
          </q-input>

          <q-input
            v-model="password"
            label="Contraseña"
            :type="showPassword ? 'text' : 'password'"
            dense
            outlined
            autocomplete="current-password"
          >
            <template #prepend>
              <q-icon name="lock" />
            </template>
            <template #append>
              <q-icon
                :name="showPassword ? 'visibility_off' : 'visibility'"
                class="cursor-pointer"
                @click="showPassword = !showPassword"
              />
            </template>
          </q-input>

          <q-banner v-if="error" class="bg-negative text-white rounded-borders" dense>
            <template #avatar>
              <q-icon name="error" />
            </template>
            {{ error }}
          </q-banner>

          <q-btn
            label="Iniciar Sesión"
            type="submit"
            color="primary"
            class="full-width q-mt-sm"
            unelevated
            :loading="loading"
            size="md"
          />
        </q-form>
      </q-card-section>
    </q-card>
  </q-page>
</template>
