<template>
  <div>
    Account:
    <vue-json-pretty :data="account.$state" />
    Auth:
    <vue-json-pretty :data="auth.$state" />
    Theme:
    <vue-json-pretty :data="theme.$state" />
  </div>
</template>

<script setup>

import VueJsonPretty from 'vue-json-pretty';
import 'vue-json-pretty/lib/styles.css';

import { useAuthStore } from '../stores/auth';
import { useAccountStore } from '../stores/account';
import { useThemeStore } from '../stores/theme';
const auth = useAuthStore();
const theme = useThemeStore();
const account = useAccountStore();


</script>
