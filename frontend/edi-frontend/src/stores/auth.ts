import { defineStore } from 'pinia';

interface User {
  id: string;
  name: string;
  email: string;
}

export const useAuthStore = defineStore('auth', {
  state: () => ({
    user: null as User | null,
    token: '',
    isLoggedIn: false
  }),
  actions: {
    login(userData: { user: User; token: string }) {
      this.user = userData.user;
      this.token = userData.token;
      this.isLoggedIn = true;
    },
    logout() {
      this.user = null;
      this.token = '';
      this.isLoggedIn = false;
    }
  }
});
