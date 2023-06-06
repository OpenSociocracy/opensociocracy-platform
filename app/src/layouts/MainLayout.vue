<template>
  <q-layout view="lHh Lpr lFf">
    <q-header elevated>
      <q-toolbar>
        <q-btn
          flat
          dense
          round
          icon="menu"
          aria-label="Menu"
          @click="toggleLeftDrawer"
        />
        <!-- LOGO -->
        <q-avatar>
          <img src="https://handbook.opensociocracy.org/logo_light.jpg" />
        </q-avatar>
        <q-toolbar-title>
          <span
            ><router-link :to="{ name: 'home' }" class="navbar-link">{{
              org.currentOrgUid
                ? org.orgs.get(org.currentOrgUid).name
                : "OpenSociocracy"
            }}</router-link></span
          >
        </q-toolbar-title>
        <!-- TOOLBAR - RIGHT SIDE BUTTONS -->
        <div>
          <!-- DISPLAY SIGN BUTTON -->
          <span>
            <sign-in-button v-if="!auth.isSignedIn"></sign-in-button>
            <q-tooltip>{{ $t("nav.signIn") }}</q-tooltip></span
          >
          <!-- NOTIFICATIONS BUTTON -->
          <span v-if="auth.isSignedIn">
            <NotificationsButton></NotificationsButton>
            <q-tooltip>{{ $t("notifications.hint") }}</q-tooltip>
          </span>

          <!-- MEMBER BUTTON -->
          <span>
            <MemberButton></MemberButton>
            <q-tooltip>{{ $t("member.hint") }}</q-tooltip>
          </span>
        </div>
      </q-toolbar>
    </q-header>

    <!-- LEFT DRAWER -->
    <q-drawer v-model="leftDrawerOpen" show-if-above bordered>
      <q-list>
        <!-- CURRENT ORG / SELECT ORG-->
        <q-expansion-item
          bordered
          expand-separator
          icon="mdi-office-building"
          :label="
            org.currentOrgUid
              ? org.orgs.get(org.currentOrgUid).name
              : $t('orgs.drawer.select-organization')
          "
          header-class="text-weight-bolder"
          :caption="
            org.currentOrgUid
              ? $t('orgs.drawer.current-organization')
              : $t('orgs.drawer.select-or-create-an-organization')
          "
        >
          <!-- ADD ORAGNIZATION -->
          <q-item clickable @click="org.triggerNewOrgDialog">
            <q-item-section avatar>
              <q-icon name="mdi-office-building-plus" />
            </q-item-section>
            <q-item-section>
              <q-item-label>{{ $t("orgs.new-org") }}</q-item-label>
              <q-item-label caption>
                {{ $t("orgs.create-an-org") }}
              </q-item-label>
            </q-item-section>
          </q-item>

          <!-- LIST ORGANIZATIONS -->
          <q-item header dense>
            <div class="text-center full-width text-bold text-italic">
              {{ $t("orgs.drawer.current-organizations") }}
            </div>
          </q-item>
          <q-expansion-item
            v-for="[ix, item] in org.$state.orgs"
            :key="ix"
            expand-icon-toggle
            expand-separator
            :label="item.name"
            :caption="item.uid"
            :to="'/org/' + item.uid"
          >
            <!-- ORGANIZATION QUICKVIEW -->
            <q-card>
              <q-card-actions>
                <!-- ORGANIZATION QUICKVIEW CONTROLS -->
                <q-btn
                  flat
                  icon="mdi-delete"
                  size="sm"
                  @click="org.delete(item.uid)"
                  >{{ $t("nav.delete") }}</q-btn
                >
              </q-card-actions>
            </q-card>
          </q-expansion-item>
        </q-expansion-item>
      </q-list>
      <!-- ORGANIZATION MANAGEMENT MENU -->
      <q-list v-if="org.currentOrgUid" bordered>
        <!-- NEW ACTVITY -->
        <!-- LOGBOOK -->
        <q-expansion-item
          expand-separator
          icon="mdi-notebook"
          :label="$t('orgs.drawer.logbook-label')"
          :caption="$t('orgs.drawer.logbook-caption')"
          group="org-management"
          header-class="text-weight-medium"
        >

          <!-- ADD LOGBOOK ITEM -->
          <q-item clickable @click="org.triggerNewLogbookEntryDialog">
            <q-item-section avatar>
              <q-icon name="mdi-notebook-plus" />
            </q-item-section>
            <q-item-section>
              <q-item-label>{{
                $t("orgs.drawer.new-logbook-entry-label")
              }}</q-item-label>
              <q-item-label caption>
                {{ $t("orgs.drawer.new-logbook-entry-caption") }}
              </q-item-label>
            </q-item-section>
          </q-item>

         <!-- SEARCH LOGBOOK -->
         <q-item>
          <q-item-section avatar>
              <q-icon name="mdi-book-search" />
            </q-item-section>
            <q-input label="Search Logbook"></q-input></q-item>

          <!-- VIEW LOGBOOK ENTRIES -->
          <q-item clickable :to="'/org/' + org.currentOrgUid + '/logbook'">
            <q-item-section avatar>
              <q-icon name="mdi-book-cog" />
            </q-item-section>
            <q-item-section>
              <q-item-label>{{
                $t("orgs.drawer.logbook-dashboard-label")
              }}</q-item-label>
              <q-item-label caption>
                {{ $t("orgs.drawer.logbook-dashboard-caption") }}
              </q-item-label>
            </q-item-section>
          </q-item>

        </q-expansion-item>

        <!-- DRIVERS -->
        <q-expansion-item
          expand-separator
          icon="mdi-sign-direction"
          :label="$t('orgs.drawer.drivers-label')"
          :caption="$t('orgs.drawer.drivers-caption')"
          group="org-management"
          header-class="text-weight-medium"
        >

         <!-- ADD DRIVER -->
          <q-item clickable @click="org.triggerNewDriverDialog">
            <q-item-section avatar>
              <q-icon name="mdi-sign-direction-plus" />
            </q-item-section>
            <q-item-section>
              <q-item-label>{{
                $t("orgs.drawer.new-driver-label")
              }}</q-item-label>
              <q-item-label caption>
                {{ $t("orgs.drawer.new-driver-caption") }}
              </q-item-label>
            </q-item-section>
          </q-item>

          <!-- LIST DRIVERS -->
          <q-expansion-item
            v-for="[ix, item] in org.$state.orgDrivers"
            :key="ix"
            expand-icon-toggle
            expand-separator
            :label="item.name"
            :caption="item.uid"
            :to="'/org/' + item.uid"
          >
            <!-- DRIVER QUICKVIEW -->
            <q-card>
              <q-card-actions>
                <!-- DRIVER QUICKVIEW CONTROLS -->
                <q-btn
                  flat
                  icon="mdi-delete"
                  size="sm"
                  @click="org.delete(item.uid)"
                  >{{ $t("nav.delete") }}</q-btn
                >
              </q-card-actions>
            </q-card>
          </q-expansion-item>

          <!-- DRIVER DASHBOARD - BROWSE DRIVERS -->
          <q-item clickable :to="'/org/' + org.currentOrgUid + '/members'">
            <q-item-section avatar>
              <q-icon name="mdi-view-dashboard-variant" />
            </q-item-section>
            <q-item-section>
              <q-item-label>{{
                $t("orgs.drawer.drivers-dashboard-label")
              }}</q-item-label>
              <q-item-label caption>
                {{ $t("orgs.drawer.drivers-dashboard-caption") }}
              </q-item-label>
            </q-item-section>
          </q-item>
        </q-expansion-item>

        <!-- DOMAINS -->
        <q-expansion-item
          expand-separator
          icon="mdi-domain"
          :label="$t('orgs.drawer.domains-label')"
          :caption="$t('orgs.drawer.domains-caption')"
          group="org-management"
          header-class="text-weight-medium"
        >
        <!-- ADD DOMAIN -->
          <q-item clickable @click="org.triggerNewDomainDialog">
            <q-item-section avatar>
              <q-icon name="mdi-domain" />
            </q-item-section>
            <q-item-section>
              <q-item-label>{{
                $t("orgs.drawer.new-domain-label")
              }}</q-item-label>
              <q-item-label caption>
                {{ $t("orgs.drawer.new-domain-caption") }}
              </q-item-label>
            </q-item-section>
          </q-item>
          <!-- LIST DOMAINS -->
          <q-expansion-item
            v-for="[ix, item] in org.$state.orgDomains"
            :key="ix"
            expand-icon-toggle
            expand-separator
            :label="item.name"
            :caption="item.uid"
            :to="'/org/' + org.currentOrgUid + '/domain/' + item.uid"
          >
            <!-- DOMAIN QUICKVIEW -->
            <q-card>
              <q-card-actions>
                <!-- DOMAIN QUICKVIEW CONTROLS -->
                <q-btn
                  flat
                  icon="mdi-delete"
                  size="sm"
                  @click="org.delete(item.uid)"
                  >{{ $t("nav.delete") }}</q-btn
                >
              </q-card-actions>
            </q-card>
          </q-expansion-item>
          <!-- DOMAIN DASHBOARD - BROWSE DOMAINS -->
          <q-item clickable :to="'/org/' + org.currentOrgUid + '/members'">
            <q-item-section avatar>
              <q-icon name="mdi-view-dashboard" />
            </q-item-section>
            <q-item-section>
              <q-item-label>{{
                $t("orgs.drawer.domains-dashboard-label")
              }}</q-item-label>
              <q-item-label caption>
                {{ $t("orgs.drawer.domains-dashboard-caption") }}
              </q-item-label>
            </q-item-section>
          </q-item>
        </q-expansion-item>

        <!-- MEMBERS -->
        <q-expansion-item
          expand-separator
          icon="mdi-account-multiple"
          :label="$t('orgs.drawer.members-label')"
          :caption="$t('orgs.drawer.members-caption')"
          group="org-management"
          header-class="text-weight-medium"
        >
          <!-- MEMBER SEARCH -->
          <q-item>
            <q-item-section avatar>
              <q-icon name="mdi-account-search" />
            </q-item-section>
            <q-input label="Search Members"></q-input>

          </q-item>

          <!-- LIST SEARCH MEMBERS -->
          <q-expansion-item
            v-for="[ix, item] in org.$state.orgMembers"
            :key="ix"
            expand-icon-toggle
            expand-separator
            :label="item.name"
            :caption="item.uid"
            :to="'/org/' + org.currentOrgUid + '/member/' + item.uid"
          >
            <!-- MEMBER QUICKVIEW -->
            <q-card>
              <q-card-actions>
                <!-- MEMBER QUICKVIEW CONTROLS -->
                <q-btn
                  flat
                  icon="mdi-delete"
                  size="sm"
                  @click="org.delete(item.uid)"
                  >{{ $t("nav.delete") }}</q-btn
                >
              </q-card-actions>
            </q-card>
          </q-expansion-item>

          <!-- ADD MEMBER -->
          <q-item clickable @click="org.triggerNewMemberDialog">
            <q-item-section avatar>
              <q-icon name="mdi-account-plus" />
            </q-item-section>
            <q-item-section>
              <q-item-label>{{
                $t("orgs.drawer.new-member-label")
              }}</q-item-label>
              <q-item-label caption>
                {{ $t("orgs.drawer.new-member-caption") }}
              </q-item-label>
            </q-item-section>
          </q-item>

          <!-- MEMBERS DASHBOARD - BROWSE MEMBERS -->
          <q-item clickable :to="'/org/' + org.currentOrgUid + '/members'">
            <q-item-section avatar>
              <q-icon name="mdi-account-group" />
            </q-item-section>
            <q-item-section>
              <q-item-label>{{
                $t("orgs.drawer.members-dashboard-label")
              }}</q-item-label>
              <q-item-label caption>
                {{ $t("orgs.drawer.members-dashboard-caption") }}
              </q-item-label>
            </q-item-section>
          </q-item>
        </q-expansion-item>
      </q-list>
    </q-drawer>

    <!-- DIALOGS -->
    <q-page-container>
      <PasswordlessAuthDialog
        v-model="auth.signInRequired"
      ></PasswordlessAuthDialog>
      <WelcomeDialog v-model="auth.isNewMember"></WelcomeDialog>
      <OrgCreateDialog v-model="org.showNewOrgDialog"></OrgCreateDialog>
      <router-view />
    </q-page-container>
  </q-layout>
