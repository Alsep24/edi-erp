<template>
  <q-page class="q-pa-md">
    <div class="row q-col-gutter-md">
      <q-card class="col-12 col-sm-4">
        <q-card-section>
          <div class="text-h6">Empresas</div>
          <div class="text-h4">{{ companiesCount }}</div>
        </q-card-section>
      </q-card>
      <q-card class="col-12 col-sm-4">
        <q-card-section>
          <div class="text-h6">Sucursales</div>
          <div class="text-h4">{{ branchesCount }}</div>
        </q-card-section>
      </q-card>
    </div>
  </q-page>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { api } from 'boot/axios';

const companiesCount = ref(0);
const branchesCount = ref(0);

async function loadStats() {
  const companies = await api.get('/companies');
  companiesCount.value = companies.data.length;

  const branches = await api.get('/branches');
  branchesCount.value = branches.data.length;
}

onMounted(loadStats);
</script>
