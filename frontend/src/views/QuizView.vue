<script setup lang="ts">
import { computed, onMounted, ref, watch } from "vue";
import { useQuizStore } from "../stores/useQuizStore";
import { useCourseStore } from "../stores/useCourseStore";
import { useRouter, useRoute } from "vue-router";
const router = useRouter();
const route = useRoute();
const quizStore = useQuizStore();
const courseStore = useCourseStore();

const lectionId = ref(Number(route.params.lectionId));

const currentLection = computed(() => {
    const lections = courseStore.getLectionsByCourseId(
        courseStore.currentCourse?.courseId ?? 0
    );
    const lection = lections.find((l) => l.lectionId === lectionId.value);
    return lection || null;
});

const loadLectionQuiz = () => {
    quizStore.restartQuiz();

    if (currentLection.value) {
        quizStore.loadQuizFromLection(currentLection.value);
    } else {
        console.log("No lection found");
    }
};

onMounted(loadLectionQuiz);

watch(
    () => route.params.lectionId,
    (newLectionId) => {
        lectionId.value = Number(newLectionId);
        quizStore.restartQuiz();
        loadLectionQuiz();
    }
);

const isSelected = ref<Record<number, boolean>>({});
const isAnswerSelected = (answerOptionId: number) =>
    isSelected.value[answerOptionId] ?? false;

const toggleAnswer = (answerOptionId: number) => {
    if (isSelected.value[answerOptionId]) {
        delete isSelected.value[answerOptionId];
    } else {
        isSelected.value[answerOptionId] = true;
    }
    quizStore.selectAnswer(quizStore.currentQuestion?.questionId, answerOptionId);
};

const goToPreviousQuestion = () => {
    if (quizStore.currentQuestionIndex > 0) quizStore.currentQuestionIndex--;
};
const goToNextQuestion = () => {
    if (quizStore.currentQuestionIndex < quizStore.questions.length - 1)
        quizStore.currentQuestionIndex++;
};

const submitQuiz = () => quizStore.calculateScore();

const restartQuiz = () => {
    isSelected.value = {};
    quizStore.restartQuiz();
};

const currentQuestion = computed(() => quizStore.currentQuestion);
</script>

<template>
    <div class="flex flex-col items-center mx-auto w-full max-w-4xl">
        <h1 class="text-3xl">Lektion: {{ currentLection?.lectionName }}</h1>

        <div class="mt-8" v-if="!quizStore.isQuizCompleted">
            <h2>
                Frage {{ quizStore.currentQuestionIndex + 1 }} von
                {{ quizStore.questions.length }}
            </h2>
            <div class="text-3xl">{{ currentQuestion?.question }}</div>

            <ul>
                <li v-for="option in currentQuestion?.answerOptions" :key="option.answerOptionId"
                    @click="toggleAnswer(option.answerOptionId)"
                    class="p-4 m-4 rounded border border-transparent cursor-pointer transition-all hover:border-primary-500"
                    :class="{
                        'bg-primary text-surface-800': isAnswerSelected(
                            option.answerOptionId
                        ),
                        'bg-surface-500 ': !isAnswerSelected(option.answerOptionId),
                    }">
                    <label class="flex items-center cursor-pointer">
                        {{ option.answer }}
                    </label>
                </li>
            </ul>
            <div class="flex justify-between m-4">
                <Button severity="secondary" :disabled="quizStore.currentQuestionIndex === 0"
                    @click="goToPreviousQuestion" label="Zurück" icon="pi pi-arrow-left" icon-pos="left" />
                <Button v-if="
                    quizStore.currentQuestionIndex === quizStore.questions.length - 1
                " severity="success" @click="submitQuiz" label="Quiz abschließen" icon="pi pi-check" />
                <Button v-else severity="secondary" :disabled="quizStore.currentQuestionIndex === quizStore.questions.length - 1
                    " @click="goToNextQuestion" label="Weiter" icon="pi pi-arrow-right" icon-pos="right" />
            </div>
        </div>

        <div v-else class="mt-8">
            <div v-if="quizStore.isCompleted" class=" ">
                <div class="flex flex-col items-center gap-4">
                    <h2 class="text-green-500 text-4xl">
                        🎉 Quiz erfolgreich abgeschlossen! Du hast bestanden!
                    </h2>
                    <h3>
                        Du hast alle Fragen ({{ quizStore.score }}/{{
                            quizStore.questions.length
                        }}) richtig beantwortet.
                    </h3>

                    <Button @click="router.push('/rewards')" label="Rewards ansehen" icon="pi pi-crown">
                    </Button>

                    <Button @click="router.back()" label="Zurück zum Kurs" severity="secondary" icon="pi pi-arrow-left">
                    </Button>
                </div>
            </div>
            <div v-else>

                <div class="flex flex-col items-center gap-4">

                    <h2 class="text-red-500 text-4xl">
                        ❌ Quiz nicht bestanden. Versuche es nochmal!
                    </h2>
                    <p>
                        Du hast {{ quizStore.score }}/{{ quizStore.questions.length }} Fragen
                        richtig beantwortet.
                    </p>

                    <Button @click="restartQuiz" label="Quiz erneut durchführen" icon="pi pi-replay"></Button>
                    <Button @click="router.back()" severity="secondary" label="Zurück zum Kurs" icon="pi pi-arrow-left">
                    </Button>
                </div>
            </div>
        </div>
    </div>
</template>
