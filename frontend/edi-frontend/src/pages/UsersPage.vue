<template>
  <q-page class="q-pa-md">
    <div class="q-mb-md">
      <q-input v-model="newUser.username" label="Usuario" class="q-mb-sm" />
      <q-input v-model="newUser.email" label="Email" class="q-mb-sm" />
      <q-btn label="Guardar" color="primary" @click="saveUser" />
    </div>

    <q-list bordered>
      <q-item v-for="user in usersStore.users" :key="user.id">
        <q-item-section>
          <q-item-label>{{ user.username }}</q-item-label>
          <q-item-label caption>{{ user.email }}</q-item-label>
        </q-item-section>
        <q-item-section side>
          <q-btn dense flat icon="delete" @click="usersStore.deleteUser(user.id)" />
        </q-item-section>
      </q-item>
    </q-list>
  </q-page>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { useUsersStore } from 'stores/users';

const usersStore = useUsersStore();
const newUser = ref({ username: '', email: '' });

onMounted(() => {
  usersStore.fetchUsers();
});

async function saveUser() {
  if (newUser.value.username && newUser.value.email) {
    await usersStore.createUser(newUser.value);
    newUser.value = { username: '', email: '' };
  }
}
</script>
