<template>
  <router-view />
</template>

<script>
import { defineComponent } from 'vue'

import SuperTokens from 'supertokens-web-js';
import Session from 'supertokens-web-js/recipe/session';
import Passwordless from 'supertokens-web-js/recipe/passwordless'

SuperTokens.init({
    appInfo: {
        apiDomain: "http://localhost:3000",
        apiBasePath: "/auth",
        appName: "OpenSociocracy",
    },
    recipeList: [
        Session.init(),
        Passwordless.init(),
    ],
});

export default defineComponent({
  name: 'App'
})
</script>
