<template>
  <router-view />
</template>

<script setup>
import { defineComponent } from 'vue'

import SuperTokens from 'supertokens-web-js';
import Session from 'supertokens-web-js/recipe/session';
import Passwordless from 'supertokens-web-js/recipe/passwordless'

SuperTokens.init({
    appInfo: {
        apiDomain: "https://api.service.opensociocracy.org",
        apiBasePath: "/auth",
        appName: "OpenSociocracy",
    },
    recipeList: [
        Session.init(),
        Passwordless.init(),
    ],
});

</script>
