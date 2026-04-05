<script setup lang="ts">
import { ref, onMounted, computed } from 'vue';
import { api } from 'boot/axios';
import { useQuasar } from 'quasar';

const $q = useQuasar();

interface Vendor { id: string; name: string; }
interface Product { id: string; code: string; name: string; }
interface Company { id: string; name: string; }

interface PurchaseOrder {
  id: string;
  orderNumber: string;
  orderDate: string;
  status: string;
  total: number;
  vendor?: Vendor;
  company?: Company;
  lines?: { id: string; product: Product; quantity: number; unitCost: number; lineTotal: number; quantityReceived: number }[];
}

const STATUS_COLOR: Record<string, string> = {
  draft: 'grey',
  confirmed: 'blue',
  received: 'positive',
  cancelled: 'negative',
};
const STATUS_LABEL: Record<string, string> = {
  draft: 'Borrador',
  confirmed: 'Confirmada',
  received: 'Recibida',
  cancelled: 'Cancelada',
};

const orders = ref<PurchaseOrder[]>([]);
const vendors = ref<Vendor[]>([]);
const products = ref<Product[]>([]);
const companies = ref<Company[]>([]);
const loading = ref(false);
const showDialog = ref(false);
const saving = ref(false);
const showDetail = ref(false);
const selected = ref<PurchaseOrder | null>(null);

const form = ref({
  companyId: '',
  vendorId: '',
  orderNumber: '',
  orderDate: new Date().toISOString().slice(0, 10),
  expectedDate: '',
  notes: '',
  lines: [] as { productId: string; quantity: number; unitCost: number }[],
});

const formTotal = computed(() =>
  form.value.lines.reduce((sum, l) => sum + Number(l.quantity) * Number(l.unitCost), 0),
);

const columns = [
  { name: 'orderNumber', label: 'Nro. Orden', field: 'orderNumber', align: 'left' as const, sortable: true },
  { name: 'orderDate', label: 'Fecha', field: 'orderDate', align: 'center' as const },
  { name: 'vendor', label: 'Proveedor', align: 'left' as const, field: (r: PurchaseOrder) => r.vendor?.name ?? '-' },
  { name: 'status', label: 'Estado', field: 'status', align: 'center' as const },
  { name: 'total', label: 'Total', field: 'total', align: 'right' as const },
  { name: 'actions', label: 'Acciones', align: 'center' as const, field: 'actions' },
];

async function loadAll() {
  loading.value = true;
  try {
    const [ord, ven, prod, comp] = await Promise.all([
      api.get('/purchase-orders'),
      api.get('/vendors'),
      api.get('/products'),
      api.get('/companies'),
    ]);
    orders.value = ord.data.data ?? ord.data;
    vendors.value = ven.data.data ?? ven.data;
    products.value = prod.data.data ?? prod.data;
    companies.value = comp.data;
  } catch {
    $q.notify({ type: 'negative', message: 'Error al cargar datos' });
  } finally {
    loading.value = false;
  }
}

function openCreate() {
  form.value = {
    companyId: companies.value[0]?.id ?? '',
    vendorId: '',
    orderNumber: `OC-${Date.now()}`,
    orderDate: new Date().toISOString().slice(0, 10),
    expectedDate: '',
    notes: '',
    lines: [{ productId: '', quantity: 1, unitCost: 0 }],
  };
  showDialog.value = true;
}

function addLine() { form.value.lines.push({ productId: '', quantity: 1, unitCost: 0 }); }
function removeLine(i: number) { form.value.lines.splice(i, 1); }

