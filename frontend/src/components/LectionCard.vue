<template>
    <div class=" bg-surface-800 h-[90%]   shadow-sm hover:border-primary border border-surface-200 dark:border-surface-700 rounded m-2 p-6 transition-all hover:shadow-lg cursor-pointer"
        @click="startQuiz">


        <div class="flex flex-col items-start ">
            <div class="flex items-center justify-between w-full">
                <div class="font-medium text-xl">{{ lection.lectionName }}</div>
                <Tag v-if="severity" :severity="severity">{{ lection.difficultyLevel }}</Tag>

            </div>


            <div class=" mt-2 text-md text-gray-400"> {{ lection.lectionDescription }}</div>
        </div>


        <div class="mt-4">
            <div class="flex justify-between items-center">
                <div class="flex items-center text-sm text-gray-500">
                    <i class="pi pi-clock" style="font-size: 1rem; margin-right: 0.25rem;"></i>
                    <span>5 Minuten</span>
                </div>
                <div v-if="lection.isCompleted" class="flex items-center text-sm text-green-600">
                    <i class="pi pi-check-circle" style="font-size: 1rem; margin-right: 0.25rem;"></i>
                    <span>Abgeschlossen</span>
                </div>

            </div>
        </div>
    </div>
</template>

<script setup lang="ts">
import { computed } from "vue";
import { DifficultyLevel, type Lection } from "../types/CourseType";
import { useRouter } from "vue-router";

const props = defineProps<{ lection: Lection }>();
const router = useRouter();


const severity = computed(() => {
    switch (props.lection.difficultyLevel) {
        case DifficultyLevel.EASY:
            return "success";
        case DifficultyLevel.MEDIUM:
            return "warn";
        case DifficultyLevel.HARD:
            return "danger";
        default:
            return "info";
    }
});

const startQuiz = () => {
    router.push({ name: "Quiz", params: { lectionId: String(props.lection.lectionId) } });
};
</script>
