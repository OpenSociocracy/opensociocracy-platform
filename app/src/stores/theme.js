import { defineStore } from 'pinia';
import { useStorage } from '@vueuse/core';

export const useThemeStore = defineStore('theme', {
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
