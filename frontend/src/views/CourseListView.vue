<script setup lang="ts">
import { useCourseStore } from "../stores/useCourseStore";
import { onMounted } from "vue";
import { useRouter } from "vue-router";
import CourseListCard from "../components/CourseListCard.vue";
const courseStore = useCourseStore();
const router = useRouter();


const goToCourseOverview = (courseId: number) => {
    router.push({ name: "course", params: { courseId: String(courseId) } }); // Ensure it's a string
};
</script>

<template>

    <div class="flex flex-col items-center mx-auto w-full max-w-4xl">
        <!-- Title Section -->
        <div class="flex flex-col items-start w-full  rounded-lg gap-4">
            <h1 class="text-3xl font-bold">Meine Kurse</h1>
            <h2 class="text-xl font-semibold">Kursübersicht</h2>
        </div>

        <Divider />

        <!-- Course List -->
        <div class="w-full flex flex-wrap justify-start gap-4 mt-2">
            <CourseListCard v-for="course in courseStore.courses" :key="course.courseId" :course="course" />
        </div>

    </div>

</template>
