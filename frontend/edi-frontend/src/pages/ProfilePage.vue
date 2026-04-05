<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { api } from 'boot/axios';
import { useAuthStore } from 'src/stores/auth';
import { useQuasar } from 'quasar';

const $q = useQuasar();
const auth = useAuthStore();

const profile = ref({
  username: '',
  email: '',
  firstName: '',
  lastName: '',
  isAdmin: false,
  createdAt: '',
});

const passwordForm = ref({
  currentPassword: '',
  newPassword: '',
  confirmPassword: '',
});

const loadingProfile = ref(false);
const savingProfile = ref(false);
const savingPassword = ref(false);
const showCurrentPassword = ref(false);
const showNewPassword = ref(false);

async function loadProfile() {
  loadingProfile.value = true;
  try {
    const res = await api.get('/auth/profile');
    profile.value = res.data;
  } catch {
    $q.notify({ type: 'negative', message: 'Error al cargar perfil' });
  } finally {
    loadingProfile.value = false;
  }
}

async function saveProfile() {
  savingProfile.value = true;
  try {
    await api.patch(`/users/${auth.user?.id}`, {
      firstName: profile.value.firstName,
      lastName: profile.value.lastName,
      email: profile.value.email,
    });
    auth.updateUser({
      ...auth.user!,
      firstName: profile.value.firstName,
      lastName: profile.value.lastName,
      email: profile.value.email,
    });
    $q.notify({ type: 'positive', message: 'Perfil actualizado correctamente' });
  } catch (err: unknown) {
    const e = err as { response?: { data?: { message?: string } } };
    $q.notify({ type: 'negative', message: e.response?.data?.message ?? 'Error al guardar' });
  } finally {
    savingProfile.value = false;
  }
}

async function changePassword() {
  if (passwordForm.value.newPassword !== passwordForm.value.confirmPassword) {
    $q.notify({ type: 'warning', message: 'Las contraseñas nuevas no coinciden' });
    return;
  }
  if (passwordForm.value.newPassword.length < 8) {
    $q.notify({ type: 'warning', message: 'La nueva contraseña debe tener al menos 8 caracteres' });
    return;
  }
  savingPassword.value = true;
  try {
    await api.post('/users/me/change-password', {
      currentPassword: passwordForm.value.currentPassword,
      newPassword: passwordForm.value.newPassword,
    });
    $q.notify({ type: 'positive', message: 'Contraseña cambiada exitosamente' });
    passwordForm.value = { currentPassword: '', newPassword: '', confirmPassword: '' };
  } catch (err: unknown) {
    const e = err as { response?: { data?: { message?: string } } };
    $q.notify({ type: 'negative', message: e.response?.data?.message ?? 'Error al cambiar contraseña' });
  } finally {
    savingPassword.value = false;
  }
}

onMounted(loadProfile);
</script>

<template>
  <q-page class="q-pa-md">
    <div class="text-h5 text-weight-bold q-mb-lg">Mi Perfil</div>

    <div class="row q-col-gutter-md">
      <!-- Datos del perfil -->
      <div class="col-12 col-md-6">
        <q-card flat bordered>
          <q-card-section class="row items-center bg-primary text-white">
            <q-icon name="person" class="q-mr-sm" />
            <div class="text-subtitle1 text-weight-bold">Información Personal</div>
          </q-card-section>

          <q-card-section>
            <q-skeleton v-if="loadingProfile" type="rect" height="200px" />
            <q-form v-else @submit.prevent="saveProfile" class="q-gutter-sm">

              <div class="row items-center q-mb-md">
                <q-avatar size="80px" color="primary" text-color="white" class="q-mr-md">
                  <span class="text-h4">{{ profile.username?.charAt(0)?.toUpperCase() }}</span>
                </q-avatar>
                <div>
                  <div class="text-h6">{{ profile.username }}</div>
                  <q-chip
                    :color="profile.isAdmin ? 'negative' : 'primary'"
                    text-color="white"
                    dense
                    :label="profile.isAdmin ? 'Administrador' : 'Usuario'"
                    icon="verified_user"
                  />
                </div>
              </div>

              <div class="row q-gutter-sm">
                <q-input
                  v-model="profile.firstName"
                  label="Nombre"
                  outlined dense class="col"
                />
                <q-input
                  v-model="profile.lastName"
                  label="Apellido"
                  outlined dense class="col"
                />
              </div>
              <q-input v-model="profile.email" label="Email" outlined dense type="email" />
              <q-input
                :model-value="profile.username"
                label="Usuario"
                outlined dense
                readonly
                hint="El nombre de usuario no se puede cambiar"
              />

              <div class="q-mt-sm">
                <q-btn
                  type="submit"
                  color="primary"
                  label="Guardar Cambios"
                  :loading="savingProfile"
                  unelevated
                />
              </div>
            </q-form>
          </q-card-section>
        </q-card>
      </div>

      <!-- Cambiar contraseña -->
      <div class="col-12 col-md-6">
        <q-card flat bordered>
          <q-card-section class="row items-center bg-orange text-white">
            <q-icon name="lock" class="q-mr-sm" />
            <div class="text-subtitle1 text-weight-bold">Cambiar Contraseña</div>
          </q-card-section>

          <q-card-section>
            <q-form @submit.prevent="changePassword" class="q-gutter-sm">
              <q-input
                v-model="passwordForm.currentPassword"
                label="Contraseña actual"
                :type="showCurrentPassword ? 'text' : 'password'"
                outlined dense
              >
                <template #append>
                  <q-icon
                    :name="showCurrentPassword ? 'visibility_off' : 'visibility'"
                    class="cursor-pointer"
                    @click="showCurrentPassword = !showCurrentPassword"
                  />
                </template>
              </q-input>

              <q-input
                v-model="passwordForm.newPassword"
                label="Nueva contraseña"
                :type="showNewPassword ? 'text' : 'password'"
                outlined dense
                hint="Mínimo 8 caracteres"
              >
                <template #append>
                  <q-icon
                    :name="showNewPassword ? 'visibility_off' : 'visibility'"
                    class="cursor-pointer"
                    @click="showNewPassword = !showNewPassword"
                  />
                </template>
              </q-input>

              <q-input
                v-model="passwordForm.confirmPassword"
                label="Confirmar nueva contraseña"
                type="password"
                outlined dense
                :error="passwordForm.confirmPassword !== '' && passwordForm.confirmPassword !== passwordForm.newPassword"
                error-message="Las contraseñas no coinciden"
              />

              <div class="q-mt-sm">
                <q-btn
                  type="submit"
                  color="orange"
                  label="Cambiar Contraseña"
                  :loading="savingPassword"
                  unelevated
                />
              </div>
            </q-form>
          </q-card-section>
        </q-card>
      </div>
    </div>
  </q-page>
</template>
