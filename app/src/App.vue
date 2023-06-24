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
        apiDomain: "http://localhost",
        apiBasePath: "/auth",
        appName: "OpenSociocracy",
    },
    recipeList: [
        Session.init(),
        Passwordless.init(),
    ],
});

</script>
