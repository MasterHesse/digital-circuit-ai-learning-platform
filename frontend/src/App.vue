<template>
  <div class="app">
    <AppNavBar />
    <main class="main">
      <router-view />
    </main>
  </div>
</template>

<script setup lang="ts">
import AppNavBar from './components/AppNavBar.vue'
</script>

<style scoped>
.main {
  max-width: 1100px;
  margin: 0 auto;
  padding: 18px 16px 40px;
}
</style>