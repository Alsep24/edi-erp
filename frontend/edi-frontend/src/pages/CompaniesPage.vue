<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { api } from 'boot/axios';
import { useQuasar } from 'quasar';

const $q = useQuasar();

interface Company {
  id: string;
  name: string;
  taxId: string;
  legalName: string | null;
  address: string | null;
  isActive: boolean;
}

const companies = ref<Company[]>([]);
const loading = ref(false);
const showDialog = ref(false);
const saving = ref(false);
const editingId = ref<string | null>(null);

const form = ref({ name: '', nit: '', legalName: '', address: '' });

const columns = [
  { name: 'name', label: 'Nombre', field: 'name', align: 'left' as const, sortable: true },
  { name: 'taxId', label: 'NIT', field: 'taxId', align: 'left' as const },
  { name: 'legalName', label: 'Razón Social', field: 'legalName', align: 'left' as const },
  { name: 'address', label: 'Dirección', field: 'address', align: 'left' as const },
  { name: 'actions', label: 'Acciones', align: 'center' as const, field: 'actions' },
];

async function load() {
  loading.value = true;
  try {
    const res = await api.get('/companies');
    companies.value = res.data;
  } catch {
    $q.notify({ type: 'negative', message: 'Error al cargar empresas' });
  } finally {
    loading.value = false;
  }
}

function openCreate() {
  editingId.value = null;
  form.value = { name: '', nit: '', legalName: '', address: '' };
  showDialog.value = true;
}

function openEdit(c: Company) {
  editingId.value = c.id;
  form.value = { name: c.name, nit: c.taxId, legalName: c.legalName ?? '', address: c.address ?? '' };
  showDialog.value = true;
}

async function save() {
  if (!form.value.name || !form.value.nit) {
    $q.notify({ type: 'warning', message: 'Nombre y NIT son obligatorios' });
    return;
  }
  saving.value = true;
  try {
    if (editingId.value) {
      await api.patch(`/companies/${editingId.value}`, form.value);
    } else {
      await api.post('/companies', form.value);
    }
    $q.notify({ type: 'positive', message: 'Guardado exitosamente' });
    showDialog.value = false;
    await load();
  } catch (err: unknown) {
    const e = err as { response?: { data?: { message?: string } } };
    $q.notify({ type: 'negative', message: e.response?.data?.message ?? 'Error al guardar' });
  } finally {
    saving.value = false;
  }
}

onMounted(load);
</script>

<template>
  <q-page class="q-pa-md">
    <div class="row items-center q-mb-md">
      <div class="text-h5 text-weight-bold col">Empresas</div>
      <q-btn color="primary" icon="add" label="Nueva Empresa" @click="openCreate" unelevated />
    </div>

    <q-card flat bordered>
      <q-table :rows="companies" :columns="columns" row-key="id" :loading="loading" flat>
        <template #body-cell-actions="props">
          <q-td :props="props" class="text-center">
            <q-btn flat round dense icon="edit" color="primary" @click="openEdit(props.row)" />
          </q-td>
        </template>
      </q-table>
    </q-card>

    <q-dialog v-model="showDialog" persistent>
      <q-card style="min-width: 400px">
        <q-card-section class="text-h6 bg-primary text-white">
          {{ editingId ? 'Editar Empresa' : 'Nueva Empresa' }}
        </q-card-section>
        <q-card-section class="q-gutter-sm">
          <q-input v-model="form.name" label="Nombre *" outlined dense />
          <q-input v-model="form.nit" label="NIT *" outlined dense />
          <q-input v-model="form.legalName" label="Razón Social" outlined dense />
          <q-input v-model="form.address" label="Dirección" outlined dense />
        </q-card-section>
        <q-card-actions align="right">
          <q-btn flat label="Cancelar" v-close-popup />
          <q-btn color="primary" :label="editingId ? 'Actualizar' : 'Crear'" @click="save" :loading="saving" unelevated />
        </q-card-actions>
      </q-card>
    </q-dialog>
  </q-page>
</template>
