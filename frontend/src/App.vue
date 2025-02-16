<script setup lang="ts">
import { onMounted } from "vue";
import { useCourseStore } from "./stores/useCourseStore";
import BaseLayout from "./layout/BaseLayout.vue";



const courseStore = useCourseStore();

onMounted(() => {
  courseStore.loadCourses();
});

</script>

<template>

  <BaseLayout></BaseLayout>

</template>

<style scoped></style>
