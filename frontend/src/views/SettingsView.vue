<template>
  <h2 class="text-gray-400">
    Reset Button for resetting course progress / reload courses from json
  </h2>

  <Button class="mt-4" label="Reset" @click="resetAllProgress"> </Button>
</template>

<script setup lang="ts">
import { useCourseStore } from "../stores/useCourseStore";

const courseStore = useCourseStore();

const resetAllProgress = () => {
  courseStore.resetProgress();
};
</script>
