<template>
  <q-page class="q-pa-md">
    <form @submit.prevent="saveUser" novalidate class="q-mb-md">
      <div class="q-mb-sm">
        <label for="user-username">Usuario</label>
        <q-input
          id="user-username"
          v-model="newUser.username"
          aria-required="true"
          :aria-invalid="errors.username ? 'true' : 'false'"
        />
        <div v-if="errors.username" role="alert">{{ errors.username }}</div>
      </div>
      <div class="q-mb-sm">
        <label for="user-email">Email</label>
        <q-input
          id="user-email"
          v-model="newUser.email"
          type="email"
          aria-required="true"
          :aria-invalid="errors.email ? 'true' : 'false'"
        />
        <div v-if="errors.email" role="alert">{{ errors.email }}</div>
      </div>
      <q-btn label="Guardar" color="primary" type="submit" />
    </form>

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
const errors = ref<{ username: string; email: string }>({
  username: '',
  email: ''
});

onMounted(() => {
  usersStore.fetchUsers();
});

async function saveUser() {
  errors.value = { username: '', email: '' };
  let firstInvalid: string | null = null;

  if (!newUser.value.username) {
    errors.value.username = 'El usuario es obligatorio';
    firstInvalid = 'user-username';
  }
  if (!newUser.value.email) {
    errors.value.email = 'El email es obligatorio';
    if (!firstInvalid) {
      firstInvalid = 'user-email';
    }
  }

  if (firstInvalid) {
    const el = document.getElementById(firstInvalid);
    if (el) {
      (el as HTMLElement).focus();
    }
    return;
  }

  await usersStore.createUser(newUser.value);
  newUser.value = { username: '', email: '' };
}
</script>
