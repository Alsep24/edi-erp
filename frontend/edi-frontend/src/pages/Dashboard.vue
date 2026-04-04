<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { api } from 'boot/axios';
import { useAuthStore } from 'src/stores/auth';

const auth = useAuthStore();

interface StatCard {
  title: string;
  value: number | string;
  icon: string;
  color: string;
  to: string;
}

const stats = ref<StatCard[]>([
  { title: 'Empresas', value: 0, icon: 'business', color: 'blue', to: '/companies' },
  { title: 'Sucursales', value: 0, icon: 'store', color: 'indigo', to: '/branches' },
  { title: 'Usuarios', value: 0, icon: 'people', color: 'purple', to: '/users' },
  { title: 'Productos', value: 0, icon: 'inventory_2', color: 'teal', to: '/products' },
  { title: 'Clientes', value: 0, icon: 'contacts', color: 'green', to: '/customers' },
  { title: 'Facturas', value: 0, icon: 'receipt_long', color: 'orange', to: '/invoices' },
]);

const lowStock = ref<{ id: string; name: string; code: string; stock?: { quantityOnHand: number } }[]>([]);
const recentInvoices = ref<{ id: string; invoiceNumber: string; invoiceDate: string; total: number; customer?: { name: string } }[]>([]);
const loading = ref(false);

async function loadStats() {
  loading.value = true;
  try {
    const [companies, branches, users, products, customers, invoices, lowStockRes] = await Promise.allSettled([
      api.get('/companies'),
      api.get('/branches'),
      api.get('/users'),
      api.get('/products'),
      api.get('/customers'),
      api.get('/invoices'),
      api.get('/products/low-stock'),
    ]);

    stats.value[0].value = companies.status === 'fulfilled' ? companies.value.data.length : '-';
    stats.value[1].value = branches.status === 'fulfilled' ? branches.value.data.length : '-';
    stats.value[2].value = users.status === 'fulfilled' ? users.value.data.length : '-';
    stats.value[3].value = products.status === 'fulfilled' ? products.value.data.length : '-';
    stats.value[4].value = customers.status === 'fulfilled' ? customers.value.data.length : '-';
    stats.value[5].value = invoices.status === 'fulfilled' ? invoices.value.data.length : '-';

    if (lowStockRes.status === 'fulfilled') {
      lowStock.value = lowStockRes.value.data.slice(0, 5);
    }

    if (invoices.status === 'fulfilled') {
      recentInvoices.value = invoices.value.data.slice(0, 5);
    }
  } finally {
    loading.value = false;
  }
}

onMounted(loadStats);
</script>

<template>
  <q-page class="q-pa-md">
    <!-- Saludo -->
    <div class="text-h5 q-mb-md">
      Bienvenido, <strong>{{ auth.displayName }}</strong>
    </div>

    <!-- Tarjetas de estadísticas -->
    <div class="row q-col-gutter-md q-mb-lg">
      <div
        v-for="stat in stats"
        :key="stat.title"
        class="col-12 col-sm-6 col-md-4 col-lg-2"
      >
        <q-card
          flat bordered
          class="cursor-pointer stat-card"
          @click="$router.push(stat.to)"
        >
          <q-card-section class="row items-center no-wrap">
            <div class="col">
              <div class="text-caption text-grey-6">{{ stat.title }}</div>
              <div class="text-h4 text-weight-bold" :class="`text-${stat.color}`">
                <q-skeleton v-if="loading" type="text" width="40px" />
                <span v-else>{{ stat.value }}</span>
              </div>
            </div>
            <q-icon :name="stat.icon" size="40px" :color="stat.color" class="opacity-3" />
          </q-card-section>
        </q-card>
      </div>
    </div>

    <div class="row q-col-gutter-md">
      <!-- Productos con stock bajo -->
      <div class="col-12 col-md-6">
        <q-card flat bordered>
          <q-card-section class="row items-center">
            <div class="text-subtitle1 text-weight-bold col">
              <q-icon name="warning" color="warning" class="q-mr-xs" />
              Stock Bajo
            </div>
            <q-btn flat dense label="Ver todos" color="primary" to="/products" size="sm" />
          </q-card-section>
          <q-separator />
          <q-list dense>
            <q-item v-if="lowStock.length === 0">
              <q-item-section class="text-grey-6 text-center q-py-md">
                No hay productos con stock bajo
              </q-item-section>
            </q-item>
            <q-item v-for="p in lowStock" :key="p.id">
              <q-item-section avatar>
                <q-icon name="inventory_2" color="warning" />
              </q-item-section>
              <q-item-section>
                <q-item-label>{{ p.name }}</q-item-label>
                <q-item-label caption>{{ p.code }}</q-item-label>
              </q-item-section>
              <q-item-section side>
                <q-badge color="warning">{{ p.stock?.quantityOnHand ?? 0 }}</q-badge>
              </q-item-section>
            </q-item>
          </q-list>
        </q-card>
      </div>

      <!-- Facturas recientes -->
      <div class="col-12 col-md-6">
        <q-card flat bordered>
          <q-card-section class="row items-center">
            <div class="text-subtitle1 text-weight-bold col">
              <q-icon name="receipt_long" color="primary" class="q-mr-xs" />
              Facturas Recientes
            </div>
            <q-btn flat dense label="Ver todas" color="primary" to="/invoices" size="sm" />
          </q-card-section>
          <q-separator />
          <q-list dense>
            <q-item v-if="recentInvoices.length === 0">
              <q-item-section class="text-grey-6 text-center q-py-md">
                No hay facturas recientes
              </q-item-section>
            </q-item>
            <q-item v-for="inv in recentInvoices" :key="inv.id">
              <q-item-section avatar>
                <q-icon name="receipt" color="primary" />
              </q-item-section>
              <q-item-section>
                <q-item-label>{{ inv.invoiceNumber }}</q-item-label>
                <q-item-label caption>{{ inv.customer?.name ?? 'Consumidor Final' }}</q-item-label>
              </q-item-section>
              <q-item-section side>
                <q-item-label class="text-weight-bold">${{ Number(inv.total).toFixed(2) }}</q-item-label>
                <q-item-label caption>{{ inv.invoiceDate }}</q-item-label>
              </q-item-section>
            </q-item>
          </q-list>
        </q-card>
      </div>
    </div>
  </q-page>
</template>

<style scoped>
.stat-card:hover {
  border-color: var(--q-primary);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}
</style>
