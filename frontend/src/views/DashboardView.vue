<template>
  <div class="flex flex-col items-center mx-auto w-full max-w-4xl">
    <div class="flex flex-col items-start w-full rounded-lg gap-4">
      <h1 class="text-3xl font-bold">Willkommen zurück!</h1>
      <h2 class="text-xl font-semibold">Dashboard</h2>
    </div>
    <Divider />
    <div class="flex flex-col items-start w-full gap-4">
      <h3 class="text-md">
        Gib auch heute wieder alles, um maximale Belohnungen abzusahnen!
      </h3>
      <div class="w-full flex flex-wrap gap-4 justify-center items-center">
        <DashboardItem
          title="Abgeschlossene Lektionen"
          icon="pi pi-check-circle"
          :value="`${totalCompletedLections}`"
          :index="0"
        >
        </DashboardItem>
        <DashboardItem
          title="Bestandene Kurse"
          icon="pi pi-book"
          :value="`${totalCompletedCourses}`"
          :index="1"
        >
        </DashboardItem>
        <DashboardItem
          title="Erhaltene Rewards"
          icon="pi pi-crown"
          :value="`${currentBalance} IJT`"
          :index="2"
        >
        </DashboardItem>
      </div>
      <h3 class="text-lg">
        <i class="pi pi-star-fill"> </i>
        Empfohlener Kurs:
      </h3>
      <CourseListCard v-if="currentCourse" :course="currentCourse" size="big" />
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted } from "vue";
import CourseListCard from "../components/CourseListCard.vue";
import DashboardItem from "../components/DashboardItem.vue";
import { useCourseStore } from "../stores/useCourseStore";
import { useWalletStore } from "../stores/useWalletStore";

const store = useCourseStore();

const walletStore = useWalletStore();

const totalCompletedLections = computed(() =>
  store.getTotalCompletedLections()
);
const totalCompletedCourses = computed(() => store.getTotalCompletedCourses());

const currentBalance = computed(() => walletStore.balance);
const currentCourse = computed(() => store.currentCourse);

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
</script>
