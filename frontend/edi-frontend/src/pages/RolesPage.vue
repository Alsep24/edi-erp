<template>
  <q-page class="q-pa-md">
    <form @submit.prevent="saveRole" novalidate class="q-mb-md">
      <div class="q-mb-sm">
        <label for="role-name">Nombre</label>
        <q-input
          id="role-name"
          v-model="newRole.name"
          aria-required="true"
          :aria-invalid="errors.name ? 'true' : 'false'"
        />
        <div v-if="errors.name" role="alert">{{ errors.name }}</div>
      </div>
      <div class="q-mb-sm">
        <label for="role-description">Descripción</label>
        <q-input
          id="role-description"
          v-model="newRole.description"
          aria-required="true"
          :aria-invalid="errors.description ? 'true' : 'false'"
        />
        <div v-if="errors.description" role="alert">{{ errors.description }}</div>
      </div>
      <q-btn label="Guardar" color="primary" type="submit" />
    </form>

    <q-list bordered>
      <q-item v-for="role in rolesStore.roles" :key="role.id">
        <q-item-section>
          <q-item-label>{{ role.name }}</q-item-label>
          <q-item-label caption>{{ role.description }}</q-item-label>
        </q-item-section>
        <q-item-section side>
          <q-btn dense flat icon="delete" @click="rolesStore.deleteRole(role.id)" />
        </q-item-section>
      </q-item>
    </q-list>
  </q-page>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { useRolesStore } from 'stores/roles';

const rolesStore = useRolesStore();
const newRole = ref({ name: '', description: '' });
const errors = ref<{ name: string; description: string }>({
  name: '',
  description: ''
});

onMounted(() => {
  rolesStore.fetchRoles();
});

async function saveRole() {
  errors.value = { name: '', description: '' };
  let firstInvalid: string | null = null;

  if (!newRole.value.name) {
    errors.value.name = 'El nombre es obligatorio';
    firstInvalid = 'role-name';
  }

  if (!newRole.value.description) {
    errors.value.description = 'La descripción es obligatoria';
    if (!firstInvalid) {
      firstInvalid = 'role-description';
    }
  }

  if (firstInvalid) {
    const el = document.getElementById(firstInvalid);
    if (el) {
      (el as HTMLElement).focus();
    }
    return;
  }

  await rolesStore.createRole(newRole.value);
  newRole.value = { name: '', description: '' };
}
</script>
