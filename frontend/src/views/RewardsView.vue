<template>
  <div class="flex flex-col justify-center h-[80%]">
    <div
      v-if="walletStore.account === null"
      class="flex flex-col items-center gap-4"
    >
      <img src="../assets/Fox.png" alt="MetaMask Fox" class="w-1/4 mx-auto" />

      <div class="text-3xl text-center">Kein Wallet, keine Belohnung!</div>
      <div class="text-4xl text-center">
        Verbinde dich und hol dir deine IJ-Token! 🚀
      </div>
      <span class="pi pi-angle-double-down" style="font-size: 1.5rem"></span>
      <Button
        class=""
        severity="contrast"
        @click="walletStore.connectWallet"
        label="Wallet verbinden"
      ></Button>
    </div>

    <div v-else class="flex flex-col items-center justify-evenly h-[90%] gap-8">
      <div class="flex flex-col items-center gap-4">
        <div class="text-3xl text-center">
          Hier sind deine hart verdienten Token!
        </div>

        <DashboardItem
          title="Dein Guthaben"
          icon="pi pi-crown"
          :value="`${currentBalance} IJT`"
          :index="2"
        >
        </DashboardItem>
      </div>

      <div class="flex flex-col items-center gap-2">
        <p>Du bist mit deinem Account: {{ walletStore.account }} verbunden.</p>
        <Button severity="secondary" @click="walletStore.disconnectWallet">
          Abmelden
        </Button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { onMounted, watch, onUnmounted, ref } from "vue";
import { useWalletStore } from "../stores/useWalletStore";
import DashboardItem from "../components/DashboardItem.vue";
const walletStore = useWalletStore();

watch(
  () => walletStore.account,
  async (newAccount) => {
    if (newAccount) {
      await walletStore.getBalance();
    }
  }
);

watch(
  () => walletStore.balance,
  (newBalance) => {
    console.log("Balance updated:", newBalance);
    currentBalance.value = newBalance;
  }
);

const currentBalance = ref(walletStore.balance);

let balanceInterval: NodeJS.Timeout | null = null;

onMounted(async () => {
  await walletStore.connectWallet();
  await walletStore.getBalance();

  balanceInterval = setInterval(() => {
    if (walletStore.account) {
      walletStore.getBalance();
    }
  }, 4000);
});

onUnmounted(() => {
  if (balanceInterval) clearInterval(balanceInterval);
});
</script>
