<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { api } from 'boot/axios';
import { useQuasar } from 'quasar';

const $q = useQuasar();

interface Role {
  id: string;
  name: string;
  description: string | null;
  isActive: boolean;
  permissions: { id: string; name: string; module: string }[];
}

const roles = ref<Role[]>([]);
const loading = ref(false);
const showDialog = ref(false);
const saving = ref(false);
const editingId = ref<string | null>(null);

const form = ref({ name: '', description: '' });

async function load() {
  loading.value = true;
  try {
    const res = await api.get('/roles');
    roles.value = res.data;
  } catch {
    $q.notify({ type: 'negative', message: 'Error al cargar roles' });
  } finally {
    loading.value = false;
  }
}

function openCreate() {
  editingId.value = null;
  form.value = { name: '', description: '' };
  showDialog.value = true;
}

function openEdit(role: Role) {
  editingId.value = role.id;
  form.value = { name: role.name, description: role.description ?? '' };
  showDialog.value = true;
}

async function save() {
  if (!form.value.name) {
    $q.notify({ type: 'warning', message: 'El nombre del rol es obligatorio' });
    return;
  }
  saving.value = true;
  try {
    if (editingId.value) {
      await api.patch(`/roles/${editingId.value}`, form.value);
      $q.notify({ type: 'positive', message: 'Rol actualizado' });
    } else {
      await api.post('/roles', form.value);
      $q.notify({ type: 'positive', message: 'Rol creado' });
    }
    showDialog.value = false;
    await load();
  } catch (err: unknown) {
    const e = err as { response?: { data?: { message?: string } } };
    $q.notify({ type: 'negative', message: e.response?.data?.message ?? 'Error al guardar' });
  } finally {
    saving.value = false;
  }
}

async function remove(id: string) {
  $q.dialog({ title: 'Confirmar', message: '¿Desactivar este rol?', cancel: true }).onOk(async () => {
    try {
      await api.delete(`/roles/${id}`);
      $q.notify({ type: 'positive', message: 'Rol desactivado' });
      await load();
    } catch {
      $q.notify({ type: 'negative', message: 'Error al eliminar' });
    }
  });
}

onMounted(load);
</script>

<template>
  <q-page class="q-pa-md">
    <div class="row items-center q-mb-md">
      <div class="text-h5 text-weight-bold col">Roles y Permisos</div>
      <q-btn color="primary" icon="add" label="Nuevo Rol" @click="openCreate" unelevated />
    </div>

    <div class="row q-col-gutter-md">
      <div v-for="role in roles" :key="role.id" class="col-12 col-sm-6 col-md-4">
        <q-card flat bordered>
          <q-card-section>
            <div class="row items-center">
              <div class="col">
                <div class="text-subtitle1 text-weight-bold">{{ role.name }}</div>
                <div class="text-caption text-grey-6">{{ role.description ?? 'Sin descripción' }}</div>
              </div>
              <q-btn flat round dense icon="edit" color="primary" @click="openEdit(role)" />
              <q-btn flat round dense icon="delete" color="negative" @click="remove(role.id)" />
            </div>
          </q-card-section>
          <q-separator v-if="role.permissions?.length" />
          <q-card-section v-if="role.permissions?.length" class="q-pt-sm">
            <div class="text-caption text-grey-6 q-mb-xs">Permisos:</div>
            <q-chip
              v-for="p in role.permissions"
              :key="p.id"
              dense size="sm"
              color="blue-1" text-color="blue-8"
            >
              {{ p.name }}
            </q-chip>
          </q-card-section>
        </q-card>
      </div>
      <div v-if="roles.length === 0 && !loading" class="col-12 text-center text-grey-6 q-py-xl">
        No hay roles creados
      </div>
    </div>

    <q-dialog v-model="showDialog" persistent>
      <q-card style="min-width: 360px">
        <q-card-section class="text-h6 bg-primary text-white">
          {{ editingId ? 'Editar Rol' : 'Nuevo Rol' }}
        </q-card-section>
        <q-card-section class="q-gutter-sm">
          <q-input v-model="form.name" label="Nombre del rol *" outlined dense />
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
