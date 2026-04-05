<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { api } from 'boot/axios';
import { useQuasar } from 'quasar';

const $q = useQuasar();

interface Product {
  id: string;
  code: string;
  name: string;
  salesPrice: number | null;
  category: string | null;
  unit: string | null;
  isActive: boolean;
  stock?: { quantityOnHand: number };
}

const products = ref<Product[]>([]);
const loading = ref(false);
const showDialog = ref(false);
const saving = ref(false);
const editingId = ref<string | null>(null);

const form = ref({
  code: '',
  name: '',
  salesPrice: null as number | null,
  category: '',
  unit: '',
  description: '',
  minStock: null as number | null,
});

const columns = [
  { name: 'code', label: 'Código', field: 'code', align: 'left' as const, sortable: true },
  { name: 'name', label: 'Nombre', field: 'name', align: 'left' as const, sortable: true },
  { name: 'category', label: 'Categoría', field: 'category', align: 'left' as const },
  { name: 'unit', label: 'Unidad', field: 'unit', align: 'center' as const },
  { name: 'salesPrice', label: 'Precio Venta', field: 'salesPrice', align: 'right' as const },
  { name: 'stock', label: 'Stock', align: 'center' as const, field: (row: Product) => row.stock?.quantityOnHand ?? 0 },
  { name: 'actions', label: 'Acciones', align: 'center' as const, field: 'actions' },
];

async function loadProducts() {
  loading.value = true;
  try {
    const res = await api.get('/products');
    products.value = res.data;
  } catch {
    $q.notify({ type: 'negative', message: 'Error al cargar productos' });
  } finally {
    loading.value = false;
  }
}

function openCreate() {
  editingId.value = null;
  form.value = { code: '', name: '', salesPrice: null, category: '', unit: '', description: '', minStock: null };
  showDialog.value = true;
}

function openEdit(product: Product) {
  editingId.value = product.id;
  form.value = {
    code: product.code,
    name: product.name,
    salesPrice: product.salesPrice,
    category: product.category ?? '',
    unit: product.unit ?? '',
    description: '',
    minStock: null,
  };
  showDialog.value = true;
}

async function save() {
  if (!form.value.code || !form.value.name) {
    $q.notify({ type: 'warning', message: 'Código y nombre son obligatorios' });
    return;
  }
  saving.value = true;
  try {
    if (editingId.value) {
      await api.patch(`/products/${editingId.value}`, form.value);
      $q.notify({ type: 'positive', message: 'Producto actualizado' });
    } else {
      await api.post('/products', form.value);
      $q.notify({ type: 'positive', message: 'Producto creado' });
    }
    showDialog.value = false;
    await loadProducts();
  } catch (err: unknown) {
    const e = err as { response?: { data?: { message?: string } } };
    $q.notify({ type: 'negative', message: e.response?.data?.message ?? 'Error al guardar' });
  } finally {
    saving.value = false;
  }
}

async function remove(id: string) {
  $q.dialog({
    title: 'Confirmar eliminación',
    message: '¿Está seguro de desactivar este producto?',
    cancel: true,
    persistent: true,
  }).onOk(async () => {
    try {
      await api.delete(`/products/${id}`);
      $q.notify({ type: 'positive', message: 'Producto desactivado' });
      await loadProducts();
    } catch {
      $q.notify({ type: 'negative', message: 'Error al eliminar' });
    }
  });
}

onMounted(loadProducts);
</script>

<template>
  <q-page class="q-pa-md">
    <div class="row items-center q-mb-md">
      <div class="text-h5 text-weight-bold col">Productos</div>
      <q-btn color="primary" icon="add" label="Nuevo Producto" @click="openCreate" unelevated />
    </div>

    <q-card flat bordered>
      <q-table
        :rows="products"
        :columns="columns"
        row-key="id"
        :loading="loading"
        flat
        :rows-per-page-options="[10, 20, 50]"
      >
        <template #body-cell-salesPrice="props">
          <q-td :props="props" class="text-right">
            {{ props.value != null ? `$${Number(props.value).toFixed(2)}` : '-' }}
          </q-td>
        </template>
        <template #body-cell-stock="props">
          <q-td :props="props" class="text-center">
            <q-badge
              :color="Number(props.value) <= 0 ? 'negative' : Number(props.value) <= 5 ? 'warning' : 'positive'"
            >
              {{ props.value }}
            </q-badge>
          </q-td>
        </template>
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
      <q-card style="min-width: 400px">
        <q-card-section class="text-h6 bg-primary text-white">
          {{ editingId ? 'Editar Producto' : 'Nuevo Producto' }}
        </q-card-section>

        <q-card-section class="q-gutter-sm">
          <div class="row q-gutter-sm">
            <q-input v-model="form.code" label="Código *" outlined dense class="col" />
            <q-input v-model="form.unit" label="Unidad" outlined dense class="col-4" />
          </div>
          <q-input v-model="form.name" label="Nombre *" outlined dense />
          <q-input v-model="form.category" label="Categoría" outlined dense />
          <div class="row q-gutter-sm">
            <q-input
              v-model.number="form.salesPrice"
              label="Precio de venta"
              type="number"
              outlined dense class="col"
            />
            <q-input
              v-model.number="form.minStock"
              label="Stock mínimo"
              type="number"
              outlined dense class="col"
            />
          </div>
          <q-input v-model="form.description" label="Descripción" outlined dense type="textarea" rows="2" />
        </q-card-section>

        <q-card-actions align="right">
          <q-btn flat label="Cancelar" v-close-popup />
          <q-btn color="primary" :label="editingId ? 'Actualizar' : 'Crear'" @click="save" :loading="saving" unelevated />
        </q-card-actions>
      </q-card>
    </q-dialog>
  </q-page>
</template>
