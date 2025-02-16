import { defineStore } from "pinia";

import { ref } from "vue";
import axios from "axios";
import type { Course } from "../types/CourseType";
interface RewardResponse {
  success: boolean;
  txRewardHash: string;
}

interface TxResponse {
  success: boolean;
  txHash: string;
}

interface CompletionResponse {
  success: boolean;
  completed: boolean;
}

export const useContractStore = defineStore("contractStore", () => {
  // just for testing purposes
  const rewardTxHash = ref<string>("");
  const completeLessonTxHash = ref<string>("");
  const completeCourseTxHash = ref<string>("");
  const isCompletedStatus = ref<boolean | null>(null);

  async function rewardStudent(
    student: string,
    courseId: number,
    lessonId: number,
    level: number
  ): Promise<void> {
    try {
      const response = await axios.post<RewardResponse>(
        "http://localhost:3001/completeLesson",
        {
          student,
          courseId,
          lessonId,
          level,
        }
      );
      rewardTxHash.value = response.data.txRewardHash;
      console.log("Reward successful. TX hash:", rewardTxHash.value);
    } catch (error) {
      console.error("Error rewarding student:", error);
    }
  }

  async function completeCourse(
    student: string,
    courseId: number
  ): Promise<void> {
    try {
      const response = await axios.post<TxResponse>(
        "http://localhost:3001/completeCourse",
        {
          student,
          courseId,
        }
      );
      completeCourseTxHash.value = response.data.txHash;
      console.log("Course completed. TX hash:", completeCourseTxHash.value);
    } catch (error) {
      console.error("Error completing course:", error);
    }
  }

  return { rewardStudent, completeCourse };
});
