<template>

    <div class=" h-32  min-w-48 max-w-72  w-full rounded-lg 	
  px-4 py-6  flex flex-col " :class="[backgroundColor, textColor]">


        <div class="w-full flex flex-row items-start justify-between">
            <div class="ml-2"> {{ props.title }}</div>
            <i style="font-size: 2.0rem" :class="props.icon"></i>

        </div>

        <div class=" ml-2 text-4xl font-semibold">
            {{ props.value }}
        </div>
    </div>

</template>

<script setup lang="ts">

import { ref, computed } from 'vue';

const props = defineProps<{
    title: string;
    icon: string;
    value: string | number;
    index: number;
}>();


const colors = ['bg-primary-500', 'bg-surface-800', 'bg-surface-100'];

const backgroundColor = computed(() => colors[props.index % colors.length]);

const textColor = computed(() => {
    return backgroundColor.value === 'bg-surface-100' ? 'text-surface-800' : 'text-white';
});

</script>