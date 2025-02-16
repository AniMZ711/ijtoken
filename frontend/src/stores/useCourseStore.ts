import { defineStore } from "pinia";
import { ref, computed } from "vue";
import type { Course, Lection } from "../types/CourseType";
import { mapDifficultyToNumber } from "../types/CourseType";
import { useWalletStore } from "./useWalletStore";
import { useContractStore } from "./useContractStore";
export const useCourseStore = defineStore("courseStore", () => {
  const wallet = useWalletStore();
  const contract = useContractStore();

  const courses = ref<Course[]>([]);
  const currentCourse = ref<Course | null>(null);
  const loadCourses = async () => {
    try {
      const savedCourses = localStorage.getItem("courses");

      if (savedCourses) {
        courses.value = JSON.parse(savedCourses);
        console.log("📥 Loaded courses from localStorage!");
      } else {
        const response = await fetch("/courses.json");
        if (!response.ok) throw new Error("Failed to load courses.");
        courses.value = await response.json();
        console.log("Loaded courses from JSON file!");

        saveCourses();
      }
    } catch (e) {
      console.error("Error loading courses:", e);
    }
  };

  const saveCourses = () => {
    localStorage.setItem("courses", JSON.stringify(courses.value));
    console.log("💾 Courses saved to localStorage!");
  };

  const resetProgress = async () => {
    console.log("🗑 Resetting all progress...");

    localStorage.removeItem("courses");

    await loadCourses();

    console.log("🔄 Progress reset! Courses reloaded from JSON.");
  };

  const getCourseById = (courseId: number) => {
    return courses.value.find((course) => course.courseId === courseId);
  };

  const getLectionsByCourseId = (courseId: number): Lection[] => {
    return getCourseById(courseId)?.lections || [];
  };

  const setLectionDone = (courseId: number, lection: Lection) => {
    const studentAddress = wallet.account;
    if (!studentAddress) {
      console.error("No wallet for transaction found.");
      return;
    }

    //helper function to convert the difficulty level to a number as the contract expects a number for the difficulty level (workaround)
    const difficultyAsNumber = mapDifficultyToNumber(lection.difficultyLevel);

    contract.rewardStudent(
      studentAddress,
      courseId,
      lection.lectionId,
      difficultyAsNumber
    );

    console.log("Setting lection done", courseId, lection.lectionId);
    const courseIndex = courses.value.findIndex(
      (course) => course.courseId === courseId
    );
    if (courseIndex === -1) {
      console.warn(` Course with ID ${courseId} not found.`);
      return;
    }
    const lectionIndex = courses.value[courseIndex].lections.findIndex(
      (lection) => lection.lectionId === lection.lectionId
    );
    if (lectionIndex === -1) {
      console.warn(`Lection with ID ${lection.lectionId} not found.`);
      return;
    }
    courses.value[courseIndex].lections[lectionIndex] = {
      ...courses.value[courseIndex].lections[lectionIndex],
      isCompleted: true,
    };

    const totalLections = courses.value[courseIndex].lections.length;
    const completedLections = getCompletedLectionsCount(courseId);

    if (completedLections === totalLections) {
      console.log(`🎉 Marking Course ${courseId} as completed!`);

      contract.completeCourse(studentAddress, courseId);
      courses.value[courseIndex] = {
        ...courses.value[courseIndex],
        isCompleted: true,
      };
    }
    saveCourses();
  };

  const setCurrentCourse = (courseId: number) => {
    currentCourse.value =
      courses.value.find((course) => course.courseId === courseId) || null;
  };

  const getCompletedLectionsCount = (courseId: number): number => {
    const lections = getLectionsByCourseId(courseId) || [];

    return lections.filter((lection) => lection.isCompleted).length;
  };

  const getTotalCompletedLections = (): number => {
    let totalCompleted = 0;

    courses.value.forEach((course) => {
      totalCompleted += getLectionsByCourseId(course.courseId).filter(
        (lection) => lection.isCompleted
      ).length;
    });

    return totalCompleted;
  };

  const getTotalCompletedCourses = (): number => {
    return courses.value.filter((course) => course.isCompleted).length;
  };

  const getCourseProgress = computed(() => {
    return (courseId: number): number => {
      const totalLections = getLectionsByCourseId(courseId).length;
      if (totalLections === 0) return 0;
      return Math.round(
        (getCompletedLectionsCount(courseId) / totalLections) * 100
      );
    };
  });
  loadCourses();

  return {
    courses,
    currentCourse,
    loadCourses,
    setLectionDone,
    getCourseById,
    getLectionsByCourseId,
    getCompletedLectionsCount,
    setCurrentCourse,
    resetProgress,
    getCourseProgress,
    getTotalCompletedLections,
    getTotalCompletedCourses,
  };
});
