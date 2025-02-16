<template>
    <div class="flex h-screen main-wrapper  ">
        <!-- Sidebar -->
        <div class=" sidebar fixed  h-[98%]  flex flex-col border border-transparent bg-surface-900 rounded-lg ">
            <nav class="grid mb-4 p-2">
                <div class="gap-3">

                    <Button icon="pi pi-bitcoin" severity="contrast" class="p-2">

                        <img alt="ijtTokenLogo" src="../assets/token.png">
                    </Button>
                </div>
            </nav>
            <nav class="grid gap-4 p-2">
                <router-link v-for="tab in tabs" :key="tab.route" :to="tab.route" class="flex items-center gap-3">
                    <Button v-tooltip="{ value: tab.name }" :icon="tab.icon" severity="secondary"></Button>
                </router-link>
            </nav>
            <nav class="mt-auto grid gap-1 p-2">
                <router-link class="flex items-center gap-3" to="/settings">
                    <Button v-tooltip="{ value: 'Einstellungen' }" icon="pi pi-cog" severity="secondary"></Button>
                </router-link>
            </nav>
        </div>

        <!-- Main Content -->
        <div class="main-content w-[95%] m-8   ">
            <router-view></router-view>
        </div>
    </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue';
const tabs = [
    { name: 'Dashboard', icon: 'pi pi-home', route: '/' },
    { name: 'Kursübersicht', icon: 'pi pi-book', route: '/courselistview' },
    { name: 'Rewards', icon: 'pi pi-crown', route: '/rewards' },
];
</script>

<style scoped>
.main-wrapper {

    margin: 0.5rem;
    /* border-width: 2px;
    border-style: solid;
    border-color: red; */

}

.main-content {
    margin-left: 5rem;
    /* border-width: 2px;
    border-style: solid;
    border-color: aqua; */

}

/* .main-container {
    max-width: 1448px;
    margin: 0 auto;
    padding-left: 1rem;
    padding-right: 1rem;
}

@media (max-width: 786px) {
    .main-container {
        padding-left: 2rem;
        padding-right: 2rem;
    }
}

@media (max-width: 486px) {
    .main-container {

        padding-left: 1rem;
        padding-right: 1rem;
    }
} */
</style>