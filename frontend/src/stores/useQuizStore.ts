import { defineStore } from "pinia";
import { ref, computed } from "vue";
import type { QuizQuestion, Lection } from "../types/CourseType";
import { useCourseStore } from "./useCourseStore";
export const useQuizStore = defineStore("quizStore", () => {
  const courseStore = useCourseStore();
  const questions = ref<QuizQuestion[]>([]);
  const currentQuestionIndex = ref(0);
  const selectedAnswers = ref<Record<number, number[]>>({});
  const score = ref(0);
  const currentLection = ref<Lection | null>(null);
  const hasFailed = ref(false);
  const isQuizCompleted = ref(false);
  const isCompleted = ref(false);

  const loadQuizFromLection = (lection: Lection) => {
    console.log(currentLection.value?.lectionId);

    if (lection.quizQuestions.length === 0) {
      console.warn("No quiz questions available for this lection.");
      return;
    }
    currentLection.value = lection;
    questions.value = lection.quizQuestions;
    currentQuestionIndex.value = 0;
    selectedAnswers.value = {};
    score.value = 0;
    isQuizCompleted.value = false;
    hasFailed.value = false;

    console.log(currentLection.value?.lectionId);
  };

  const currentQuestion = computed(
    () => questions.value[currentQuestionIndex.value] || null
  );

  const selectAnswer = (questionId: number, answerOptionId: number) => {
    if (!selectedAnswers.value[questionId]) {
      selectedAnswers.value[questionId] = [];
    }
    const question = questions.value.find((q) => q.questionId === questionId);
    if (question?.questionType === "SINGLE_CHOICE") {
      selectedAnswers.value[questionId] = [answerOptionId];
    } else {
      const index = selectedAnswers.value[questionId].indexOf(answerOptionId);
      if (index === -1) {
        selectedAnswers.value[questionId].push(answerOptionId);
      } else {
        selectedAnswers.value[questionId].splice(index, 1);
      }
    }
  };

  const checkAnswer = () => {
    if (!currentQuestion.value) return;

    const correctAnswers = currentQuestion.value.answerOptions
      .filter((opt) => opt.isCorrect)
      .map((opt) => opt.answerOptionId);

    const userAnswers =
      selectedAnswers.value[currentQuestion.value.questionId] || [];

    const isCorrect =
      correctAnswers.length === userAnswers.length &&
      correctAnswers.every((id) => userAnswers.includes(id));

    if (!isCorrect) {
      hasFailed.value = true;
      return;
    }

    score.value++;

    nextQuestion();
  };

  const calculateScore = () => {
    let newScore = 0;
    let hasFailed = false;

    questions.value.forEach((question) => {
      const correctAnswers = question.answerOptions
        .filter((opt) => opt.isCorrect)
        .map((opt) => opt.answerOptionId);

      const userAnswers = selectedAnswers.value[question.questionId] || [];

      const isCorrect =
        correctAnswers.length === userAnswers.length &&
        correctAnswers.every((id) => userAnswers.includes(id));

      if (isCorrect) {
        newScore++;
      } else {
        hasFailed = true;
      }
    });

    score.value = newScore;
    isQuizCompleted.value = true;

    if (!hasFailed) {
      markLectionAsCompleted();

      isCompleted.value = true;
    } else {
      isCompleted.value = false;
    }
  };

  const markLectionAsCompleted = () => {
    if (!currentLection.value) {
      console.warn(" No current lection available.");
      return;
    }

    if (!courseStore.currentCourse) {
      console.warn(" No current course found.");
      return;
    }

    console.log(
      `Marking lection ${currentLection.value.lectionId} as completed.`
    );
    currentLection.value.isCompleted = true;

    courseStore.setLectionDone(
      courseStore.currentCourse.courseId,
      currentLection.value
    );
  };

  const nextQuestion = () => {
    if (hasFailed.value) {
      isQuizCompleted.value = false;
      return;
    }

    if (currentQuestionIndex.value < questions.value.length - 1) {
      currentQuestionIndex.value++;
    } else {
      isQuizCompleted.value = true;
      if (currentLection.value) {
        currentLection.value.isCompleted = true;
      }
    }
  };
  const restartQuiz = () => {
    currentQuestionIndex.value = 0;
    selectedAnswers.value = {};
    score.value = 0;
    isQuizCompleted.value = false;
    isCompleted.value = false;
    hasFailed.value = false;
  };

  return {
    questions,
    currentQuestion,
    currentQuestionIndex,
    selectedAnswers,
    score,
    currentLection,
    isQuizCompleted,
    isCompleted,
    hasFailed,
    calculateScore,
    loadQuizFromLection,
    selectAnswer,
    checkAnswer,
    nextQuestion,
    restartQuiz,
  };
});
