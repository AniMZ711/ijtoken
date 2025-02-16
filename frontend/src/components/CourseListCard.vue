<template>
  <Card
    class="h-full bg-surface-800 shadow-lg"
    :class="cardWidth"
    style="overflow: hidden"
    @click="navigateToCourse"
  >
    <template #header
      ><img
        class="h-32 w-full object-cover"
        :src="course.imageUrl"
        alt="Course Title Image"
      />
    </template>
    <template #title> {{ course.courseName }}</template>
    <template #subtitle> {{ course.courseDescription }}</template>
    <template #content>
      <div class="flex justify-between mt-4">
        <span>Fortschritt</span>
        {{ progress }}%
      </div>
    </template>
    <template #footer class="">
      <ul class="list-none p-0 m-0 flex content-center mt-2 gap-2">
        <li
          v-for="index in totalLections"
          :key="index"
          class="flex-1 h-[7px] rounded"
          :class="{
            'bg-primary': index <= completedLections,
            'bg-gray-300': index > completedLections,
          }"
        ></li>
      </ul>
    </template>
  </Card>
</template>

<script setup lang="ts">
import { useRouter } from "vue-router";
import type { Course } from "../types/CourseType";
import { useCourseStore } from "../stores/useCourseStore";
import { computed } from "vue";
const router = useRouter();
const store = useCourseStore();

const props = defineProps<{
  course: Course;
  size?: "small" | "big";
}>();

const progress = store.getCourseProgress(props.course.courseId);

const totalLections = computed(
  () => store.getLectionsByCourseId(props.course.courseId).length
);

const completedLections = computed(
  () =>
    store
      .getLectionsByCourseId(props.course.courseId)
      .filter((lection) => lection.isCompleted).length
);

const navigateToCourse = () => {
  router.push({
    name: "course",
    params: { courseId: String(props.course.courseId) },
  });
};

const cardWidth = computed(() => {
  return props.size === "big" ? "w-full " : "w-72";
});
</script>
