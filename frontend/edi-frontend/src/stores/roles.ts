import { defineStore } from 'pinia';
import { api } from 'boot/axios';

export interface Role {
  id: string;
  name: string;
  description?: string;
}

export const useRolesStore = defineStore('roles', {
  state: () => ({
    roles: [] as Role[],
    loading: false
  }),
  actions: {
    async fetchRoles() {
      this.loading = true;
      try {
        const res = await api.get('/roles');
        this.roles = res.data;
      } finally {
        this.loading = false;
      }
    },
    async createRole(data: Partial<Role>) {
      const res = await api.post('/roles', data);
      await this.fetchRoles();
      return res.data;
    },
    async updateRole(id: string, data: Partial<Role>) {
      const res = await api.put(`/roles/${id}`, data);
      await this.fetchRoles();
      return res.data;
    },
    async deleteRole(id: string) {
      const res = await api.delete(`/roles/${id}`);
      await this.fetchRoles();
      return res.data;
    }
  }
});
