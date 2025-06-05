import { defineStore } from 'pinia';
import { api } from 'boot/axios';

export interface User {
  id: string;
  username: string;
  email: string;
}

export const useUsersStore = defineStore('users', {
  state: () => ({
    users: [] as User[],
    loading: false
  }),
  actions: {
    async fetchUsers() {
      this.loading = true;
      try {
        const res = await api.get('/users');
        this.users = res.data;
      } finally {
        this.loading = false;
      }
    },
    async createUser(data: Partial<User>) {
      const res = await api.post('/users', data);
      await this.fetchUsers();
      return res.data;
    },
    async updateUser(id: string, data: Partial<User>) {
      const res = await api.put(`/users/${id}`, data);
      await this.fetchUsers();
      return res.data;
    },
    async deleteUser(id: string) {
      const res = await api.delete(`/users/${id}`);
      await this.fetchUsers();
      return res.data;
    }
  }
});
