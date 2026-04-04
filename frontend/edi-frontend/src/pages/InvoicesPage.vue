<script setup lang="ts">
import { ref, onMounted, computed } from 'vue';
import { api } from 'boot/axios';
import { useQuasar } from 'quasar';

const $q = useQuasar();

interface Product {
  id: string;
  code: string;
  name: string;
  salesPrice: number | null;
}

interface Customer {
  id: string;
  name: string;
}

interface Company {
  id: string;
  name: string;
}

interface InvoiceLine {
  id: string;
  product: Product;
  quantity: number;
  unitPrice: number;
  lineTotal: number;
}

interface Invoice {
  id: string;
  invoiceNumber: string;
  invoiceDate: string;
  customer?: Customer;
  company: Company;
  total: number;
  lines: InvoiceLine[];
  createdAt: string;
}

const invoices = ref<Invoice[]>([]);
const products = ref<Product[]>([]);
const customers = ref<Customer[]>([]);
const companies = ref<Company[]>([]);
const loading = ref(false);
const showDialog = ref(false);
const saving = ref(false);
const showDetail = ref(false);
const selectedInvoice = ref<Invoice | null>(null);

const form = ref({
  companyId: '',
  invoiceNumber: '',
  customerId: '',
  invoiceDate: new Date().toISOString().slice(0, 10),
  lines: [] as { productId: string; quantity: number; unitPrice: number }[],
});

const formTotal = computed(() =>
  form.value.lines.reduce((sum, l) => sum + (Number(l.quantity) * Number(l.unitPrice)), 0),
);

const columns = [
  { name: 'invoiceNumber', label: 'Nro. Factura', field: 'invoiceNumber', align: 'left' as const, sortable: true },
  { name: 'invoiceDate', label: 'Fecha', field: 'invoiceDate', align: 'center' as const, sortable: true },
  { name: 'customer', label: 'Cliente', align: 'left' as const, field: (r: Invoice) => r.customer?.name ?? 'Consumidor Final' },
  { name: 'total', label: 'Total', field: 'total', align: 'right' as const },
  { name: 'actions', label: 'Acciones', align: 'center' as const, field: 'actions' },
];

async function loadAll() {
  loading.value = true;
  try {
    const [inv, prod, cust, comp] = await Promise.all([
      api.get('/invoices'),
      api.get('/products'),
      api.get('/customers'),
      api.get('/companies'),
    ]);
    invoices.value = inv.data;
    products.value = prod.data;
    customers.value = cust.data;
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
    invoiceNumber: `FAC-${Date.now()}`,
    customerId: '',
    invoiceDate: new Date().toISOString().slice(0, 10),
    lines: [{ productId: '', quantity: 1, unitPrice: 0 }],
  };
  showDialog.value = true;
}

function addLine() {
  form.value.lines.push({ productId: '', quantity: 1, unitPrice: 0 });
}

function removeLine(index: number) {
  form.value.lines.splice(index, 1);
}

function onProductSelect(index: number, productId: string) {
  const product = products.value.find((p) => p.id === productId);
  if (product) {
    form.value.lines[index].unitPrice = product.salesPrice ?? 0;
  }
}

async function save() {
  if (!form.value.companyId || !form.value.invoiceNumber || form.value.lines.length === 0) {
    $q.notify({ type: 'warning', message: 'Complete los campos requeridos' });
    return;
  }
  saving.value = true;
  try {
    const payload: Record<string, unknown> = {
      companyId: form.value.companyId,
      invoiceNumber: form.value.invoiceNumber,
      invoiceDate: form.value.invoiceDate,
      lines: form.value.lines,
    };
    if (form.value.customerId) payload.customerId = form.value.customerId;
    await api.post('/invoices', payload);
    $q.notify({ type: 'positive', message: 'Factura creada exitosamente' });
    showDialog.value = false;
    await loadAll();
  } catch (err: unknown) {
    const e = err as { response?: { data?: { message?: string } } };
    $q.notify({ type: 'negative', message: e.response?.data?.message ?? 'Error al guardar' });
  } finally {
    saving.value = false;
  }
}

function viewDetail(invoice: Invoice) {
  selectedInvoice.value = invoice;
  showDetail.value = true;
}

async function downloadPdf(id: string) {
  try {
    const res = await api.get(`/invoices/${id}/pdf`, { responseType: 'blob' });
    const url = URL.createObjectURL(new Blob([res.data], { type: 'application/pdf' }));
    const link = document.createElement('a');
    link.href = url;
    link.download = `factura-${id}.pdf`;
    link.click();
    URL.revokeObjectURL(url);
  } catch {
    $q.notify({ type: 'negative', message: 'Error al descargar PDF' });
  }
}

onMounted(loadAll);
</script>

