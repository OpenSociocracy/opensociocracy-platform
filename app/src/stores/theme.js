import { defineStore } from 'pinia';
import { useStorage } from '@vueuse/core';

export const useThemeStore = defineStore('prefs', {
  state: () => ({
    darkMode: useStorage('darkMode', false),
  }),
  getters: {},
  actions: {
    toggleDarkMode() {
      this.darkMode = !this.darkMode;
    },
    reset() {
      this.darkMode = false;
    },
  },
});
