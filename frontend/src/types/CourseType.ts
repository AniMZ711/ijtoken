export interface Course {
  courseId: number;
  courseName: string;
  imageUrl: string;
  courseDescription: string;
  lections: Lection[];
  isCompleted?: boolean;
}

export interface Lection {
  lectionId: number;
  courseId: number;
  lectionName: string;
  lectionDescription: string;
  difficultyLevel: DifficultyLevel;
  quizQuestions: QuizQuestion[];
  isCompleted?: boolean;
}

export interface QuizQuestion {
  questionId: number;
  lectionId: number;
  question: string;
  questionType: QuestionType;
  answerOptions: AnswerOption[];
}

export interface AnswerOption {
  answerOptionId: number;
  questionId: number;
  answer: string;
  isCorrect: boolean;
}

export enum QuestionType {
  SINGLE_CHOICE = "SINGLE_CHOICE",
  MULTIPLE_CHOICE = "MULTIPLE_CHOICE",
}

export enum DifficultyLevel {
  EASY = "EASY",
  MEDIUM = "MEDIUM",
  HARD = "HARD",
}

export function mapDifficultyToNumber(level: DifficultyLevel): number {
  switch (level) {
    case DifficultyLevel.EASY:
      return 1;
    case DifficultyLevel.MEDIUM:
      return 2;
    case DifficultyLevel.HARD:
      return 3;
    default:
      throw new Error("Invalid difficulty level");
  }
}
