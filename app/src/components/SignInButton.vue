<template>
  <q-btn
    flat
    dense
    icon-right="mdi-login"
    @click="triggerSignInDialog"
    :label="$t('nav.signIn')" no-caps
  ></q-btn>
</template>

<script setup language="ts">

import { useAuthStore } from '../stores/auth';
const auth = useAuthStore();

const triggerSignInDialog = async () => {
  auth.setTargetUrl('/');
  auth.setSignInRequired(true);
  console.log(auth.targetUrl)
}

</script>
