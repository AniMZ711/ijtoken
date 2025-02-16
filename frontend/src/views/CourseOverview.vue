<script setup lang="ts">
import { useRoute, useRouter } from "vue-router";
import { useCourseStore } from "../stores/useCourseStore";
import { ref, onMounted, watch, computed } from "vue";
import Carousel from 'primevue/carousel';
import LectionCard from "../components/LectionCard.vue";
import CourseListCard from "../components/CourseListCard.vue";
import type { Course, Lection } from "../types/CourseType";


const route = useRoute();
const router = useRouter();
const courseStore = useCourseStore();
const courseId = Number(route.params.courseId);

onMounted(async () => {
    courseStore.setCurrentCourse(courseId);
});

const currentCourse = computed<Course | null>(() => courseStore.currentCourse);

const lections = computed<Lection[]>(() => currentCourse.value?.lections ?? []);

const startQuiz = (lectionId: number) => {
    if (!currentCourse.value) return;
    router.push({ name: "Quiz", params: { lectionId: String(lectionId) } });
};



const responsiveOptions = ref([
    {
        breakpoint: '1400px',
        numVisible: 2,
        numScroll: 1
    },
    {
        breakpoint: '1199px',
        numVisible: 3,
        numScroll: 1
    },
    {
        breakpoint: '767px',
        numVisible: 2,
        numScroll: 1
    },
    {
        breakpoint: '575px',
        numVisible: 1,
        numScroll: 1
    }
]);


</script>

<template>

    <div class="flex flex-col items-center mx-auto w-full max-w-4xl">
        <div class="flex flex-col items-start w-full  rounded-lg ">
            <div class=" flex flex-row gap-4">
                <Button @click=(router.back()) variant="text" icon="pi pi-arrow-left" severity="secondary"> </Button>
                <h1 class="text-3xl font-bold">Kurs: {{ currentCourse?.courseName }}</h1>

            </div>

            <Divider />

        </div>
        <div v-if="currentCourse">

            <div class=" flex flex-col items-center justify-center ">

                <CourseListCard :course="currentCourse" size="big" />


            </div>


            <div class=" max-w-6xl mx-auto p-8">
                <Carousel :value="lections" :circular="true" :num-visible="3" :num-scroll="1"
                    :responsiveOptions="responsiveOptions">
                    <template #item="{ data }: { data: Lection }">
                        <LectionCard :lection="data" />
                    </template>
                </Carousel>
            </div>
        </div>

        <p v-else>Loading course...</p>

    </div>
</template>
