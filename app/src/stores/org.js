import { defineStore } from "pinia";
import { useStorage } from "@vueuse/core";
import { nanoid } from "nanoid";
import { ref } from "vue";


export const useOrgStore = defineStore("org", {
  state: () => ({
    orgs: useStorage("orgs", new Map()),
    orgDomains: useStorage("orgDomains", new Map()),
    orgDrivers: useStorage("orgDrivers", new Map()),
    orgMembers: useStorage("orgMembers", new Map()),
    orgNuggets: useStorage("orgNuggets", new Map()),
    currentOrgUid: useStorage("currentOrgUid", null),
    lastSynced: useStorage("lastSynced", null),
    fetching: false,
    showNewOrgDialog: false,
    offline: new Map(),
  }),
  getters: {
    hasOrgs(state) {
      if (state.lastSynced && state.orgs.size > 0) {
        return true;
      } else {
        this.fetching = true;
        // GET orgs
        // Set state.orgs
        this.fetching = false;
        // Set last Synced to current time
        state.lastSynced = true;

        // Test again
        if (state.lastSynced && state.orgs.size > 0) {
          return true;
        }
      }
      return false;
    },
    otherOrgs(state) {
      const notCurrentOrgs = ref(new Map())
      if(state.currentOrgUid) {
        state.orgs.forEach(function(value, key) {
          if(key != state.currentOrgUid) {
            notCurrentOrgs.value.set(key, value)
            console.log(value)
          }
        })
      }

      return notCurrentOrgs;
    }
  },
  actions: {
    async createOrg(name) {
      // Save it locally in orgs with a local Uid
      const localOrgUid = nanoid();

      const orgData = {
        uid: localOrgUid,
        name: name,
      };

      this.orgs.set(localOrgUid, orgData);

      // POST an org

      this.showNewOrgDialog = false;

      return orgData;
    },
    async delete(uid) {
      if(uid == this.currentOrgUid ) {
        this.currentOrgUid = null;
      }
      this.orgs.delete(uid);
    },
    setCurrentOrg(uid) {
      this.currentOrgUid = uid;
    },
    triggerNewOrgDialog() {
      this.showNewOrgDialog = true;
    },
    validateOrgName(orgName) {
      return orgName.length >= 2 && orgName.length <= 64;
    },
    reset() {
      this.orgs = new Map();
      this.orgDomains = new Map();
      this.orgDrivers = new Map();
      this.orgMembers = new Map();
      this.orgNuggets = new Map();
      this.currentOrgUid = null;
      this.lastSynced = null;
      this.fetching = false;
      this.showNewOrgDialog = false;
      this.offline = new Map();
    },
  },
});