<template>
  <q-page class="q-pa-md">
    <div class="row items-center q-mb-md">
      <div class="text-h5 text-weight-bold col">Facturas de Venta</div>
      <q-btn color="primary" icon="add" label="Nueva Factura" @click="openCreate" unelevated />
    </div>

    <q-card flat bordered>
      <q-table
        :rows="invoices"
        :columns="columns"
        row-key="id"
        :loading="loading"
        flat
        :rows-per-page-options="[10, 20, 50]"
      >
        <template #body-cell-total="props">
          <q-td :props="props" class="text-right text-weight-bold">
            ${{ Number(props.value).toFixed(2) }}
          </q-td>
        </template>
        <template #body-cell-actions="props">
          <q-td :props="props" class="text-center">
            <q-btn flat round dense icon="visibility" color="primary" @click="viewDetail(props.row)" />
            <q-btn flat round dense icon="picture_as_pdf" color="red" @click="downloadPdf(props.row.id)" />
          </q-td>
        </template>
      </q-table>
    </q-card>

    <!-- Dialog crear factura -->
    <q-dialog v-model="showDialog" persistent maximized>
      <q-card>
        <q-card-section class="row items-center bg-primary text-white">
          <div class="text-h6">Nueva Factura</div>
          <q-space />
          <q-btn icon="close" flat round dense v-close-popup />
        </q-card-section>

        <q-card-section class="q-gutter-sm">
          <div class="row q-gutter-md">
            <q-select
              v-model="form.companyId"
              :options="companies.map(c => ({ label: c.name, value: c.id }))"
              label="Empresa *"
              outlined dense
              emit-value map-options
              class="col-12 col-sm-5"
            />
            <q-input v-model="form.invoiceNumber" label="Nro. Factura *" outlined dense class="col-12 col-sm-3" />
            <q-input v-model="form.invoiceDate" label="Fecha *" type="date" outlined dense class="col-12 col-sm-3" />
          </div>

          <q-select
            v-model="form.customerId"
            :options="[{ label: 'Consumidor Final', value: '' }, ...customers.map(c => ({ label: c.name, value: c.id }))]"
            label="Cliente"
            outlined dense
            emit-value map-options
            clearable
            class="col-12 col-sm-6"
          />

          <div class="text-subtitle2 q-mt-md">Líneas de Factura</div>

          <div
            v-for="(line, index) in form.lines"
            :key="index"
            class="row q-gutter-sm items-center"
          >
            <q-select
              v-model="line.productId"
              :options="products.map(p => ({ label: `${p.code} - ${p.name}`, value: p.id }))"
              label="Producto *"
              outlined dense
              emit-value map-options
              class="col-12 col-sm-5"
              @update:model-value="(val) => onProductSelect(index, val)"
            />
            <q-input
              v-model.number="line.quantity"
              label="Cantidad"
              type="number"
              outlined dense
              class="col-12 col-sm-2"
            />
            <q-input
              v-model.number="line.unitPrice"
              label="Precio Unit."
              type="number"
              outlined dense
              class="col-12 col-sm-2"
            />
            <div class="col-12 col-sm-2 text-right text-weight-bold">
              ${{ (Number(line.quantity) * Number(line.unitPrice)).toFixed(2) }}
            </div>
            <q-btn flat round dense icon="remove_circle" color="negative" @click="removeLine(index)" />
          </div>

          <q-btn
            flat icon="add" label="Agregar línea" color="primary" @click="addLine" class="q-mt-xs"
          />

          <q-separator class="q-my-md" />
          <div class="text-right text-h6">
            Total: <strong>${{ formTotal.toFixed(2) }}</strong>
          </div>
        </q-card-section>

        <q-card-actions align="right" class="q-pa-md">
          <q-btn flat label="Cancelar" v-close-popup />
          <q-btn color="primary" label="Crear Factura" @click="save" :loading="saving" unelevated />
        </q-card-actions>
      </q-card>
    </q-dialog>

    <!-- Dialog detalle -->
    <q-dialog v-model="showDetail">
      <q-card style="min-width: 500px" v-if="selectedInvoice">
        <q-card-section class="bg-primary text-white">
          <div class="text-h6">Factura #{{ selectedInvoice.invoiceNumber }}</div>
          <div class="text-caption">{{ selectedInvoice.invoiceDate }}</div>
        </q-card-section>
        <q-card-section>
          <div><strong>Cliente:</strong> {{ selectedInvoice.customer?.name ?? 'Consumidor Final' }}</div>
          <div><strong>Empresa:</strong> {{ selectedInvoice.company?.name }}</div>
          <q-separator class="q-my-md" />
          <q-list dense>
            <q-item v-for="line in selectedInvoice.lines" :key="line.id">
              <q-item-section>
                <q-item-label>{{ line.product.name }}</q-item-label>
                <q-item-label caption>{{ line.quantity }} × ${{ Number(line.unitPrice).toFixed(2) }}</q-item-label>
              </q-item-section>
              <q-item-section side>
                ${{ Number(line.lineTotal).toFixed(2) }}
              </q-item-section>
            </q-item>
          </q-list>
          <q-separator class="q-my-md" />
          <div class="text-right text-h6">Total: ${{ Number(selectedInvoice.total).toFixed(2) }}</div>
        </q-card-section>
        <q-card-actions align="right">
          <q-btn flat label="Cerrar" v-close-popup />
          <q-btn color="red" icon="picture_as_pdf" label="Descargar PDF" @click="downloadPdf(selectedInvoice.id)" unelevated />
        </q-card-actions>
      </q-card>
    </q-dialog>
  </q-page>
</template>
