import { createRouter, createWebHistory } from "vue-router";

import type { RouteRecordRaw } from "vue-router";

import DashboardView from "../views/DashboardView.vue";
import CourseListView from "../views/CourseListView.vue";
import CourseOverview from "../views/CourseOverview.vue";
import LectionView from "../views/LectionView.vue";
import SettingsView from "../views/SettingsView.vue";
import RewardsView from "../views/RewardsView.vue";
import QuizView from "../views/QuizView.vue";

const routes: RouteRecordRaw[] = [
  { path: "/", component: DashboardView },
  { path: "/courselistview", component: CourseListView },
  {
    path: "/courselistview/:courseId",
    name: "course",
    component: CourseOverview,
    props: true,
  },

  {
    path: "/quiz/:lectionId",
    name: "Quiz",
    component: QuizView,
    props: true,
  },

  { path: "/rewards", component: RewardsView },
  { path: "/settings", component: SettingsView },
];

const router = createRouter({
  history: createWebHistory(),
  routes,
});

export default router;
