<template>
  <q-dialog ref="dialogRef" persistent>
    <q-card class="q-dialog-plugin">
      <q-form @submit="onSubmit" @reset="onReset">
        <q-bar class="dialog-qbar">
          {{  $t('orgs.create-dialog.dialog-title') }}
          <q-space></q-space>

          <q-btn dense flat icon="mdi-close" v-close-popup @click="auth.setTargetUrl(null)">
            <q-tooltip>{{$t('nav.close')}} </q-tooltip>
          </q-btn>
        </q-bar>
        <q-card-section>
          <div class="dialog-header row">
            <div class="col">
              {{ $t('orgs.create-dialog.create-form-title') }}
            </div>
          </div>
          <div class="dialog-body">
            {{ $t('orgs.create-dialog.create-form-body') }}
          </div>
        </q-card-section>
        <q-card-section>
          <q-input
            :label="$t('orgs.create-dialog.org-name-hint')"
            v-model="orgName"
          ></q-input>
        </q-card-section>
        <!-- buttons example -->
        <q-card-actions align="center">
          <q-btn
            icon="mdi-office-building-plus"
            color="primary"
            type="submit"
            :label="$t('orgs.create-dialog.submit-button')"
            :disable="!submitEnabled"
          ></q-btn>
        </q-card-actions>
      </q-form>
    </q-card>
  </q-dialog>
</template>

<script setup>
import { ref, computed, watch } from 'vue';
import { useDialogPluginComponent } from 'quasar';
import { useRouter } from 'vue-router';

import { useOrgStore } from '../stores/org';

import { useI18n } from "vue-i18n";

const { t } = useI18n();

const org = useOrgStore();

const props = defineProps({});

const router = useRouter();

const orgName = ref(null);
const validOrgName = ref(false);
const submitted = ref(false);
const submitEnabled = computed(() => {
  return orgName.value && ! submitted.value && validOrgName.value ? true : false;
});


const reset = () => {
  orgName.value = null;
  validEmail.value = false;
  submitted.value = false;
};

defineEmits([
  // REQUIRED; need to specify some events that your
  // component will emit through useDialogPluginComponent()
  //...useDialogPluginComponent.emits,
  'ok',
]);

const { dialogRef, onDialogOK } = useDialogPluginComponent();
// dialogRef      - Vue ref to be applied to QDialog
// onDialogHide   - Function to be used as handler for @hide on QDialog
// onDialogOK     - Function to call to settle dialog with "ok" outcome
//                    example: onDialogOK() - no payload
//                    example: onDialogOK({ /*...*/ }) - with payload
// onDialogCancel - Function to call to settle dialog with "cancel" outcome

const onOKClick = () => {
  // on OK, it is REQUIRED to
  // call onDialogOK (with optional payload)
  onDialogOK();
  //primary.value = editPrimary.value;
  // or with payload: onDialogOK({ ... })
  // ...and it will also hide the dialog automatically
};

const onSubmit = async () => {
  submitted.value = true;
  const orgData = await org.createOrg(orgName.value);

  console.log(orgData.uid)
  router.push('/org/'+ orgData.uid)


};

const onReset = () => {
  orgName.value = null;
};

watch(orgName, (newValue, oldValue) => {
  if (org.validateOrgName(newValue)) {
    validOrgName.value = true;
  } else {
    validOrgName.value = false;
  }
});

</script>

<style scoped lang="scss"></style>
