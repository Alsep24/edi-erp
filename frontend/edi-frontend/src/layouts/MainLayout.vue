<script setup lang="ts">
import { ref, computed } from 'vue';
import { useRouter } from 'vue-router';
import { useAuthStore } from 'src/stores/auth';
import { api } from 'boot/axios';

const router = useRouter();
const auth = useAuthStore();
const leftDrawerOpen = ref(false);

const userDisplayName = computed(() => {
  const u = auth.user;
  if (!u) return '';
  return u.firstName ? `${u.firstName} ${u.lastName ?? ''}`.trim() : u.username;
});

const navLinks = [
  { title: 'Dashboard', icon: 'dashboard', to: '/dashboard' },
  { title: 'Empresas', icon: 'business', to: '/companies', section: 'Configuración' },
  { title: 'Sucursales', icon: 'store', to: '/branches' },
  { title: 'Usuarios', icon: 'people', to: '/users', section: 'Administración' },
  { title: 'Roles', icon: 'admin_panel_settings', to: '/roles' },
  { title: 'Clientes', icon: 'contacts', to: '/customers', section: 'Ventas' },
  { title: 'Facturas', icon: 'receipt_long', to: '/invoices' },
  { title: 'Productos', icon: 'inventory_2', to: '/products', section: 'Inventario' },
];

function toggleLeftDrawer() {
  leftDrawerOpen.value = !leftDrawerOpen.value;
}

async function handleLogout() {
  try {
    await api.post('/auth/logout');
  } finally {
    auth.logout();
    await router.push('/login');
  }
}
</script>

<template>
  <q-layout view="lHh Lpr lFf">
    <q-header elevated class="bg-primary">
      <q-toolbar>
        <q-btn
          flat dense round
          icon="menu"
          aria-label="Menu"
          @click="toggleLeftDrawer"
        />
        <q-toolbar-title class="text-weight-bold">
          <q-icon name="inventory_2" class="q-mr-xs" />
          EDI-ERP
        </q-toolbar-title>

        <template v-if="auth.isLoggedIn">
          <q-btn flat round dense icon="notifications">
            <q-badge color="red" floating>3</q-badge>
          </q-btn>
          <q-btn flat round dense icon="account_circle">
            <q-menu>
              <q-list style="min-width: 180px">
                <q-item-label header class="text-weight-bold">{{ userDisplayName }}</q-item-label>
                <q-separator />
                <q-item clickable v-close-popup @click="router.push('/profile')">
                  <q-item-section avatar><q-icon name="person" /></q-item-section>
                  <q-item-section>Mi Perfil</q-item-section>
                </q-item>
                <q-item clickable v-close-popup @click="handleLogout" class="text-negative">
                  <q-item-section avatar><q-icon name="logout" color="negative" /></q-item-section>
                  <q-item-section>Cerrar Sesión</q-item-section>
                </q-item>
              </q-list>
            </q-menu>
          </q-btn>
        </template>
      </q-toolbar>
    </q-header>

    <q-drawer
      v-model="leftDrawerOpen"
      show-if-above
      bordered
      class="bg-grey-1"
      :width="240"
    >
      <q-scroll-area class="fit">
        <q-list padding>
          <template v-for="(link, index) in navLinks" :key="link.to">
            <q-item-label
              v-if="link.section"
              header
              class="text-grey-7 text-caption text-weight-bold q-pb-xs"
              :class="index > 0 ? 'q-mt-sm' : ''"
            >
              {{ link.section }}
            </q-item-label>
            <q-item
              :to="link.to"
              clickable
              exact
              active-class="text-primary bg-blue-1"
              class="rounded-borders q-mx-sm"
            >
              <q-item-section avatar>
                <q-icon :name="link.icon" />
              </q-item-section>
              <q-item-section>{{ link.title }}</q-item-section>
            </q-item>
          </template>
        </q-list>
      </q-scroll-area>
    </q-drawer>

    <q-page-container>
      <router-view />
    </q-page-container>
  </q-layout>
</template>
