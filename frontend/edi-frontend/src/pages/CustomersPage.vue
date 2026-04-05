<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { api } from 'boot/axios';
import { useQuasar } from 'quasar';

const $q = useQuasar();

interface Customer {
  id: string;
  name: string;
  taxId: string | null;
  email: string | null;
  phone: string | null;
  city: string | null;
  country: string | null;
  isActive: boolean;
}

const customers = ref<Customer[]>([]);
const loading = ref(false);
const showDialog = ref(false);
const saving = ref(false);
const editingId = ref<string | null>(null);
const search = ref('');

const form = ref({
  name: '',
  taxId: '',
  email: '',
  phone: '',
  address: '',
  city: '',
  country: 'Colombia',
});

const columns = [
  { name: 'name', label: 'Nombre', field: 'name', align: 'left' as const, sortable: true },
  { name: 'taxId', label: 'NIT/ID', field: 'taxId', align: 'left' as const },
  { name: 'email', label: 'Email', field: 'email', align: 'left' as const },
  { name: 'phone', label: 'Teléfono', field: 'phone', align: 'left' as const },
  { name: 'city', label: 'Ciudad', field: 'city', align: 'left' as const },
  { name: 'actions', label: 'Acciones', align: 'center' as const, field: 'actions' },
];

async function loadCustomers() {
  loading.value = true;
  try {
    const res = await api.get('/customers', { params: search.value ? { search: search.value } : {} });
    customers.value = res.data;
  } catch {
    $q.notify({ type: 'negative', message: 'Error al cargar clientes' });
  } finally {
    loading.value = false;
  }
}

function openCreate() {
  editingId.value = null;
  form.value = { name: '', taxId: '', email: '', phone: '', address: '', city: '', country: 'Colombia' };
  showDialog.value = true;
}

function openEdit(customer: Customer) {
  editingId.value = customer.id;
  form.value = {
    name: customer.name,
    taxId: customer.taxId ?? '',
    email: customer.email ?? '',
    phone: customer.phone ?? '',
    address: '',
    city: customer.city ?? '',
    country: customer.country ?? 'Colombia',
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
    const payload = Object.fromEntries(
      Object.entries(form.value).filter(([, v]) => v !== ''),
    );
    if (editingId.value) {
      await api.patch(`/customers/${editingId.value}`, payload);
      $q.notify({ type: 'positive', message: 'Cliente actualizado' });
    } else {
      await api.post('/customers', payload);
      $q.notify({ type: 'positive', message: 'Cliente creado' });
    }
    showDialog.value = false;
    await loadCustomers();
  } catch (err: unknown) {
    const e = err as { response?: { data?: { message?: string } } };
    $q.notify({ type: 'negative', message: e.response?.data?.message ?? 'Error al guardar' });
  } finally {
    saving.value = false;
  }
}

async function remove(id: string) {
  $q.dialog({
    title: 'Confirmar',
    message: '¿Desactivar este cliente?',
    cancel: true,
  }).onOk(async () => {
    try {
      await api.delete(`/customers/${id}`);
      $q.notify({ type: 'positive', message: 'Cliente desactivado' });
      await loadCustomers();
    } catch {
      $q.notify({ type: 'negative', message: 'Error al eliminar' });
    }
  });
}

onMounted(loadCustomers);
</script>

<template>
  <q-page class="q-pa-md">
    <div class="row items-center q-mb-md">
      <div class="text-h5 text-weight-bold col">Clientes</div>
      <q-btn color="primary" icon="add" label="Nuevo Cliente" @click="openCreate" unelevated />
    </div>

    <div class="row q-mb-md">
      <q-input
        v-model="search"
        placeholder="Buscar por nombre, email o NIT..."
        outlined dense clearable class="col-12 col-sm-4"
        @keyup.enter="loadCustomers"
        @clear="loadCustomers"
      >
        <template #prepend><q-icon name="search" /></template>
        <template #append>
          <q-btn flat round dense icon="search" @click="loadCustomers" />
        </template>
      </q-input>
    </div>

    <q-card flat bordered>
      <q-table
        :rows="customers"
        :columns="columns"
        row-key="id"
        :loading="loading"
        flat
        :rows-per-page-options="[10, 20, 50]"
      >
        <template #body-cell-actions="props">
          <q-td :props="props" class="text-center">
            <q-btn flat round dense icon="edit" color="primary" @click="openEdit(props.row)" />
            <q-btn flat round dense icon="delete" color="negative" @click="remove(props.row.id)" />
          </q-td>
        </template>
      </q-table>
    </q-card>

    <!-- Dialog crear/editar -->
    <q-dialog v-model="showDialog" persistent>
      <q-card style="min-width: 420px">
        <q-card-section class="text-h6 bg-primary text-white">
          {{ editingId ? 'Editar Cliente' : 'Nuevo Cliente' }}
        </q-card-section>

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
        </q-card-section>

        <q-card-actions align="right">
          <q-btn flat label="Cancelar" v-close-popup />
          <q-btn color="primary" :label="editingId ? 'Actualizar' : 'Crear'" @click="save" :loading="saving" unelevated />
        </q-card-actions>
      </q-card>
    </q-dialog>
  </q-page>
</template>
