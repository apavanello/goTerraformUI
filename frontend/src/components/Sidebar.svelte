<script lang="ts">
  import { selectedNode } from "../stores/graph";
  import { slide } from "svelte/transition";

  $: meta = $selectedNode?.data;
</script>

{#if $selectedNode}
  <div
    class="absolute top-0 right-0 w-[450px] max-w-full h-full bg-slate-900 border-l border-slate-700 shadow-2xl flex flex-col z-50 text-slate-200"
    transition:slide={{ duration: 250, axis: "x" }}
  >
    <div
      class="p-4 border-b border-slate-700 bg-slate-800 flex justify-between items-center"
    >
      <div>
        <h2
          class="text-sm uppercase tracking-wide text-slate-400 font-bold mb-1"
        >
          Inspecionar
        </h2>
        <p
          class="font-mono text-[13px] text-emerald-400 truncate w-60"
          title={$selectedNode.id}
        >
          {$selectedNode.id}
        </p>
      </div>
      <button
        class="text-slate-400 hover:text-white"
        on:click={() => selectedNode.set(null)}
      >
        <!-- Fechar Ícone SVGs -->
        <svg
          class="w-5 h-5"
          fill="none"
          stroke="currentColor"
          viewBox="0 0 24 24"
          ><path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M6 18L18 6M6 6l12 12"
          ></path></svg
        >
      </button>
    </div>

    <div
      class="flex-1 overflow-y-auto p-4 space-y-4 font-mono text-sm text-slate-300"
    >
      {#if meta}
        <div>
          <span
            class="text-slate-500 block text-xs uppercase font-sans tracking-wide"
            >Tipo</span
          >
          <span class="text-blue-400">{meta.tfType}</span>
        </div>
        <div>
          <span
            class="text-slate-500 block text-xs uppercase font-sans tracking-wide"
            >Nome</span
          >
          <span>{meta.label}</span>
        </div>

        {#if meta.attributes && Object.keys(meta.attributes).length > 0}
          <div>
            <span
              class="text-slate-500 block text-xs uppercase font-sans tracking-wide mb-2"
              >Atributos Extraídos</span
            >
            <div
              class="bg-slate-950 rounded border border-slate-800 p-2 overflow-x-auto"
            >
              {#each Object.entries(meta.attributes) as [key, value]}
                <div
                  class="grid grid-cols-[auto_1fr] gap-4 mb-2 border-b border-slate-800/50 pb-2 last:border-0"
                >
                  <span class="text-fuchsia-400">{key}:</span>
                  <span class="text-slate-400 break-all">{value}</span>
                </div>
              {/each}
            </div>
          </div>
        {/if}
      {/if}
    </div>
  </div>
{/if}
