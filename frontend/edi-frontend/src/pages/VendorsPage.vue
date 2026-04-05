<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { api } from 'boot/axios';
import { useQuasar } from 'quasar';

const $q = useQuasar();

interface Vendor {
  id: string;
  name: string;
  taxId: string | null;
  email: string | null;
  phone: string | null;
  city: string | null;
  paymentTerms: string | null;
}

const vendors = ref<Vendor[]>([]);
const loading = ref(false);
const showDialog = ref(false);
const saving = ref(false);
const editingId = ref<string | null>(null);
const search = ref('');

const form = ref({ name: '', taxId: '', email: '', phone: '', address: '', city: '', country: 'Colombia', paymentTerms: '' });

const columns = [
  { name: 'name', label: 'Nombre', field: 'name', align: 'left' as const, sortable: true },
  { name: 'taxId', label: 'NIT', field: 'taxId', align: 'left' as const },
  { name: 'email', label: 'Email', field: 'email', align: 'left' as const },
  { name: 'phone', label: 'Teléfono', field: 'phone', align: 'left' as const },
  { name: 'city', label: 'Ciudad', field: 'city', align: 'left' as const },
  { name: 'paymentTerms', label: 'Términos Pago', field: 'paymentTerms', align: 'left' as const },
  { name: 'actions', label: 'Acciones', align: 'center' as const, field: 'actions' },
];

async function load() {
  loading.value = true;
  try {
    const res = await api.get('/vendors', { params: search.value ? { search: search.value } : {} });
    vendors.value = res.data.data ?? res.data;
  } catch {
    $q.notify({ type: 'negative', message: 'Error al cargar proveedores' });
  } finally {
    loading.value = false;
  }
}

function openCreate() {
  editingId.value = null;
  form.value = { name: '', taxId: '', email: '', phone: '', address: '', city: '', country: 'Colombia', paymentTerms: '' };
  showDialog.value = true;
}

function openEdit(v: Vendor) {
  editingId.value = v.id;
  form.value = { name: v.name, taxId: v.taxId ?? '', email: v.email ?? '', phone: v.phone ?? '', address: '', city: v.city ?? '', country: 'Colombia', paymentTerms: v.paymentTerms ?? '' };
  showDialog.value = true;
}

async function save() {
  if (!form.value.name) { $q.notify({ type: 'warning', message: 'El nombre es obligatorio' }); return; }
  saving.value = true;
  try {
    const payload = Object.fromEntries(Object.entries(form.value).filter(([, v]) => v !== ''));
    if (editingId.value) {
      await api.patch(`/vendors/${editingId.value}`, payload);
    } else {
      await api.post('/vendors', payload);
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
      <div class="text-h5 text-weight-bold col">Proveedores</div>
      <q-btn color="primary" icon="add" label="Nuevo Proveedor" @click="openCreate" unelevated />
    </div>

    <div class="row q-mb-md">
      <q-input v-model="search" placeholder="Buscar..." outlined dense clearable class="col-12 col-sm-4" @keyup.enter="load" @clear="load">
        <template #prepend><q-icon name="search" /></template>
      </q-input>
    </div>

    <q-card flat bordered>
      <q-table :rows="vendors" :columns="columns" row-key="id" :loading="loading" flat :rows-per-page-options="[10, 20, 50]">
        <template #body-cell-actions="props">
          <q-td :props="props" class="text-center">
            <q-btn flat round dense icon="edit" color="primary" @click="openEdit(props.row)" />
          </q-td>
        </template>
      </q-table>
    </q-card>

    <q-dialog v-model="showDialog" persistent>
      <q-card style="min-width: 420px">
        <q-card-section class="text-h6 bg-primary text-white">{{ editingId ? 'Editar Proveedor' : 'Nuevo Proveedor' }}</q-card-section>
        <q-card-section class="q-gutter-sm">
          <q-input v-model="form.name" label="Nombre *" outlined dense />
          <div class="row q-gutter-sm">
            <q-input v-model="form.taxId" label="NIT / ID Fiscal" outlined dense class="col" />
            <q-input v-model="form.phone" label="Teléfono" outlined dense class="col" />
          </div>
          <q-input v-model="form.email" label="Email" outlined dense type="email" />
          <q-input v-model="form.address" label="Dirección" outlined dense />
          <div class="row q-gutter-sm">
            <q-input v-model="form.city" label="Ciudad" outlined dense class="col" />
            <q-input v-model="form.country" label="País" outlined dense class="col" />
          </div>
          <q-input v-model="form.paymentTerms" label="Términos de pago" outlined dense placeholder="ej: 30 días" />
        </q-card-section>
        <q-card-actions align="right">
          <q-btn flat label="Cancelar" v-close-popup />
          <q-btn color="primary" :label="editingId ? 'Actualizar' : 'Crear'" @click="save" :loading="saving" unelevated />
        </q-card-actions>
      </q-card>
    </q-dialog>
  </q-page>
</template>
