<template>
  <q-page class="q-pa-md">
    <div class="q-mb-md">
      <q-input v-model="newRole.name" label="Nombre" class="q-mb-sm" />
      <q-input v-model="newRole.description" label="Descripción" class="q-mb-sm" />
      <q-btn label="Guardar" color="primary" @click="saveRole" />
    </div>

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

onMounted(() => {
  rolesStore.fetchRoles();
});

async function saveRole() {
  if (newRole.value.name) {
    await rolesStore.createRole(newRole.value);
    newRole.value = { name: '', description: '' };
  }
}
</script>