</template>

<script setup>
import { ref, watch } from "vue";
import { useRoute } from "vue-router";
import { useAuthStore } from "../stores/auth";
import { useOrgStore } from "../stores/org";

import NotificationsButton from "../components/NotificationsButton.vue";
import MemberButton from "../components/MemberButton.vue";
import SignInButton from "../components/SignInButton.vue";

import PasswordlessAuthDialog from "../components/PasswordlessDialog.vue";
import WelcomeDialog from "../components/WelcomeDialog.vue";

import OrgCreateDialog from "../components/OrgCreateDialog.vue";

const route = useRoute();
const auth = useAuthStore();
const org = useOrgStore();

watch(
  () => route.params.orgUid,
  () => {
    if (route.params.orgUid) {
      org.setCurrentOrg(route.params.orgUid);
    }
  },
  { immediate: true }
);

const leftDrawerOpen = ref(false);

const toggleLeftDrawer = () => {
  leftDrawerOpen.value = !leftDrawerOpen.value;
};
</script>

<style lang="scss">
a.noLinkStyle {
  a:link {
    color: inherit;
    text-decoration: none;
  }
  a:visited {
    color: inherit;
    text-decoration: none;
  }
  a:hover {
    color: inherit;
    text-decoration: none;
  }
  a:active {
    color: inherit;
    text-decoration: none;
  }
}
</style>
