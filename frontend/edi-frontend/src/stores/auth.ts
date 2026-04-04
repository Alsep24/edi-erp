import { defineStore } from 'pinia';

export interface AuthUser {
  id: string;
  username: string;
  email: string;
  firstName?: string;
  lastName?: string;
  isAdmin: boolean;
}

const STORAGE_KEY = 'edi_erp_auth';

function loadFromStorage(): { user: AuthUser | null; token: string; refreshToken: string } {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (raw) return JSON.parse(raw);
  } catch {
    // ignore
  }
  return { user: null, token: '', refreshToken: '' };
}

const stored = loadFromStorage();

export const useAuthStore = defineStore('auth', {
  state: () => ({
    user: stored.user as AuthUser | null,
    token: stored.token,
    refreshToken: stored.refreshToken,
    isLoggedIn: !!stored.token,
  }),

  getters: {
    isAdmin: (state) => state.user?.isAdmin ?? false,
    displayName: (state) => {
      const u = state.user;
      if (!u) return '';
      return u.firstName ? `${u.firstName} ${u.lastName ?? ''}`.trim() : u.username;
    },
  },

  actions: {
    login(data: { accessToken: string; refreshToken: string; user: AuthUser }) {
      this.token = data.accessToken;
      this.refreshToken = data.refreshToken;
      this.user = data.user;
      this.isLoggedIn = true;
      this._persist();
    },

    updateUser(user: AuthUser) {
      this.user = user;
      this._persist();
    },

    logout() {
      this.user = null;
      this.token = '';
      this.refreshToken = '';
      this.isLoggedIn = false;
      localStorage.removeItem(STORAGE_KEY);
    },

    _persist() {
      localStorage.setItem(
        STORAGE_KEY,
        JSON.stringify({ user: this.user, token: this.token, refreshToken: this.refreshToken }),
      );
    },
  },
});
