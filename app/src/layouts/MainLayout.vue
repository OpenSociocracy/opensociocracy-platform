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

        <q-toolbar-title>
          <span
            ><router-link :to="{ name: 'home' }" class="navbar-link"
              >OpenSociocracy</router-link
            ></span
          >
        </q-toolbar-title>

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

    <q-drawer v-model="leftDrawerOpen" show-if-above bordered>
      <q-list>
        <q-item-label header> Essential Links </q-item-label>
      </q-list>
    </q-drawer>

    <q-page-container>
      <PasswordlessAuthDialog
        v-model="auth.signInRequired"
      ></PasswordlessAuthDialog>
      <router-view />
    </q-page-container>
  </q-layout>
</template>

<script setup>
import { defineComponent, ref } from "vue";

import { useAuthStore } from "../stores/auth";

import AppsButton from "../components/AppsButton.vue";
import NotificationsButton from "../components/NotificationsButton.vue";
import MemberButton from "../components/MemberButton.vue";
import SignInButton from "../components/SignInButton.vue";

import PasswordlessAuthDialog from "../components/PasswordlessDialog.vue";
import WelcomeDialog from "../components/WelcomeDialog.vue";

const leftDrawerOpen = ref(false);

const auth = useAuthStore();

const toggleLeftDrawer = () => {
  leftDrawerOpen.value = !leftDrawerOpen.value;
};
</script>