async function save() {
  if (!form.value.companyId || !form.value.vendorId) {
    $q.notify({ type: 'warning', message: 'Empresa y proveedor son obligatorios' }); return;
  }
  saving.value = true;
  try {
    const payload: Record<string, unknown> = { ...form.value };
    if (!payload.expectedDate) delete payload.expectedDate;
    if (!payload.notes) delete payload.notes;
    await api.post('/purchase-orders', payload);
    $q.notify({ type: 'positive', message: 'Orden de compra creada' });
    showDialog.value = false;
    await loadAll();
  } catch (err: unknown) {
    const e = err as { response?: { data?: { message?: string } } };
    $q.notify({ type: 'negative', message: e.response?.data?.message ?? 'Error al guardar' });
  } finally {
    saving.value = false;
  }
}

async function updateStatus(id: string, action: 'confirm' | 'receive' | 'cancel') {
  const labels = { confirm: 'confirmar', receive: 'recibir', cancel: 'cancelar' };
  $q.dialog({ title: 'Confirmar', message: `¿Desea ${labels[action]} esta orden?`, cancel: true })
    .onOk(async () => {
      try {
        await api.patch(`/purchase-orders/${id}/${action}`);
        $q.notify({ type: 'positive', message: `Orden ${labels[action]}da exitosamente` });
        await loadAll();
        if (selected.value?.id === id) selected.value = orders.value.find(o => o.id === id) ?? null;
      } catch (err: unknown) {
        const e = err as { response?: { data?: { message?: string } } };
        $q.notify({ type: 'negative', message: e.response?.data?.message ?? 'Error' });
      }
    });
}

function viewDetail(order: PurchaseOrder) {
  selected.value = order;
  showDetail.value = true;
}

onMounted(loadAll);
</script>

