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
          Base App
        </q-toolbar-title>

        <div> <q-btn label="Sign In" aria-label="Sign In" @click="auth.setSignInRequired(true)" color="secondary"></q-btn> </div>
      </q-toolbar>
    </q-header>

    <q-drawer
      v-model="leftDrawerOpen"
      show-if-above
      bordered
    >
      <q-list>
        <q-item-label
          header
        >
          Essential Links
        </q-item-label>


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
import { defineComponent, ref } from 'vue'

import { useAuthStore } from '../stores/auth';

import PasswordlessAuthDialog from '../components/PasswordlessDialog.vue';



    const leftDrawerOpen = ref(false)

    const auth = useAuthStore();


    const toggleLeftDrawer = () => {
        leftDrawerOpen.value = !leftDrawerOpen.value
      };


</script>
