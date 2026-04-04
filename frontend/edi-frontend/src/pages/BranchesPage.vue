<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { api } from 'boot/axios';
import { useQuasar } from 'quasar';

const $q = useQuasar();

interface Branch {
  id: string;
  name: string;
  code: string | null;
  address: string | null;
  isMainBranch: boolean;
  isActive: boolean;
  company?: { id: string; name: string };
}

interface Company {
  id: string;
  name: string;
}

const branches = ref<Branch[]>([]);
const companies = ref<Company[]>([]);
const loading = ref(false);
const showDialog = ref(false);
const saving = ref(false);
const editingId = ref<string | null>(null);

const form = ref({ name: '', code: '', address: '', companyId: '', isMainBranch: false });

const columns = [
  { name: 'name', label: 'Nombre', field: 'name', align: 'left' as const, sortable: true },
  { name: 'code', label: 'Código', field: 'code', align: 'left' as const },
  { name: 'company', label: 'Empresa', align: 'left' as const, field: (r: Branch) => r.company?.name ?? '-' },
  { name: 'isMainBranch', label: 'Principal', field: 'isMainBranch', align: 'center' as const },
  { name: 'address', label: 'Dirección', field: 'address', align: 'left' as const },
  { name: 'actions', label: 'Acciones', align: 'center' as const, field: 'actions' },
];

async function load() {
  loading.value = true;
  try {
    const [br, co] = await Promise.all([api.get('/branches'), api.get('/companies')]);
    branches.value = br.data;
    companies.value = co.data;
  } catch {
    $q.notify({ type: 'negative', message: 'Error al cargar datos' });
  } finally {
    loading.value = false;
  }
}

function openCreate() {
  editingId.value = null;
  form.value = { name: '', code: '', address: '', companyId: companies.value[0]?.id ?? '', isMainBranch: false };
  showDialog.value = true;
}

function openEdit(b: Branch) {
  editingId.value = b.id;
  form.value = {
    name: b.name,
    code: b.code ?? '',
    address: b.address ?? '',
    companyId: b.company?.id ?? '',
    isMainBranch: b.isMainBranch,
  };
  showDialog.value = true;
}

async function save() {
  if (!form.value.name) {
    $q.notify({ type: 'warning', message: 'El nombre es obligatorio' });
    return;
  }
  saving.value = true;
  try {
    if (editingId.value) {
      await api.patch(`/branches/${editingId.value}`, form.value);
    } else {
      await api.post('/branches', form.value);
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
      <div class="text-h5 text-weight-bold col">Sucursales</div>
      <q-btn color="primary" icon="add" label="Nueva Sucursal" @click="openCreate" unelevated />
    </div>

    <q-card flat bordered>
      <q-table :rows="branches" :columns="columns" row-key="id" :loading="loading" flat>
        <template #body-cell-isMainBranch="props">
          <q-td :props="props" class="text-center">
            <q-icon :name="props.value ? 'star' : 'star_border'" :color="props.value ? 'warning' : 'grey'" />
          </q-td>
        </template>
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
          {{ editingId ? 'Editar Sucursal' : 'Nueva Sucursal' }}
        </q-card-section>
        <q-card-section class="q-gutter-sm">
          <q-input v-model="form.name" label="Nombre *" outlined dense />
          <q-input v-model="form.code" label="Código" outlined dense />
          <q-select
            v-model="form.companyId"
            :options="companies.map(c => ({ label: c.name, value: c.id }))"
            label="Empresa"
            outlined dense emit-value map-options
          />
          <q-input v-model="form.address" label="Dirección" outlined dense />
          <q-checkbox v-model="form.isMainBranch" label="Sucursal principal" />
        </q-card-section>
        <q-card-actions align="right">
          <q-btn flat label="Cancelar" v-close-popup />
          <q-btn color="primary" :label="editingId ? 'Actualizar' : 'Crear'" @click="save" :loading="saving" unelevated />
        </q-card-actions>
      </q-card>
    </q-dialog>
  </q-page>
</template>