<template>
  <q-page class="q-pa-md">
    <div class="row items-center q-mb-md">
      <div class="text-h5 text-weight-bold col">Órdenes de Compra</div>
      <q-btn color="primary" icon="add" label="Nueva Orden" @click="openCreate" unelevated />
    </div>

    <q-card flat bordered>
      <q-table :rows="orders" :columns="columns" row-key="id" :loading="loading" flat :rows-per-page-options="[10, 20, 50]">
        <template #body-cell-status="props">
          <q-td :props="props" class="text-center">
            <q-badge :color="STATUS_COLOR[props.value]">{{ STATUS_LABEL[props.value] }}</q-badge>
          </q-td>
        </template>
        <template #body-cell-total="props">
          <q-td :props="props" class="text-right text-weight-bold">${{ Number(props.value).toFixed(2) }}</q-td>
        </template>
        <template #body-cell-actions="props">
          <q-td :props="props" class="text-center">
            <q-btn flat round dense icon="visibility" color="primary" @click="viewDetail(props.row)" />
            <q-btn v-if="props.row.status === 'draft'" flat round dense icon="check_circle" color="blue" @click="updateStatus(props.row.id, 'confirm')" />
            <q-btn v-if="props.row.status === 'confirmed'" flat round dense icon="inventory" color="positive" @click="updateStatus(props.row.id, 'receive')" />
            <q-btn v-if="['draft','confirmed'].includes(props.row.status)" flat round dense icon="cancel" color="negative" @click="updateStatus(props.row.id, 'cancel')" />
          </q-td>
        </template>
      </q-table>
    </q-card>

    <!-- Dialog crear -->
    <q-dialog v-model="showDialog" persistent maximized>
      <q-card>
        <q-card-section class="row items-center bg-primary text-white">
          <div class="text-h6">Nueva Orden de Compra</div>
          <q-space />
          <q-btn icon="close" flat round dense v-close-popup />
        </q-card-section>
        <q-card-section class="q-gutter-sm">
          <div class="row q-gutter-md">
            <q-select v-model="form.companyId" :options="companies.map(c => ({ label: c.name, value: c.id }))" label="Empresa *" outlined dense emit-value map-options class="col-12 col-sm-4" />
            <q-select v-model="form.vendorId" :options="vendors.map(v => ({ label: v.name, value: v.id }))" label="Proveedor *" outlined dense emit-value map-options class="col-12 col-sm-4" />
            <q-input v-model="form.orderNumber" label="Nro. Orden *" outlined dense class="col-12 col-sm-3" />
          </div>
          <div class="row q-gutter-md">
            <q-input v-model="form.orderDate" label="Fecha *" type="date" outlined dense class="col-12 col-sm-3" />
            <q-input v-model="form.expectedDate" label="Fecha esperada" type="date" outlined dense class="col-12 col-sm-3" />
            <q-input v-model="form.notes" label="Notas" outlined dense class="col-12 col-sm-5" />
          </div>

          <div class="text-subtitle2 q-mt-md">Productos</div>
          <div v-for="(line, i) in form.lines" :key="i" class="row q-gutter-sm items-center">
            <q-select v-model="line.productId" :options="products.map(p => ({ label: `${p.code} - ${p.name}`, value: p.id }))" label="Producto *" outlined dense emit-value map-options class="col-12 col-sm-5" />
            <q-input v-model.number="line.quantity" label="Cantidad" type="number" outlined dense class="col-12 col-sm-2" />
            <q-input v-model.number="line.unitCost" label="Costo Unit." type="number" outlined dense class="col-12 col-sm-2" />
            <div class="col text-right text-weight-bold">${{ (Number(line.quantity) * Number(line.unitCost)).toFixed(2) }}</div>
            <q-btn flat round dense icon="remove_circle" color="negative" @click="removeLine(i)" />
          </div>
          <q-btn flat icon="add" label="Agregar producto" color="primary" @click="addLine" />
          <q-separator class="q-my-md" />
          <div class="text-right text-h6">Total: <strong>${{ formTotal.toFixed(2) }}</strong></div>
        </q-card-section>
        <q-card-actions align="right" class="q-pa-md">
          <q-btn flat label="Cancelar" v-close-popup />
          <q-btn color="primary" label="Crear Orden" @click="save" :loading="saving" unelevated />
        </q-card-actions>
      </q-card>
    </q-dialog>

    <!-- Dialog detalle -->
    <q-dialog v-model="showDetail">
      <q-card style="min-width: 520px" v-if="selected">
        <q-card-section class="bg-primary text-white">
          <div class="text-h6">Orden #{{ selected.orderNumber }}</div>
          <div class="row items-center q-mt-xs">
            <q-badge :color="STATUS_COLOR[selected.status]" class="q-mr-sm">{{ STATUS_LABEL[selected.status] }}</q-badge>
            <span class="text-caption">{{ selected.orderDate }}</span>
          </div>
        </q-card-section>
        <q-card-section>
          <div><strong>Proveedor:</strong> {{ selected.vendor?.name }}</div>
          <div><strong>Empresa:</strong> {{ selected.company?.name }}</div>
          <q-separator class="q-my-md" />
          <q-list dense>
            <q-item v-for="line in selected.lines" :key="line.id">
              <q-item-section>
                <q-item-label>{{ line.product.name }}</q-item-label>
                <q-item-label caption>{{ line.quantity }} × ${{ Number(line.unitCost).toFixed(2) }} | Recibido: {{ line.quantityReceived }}</q-item-label>
              </q-item-section>
              <q-item-section side>${{ Number(line.lineTotal).toFixed(2) }}</q-item-section>
            </q-item>
          </q-list>
          <q-separator class="q-my-md" />
          <div class="text-right text-h6">Total: ${{ Number(selected.total).toFixed(2) }}</div>
        </q-card-section>
        <q-card-actions align="right">
          <q-btn v-if="selected.status === 'draft'" color="blue" label="Confirmar" @click="updateStatus(selected.id, 'confirm')" unelevated />
          <q-btn v-if="selected.status === 'confirmed'" color="positive" label="Recibir Mercancía" @click="updateStatus(selected.id, 'receive')" unelevated />
          <q-btn flat label="Cerrar" v-close-popup />
        </q-card-actions>
      </q-card>
    </q-dialog>
  </q-page>
</template>
