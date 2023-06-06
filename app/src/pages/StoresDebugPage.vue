<template>
  <div>
    Auth:
    <vue-json-pretty :data="auth.$state" />
    Theme:
    <vue-json-pretty :data="theme.$state" />
    Org:
    <vue-json-pretty :data="org.$state" />
    Orgs:
    <vue-json-pretty :data="[...org.$state.orgs.entries()]" />
    Nuggets:
    <vue-json-pretty :data="nugget.$state" />
  </div>
</template>

<script setup>

import VueJsonPretty from 'vue-json-pretty';
import 'vue-json-pretty/lib/styles.css';

import { useAuthStore } from '../stores/auth';
import { useThemeStore } from '../stores/theme';
import { useOrgStore } from '../stores/org';
import { useNuggetStore } from '../stores/nugget';
const auth = useAuthStore();
const theme = useThemeStore();
const org = useOrgStore();
const nugget = useNuggetStore();
</script>
