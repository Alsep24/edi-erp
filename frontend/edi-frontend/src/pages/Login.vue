import { ref } from 'vue';
import { useRouter } from 'vue-router';
import { useAuthStore } from 'src/stores/auth';
import { useI18n } from 'vue-i18n';
import { api } from 'boot/axios';

const router = useRouter();
const auth = useAuthStore();

const username = ref('');
const password = ref('');
const loading = ref(false);
const error = ref('');

async function handleLogin() {
  loading.value = true;
  error.value = '';
  try {
    const response = await api.post('/auth/login', {
      username: username.value,
      password: password.value
    });

    auth.login(response.data);
    router.push('/dashboard');
  } catch (err: any) {
    if (err.response?.data?.message) {
      error.value = err.response.data.message;
    } else {
      error.value = 'Error al iniciar sesión';
    }
  } finally {
    loading.value = false;
  }
}
</script>

<template>
  <q-page class="flex flex-center">
    <q-card class="q-pa-md" style="min-width: 300px; width: 350px">
      <q-card-section>
        <div class="text-h6">Iniciar sesión</div>
      </q-card-section>

      <q-card-section>
        <q-form @submit.prevent="handleLogin">
          <q-input v-model="username" label="Usuario" dense />
          <q-input
            v-model="password"
            label="Contraseña"
            type="password"
            dense
            class="q-mt-md"
          />

          <div class="text-negative q-mt-md" v-if="error">{{ error }}</div>

          <q-btn
            label="Ingresar"
            type="submit"
            color="primary"
            class="q-mt-md"
            :loading="loading"
          />
        </q-form>
      </q-card-section>
    </q-card>
  </q-page>
import { ref } from 'vue';
import { useRouter } from 'vue-router';
import { useAuthStore } from 'src/stores/auth';
import { api } from 'boot/axios';

const router = useRouter();
const auth = useAuthStore();
const { t } = useI18n();

const username = ref('');
const password = ref('');
const loading = ref(false);
const error = ref('');

async function handleLogin() {
  loading.value = true;
  error.value = '';
  try {
    const response = await api.post('/auth/login', {
      username: username.value,
      password: password.value
    });

    auth.login(response.data);
    router.push('/dashboard');
  } catch (err) {
    if (err.response?.data?.message) {
      error.value = err.response.data.message;
    } else {
      error.value = 'Error al iniciar sesión';
    }
  } finally {
    loading.value = false;
  }
}
</script>

<template>
  <div>
    <button @click="handleLogin">{{ t('login.button') }}</button>
    <p v-if="auth.isLoggedIn">{{ t('login.userLabel') }} {{ auth.user?.username }}</p>
  </div>
</template>
=======
  <q-page class="flex flex-center">
    <q-card class="q-pa-md" style="min-width: 300px; width: 350px">
      <q-card-section>
        <div class="text-h6">Iniciar sesión</div>
      </q-card-section>

      <q-card-section>
        <q-form @submit.prevent="handleLogin">
          <q-input v-model="username" label="Usuario" dense />
          <q-input
            v-model="password"
            label="Contraseña"
            type="password"
            dense
            class="q-mt-md"
          />

          <div class="text-negative q-mt-md" v-if="error">{{ error }}</div>

          <q-btn
            label="Ingresar"
            type="submit"
            color="primary"
            class="q-mt-md"
            :loading="loading"
          />
        </q-form>
      </q-card-section>
    </q-card>
  </q-page>
</template>