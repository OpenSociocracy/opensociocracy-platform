import { defineStore } from 'pinia';
import { useStorage } from '@vueuse/core';

export const useAccountStore = defineStore('account', {
  state: () => ({
    currentAccount: useStorage('currentAccount', null),
    personalAccount: useStorage('personalAccount', null),
    accounts: useStorage('accounts', {}),
    lastSynced: useStorage('lastSynced', null),
  }),
  getters: {
    currentAccountName(state) {
      if(state.currentAccount) {
        return state.accounts[state.currentAccount].name;
      } else {
          return '';
      }
    },
    isSynced(state) {
      return state.lastSynced ? false : true;
    }

  },
  actions: {
    reset() {
      this.currentAccount = null,
      this.personalAccount = null,
      this.accounts = {},
      this.lastSynced = null
    },
    async refreshMemberAccounts() {



      this.accounts = {};
    }
  }

});
