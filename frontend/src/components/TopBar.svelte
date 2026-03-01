<script lang="ts">
    import {
        activeSearchQuery,
        loadDirectory,
        isLoading,
    } from "../stores/graph";
    import { SelectDirectory } from "../../wailsjs/go/main/App";

    let localInput = "";
    $: activeSearchQuery.set(localInput);

    async function handleLoad() {
        try {
            const dir = await SelectDirectory();
            if (dir) {
                await loadDirectory(dir);
            }
        } catch (e) {
            console.error(e);
        }
    }
</script>

<nav
    class="absolute top-0 w-full h-14 bg-slate-900 border-b border-slate-700 flex items-center px-4 justify-between z-40 shadow-md"
>
    <div class="flex items-center space-x-2">
        <div
            class="w-8 h-8 rounded bg-emerald-600 flex items-center justify-center font-bold text-white shadow shadow-emerald-900"
        >
            tf
        </div>
        <h1 class="text-slate-200 font-bold tracking-tight">GoTerraformUI</h1>
    </div>

    <!-- Omnibox Search -->
    <div class="flex-1 max-w-xl px-10 relative hidden sm:block">
        <input
            bind:value={localInput}
            type="text"
            placeholder="Buscar recursos (ex: aws_vpc) ou nomes..."
            class="w-full bg-slate-800 border border-slate-700 text-sm text-slate-300 rounded-md px-4 py-1.5 focus:outline-none focus:ring-1 focus:ring-emerald-500 focus:border-emerald-500 transition-shadow"
        />
        <svg
            class="w-4 h-4 text-slate-400 absolute right-12 top-2"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
            ><path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"
            ></path></svg
        >
    </div>

    <!-- Actions -->
    <div class="flex items-center space-x-3">
        {#if $isLoading}
            <div
                class="animate-spin w-5 h-5 border-2 border-emerald-500 border-t-transparent rounded-full"
            ></div>
            <span class="text-xs font-mono text-slate-400">Parsing...</span>
        {:else}
            <button
                on:click={handleLoad}
                class="bg-indigo-600 hover:bg-indigo-500 text-white px-3 py-1.5 rounded text-sm font-medium transition-colors shadow"
            >
                Carregar Raiz
            </button>
        {/if}
    </div>
</nav>
