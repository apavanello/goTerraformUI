<script lang="ts">
    import { Handle, Position } from "@xyflow/svelte";
    export let data: any;

    // Mapeamento visual por tipo de nó Terraform
    const typeConfig: Record<
        string,
        { badge: string; color: string; icon: string }
    > = {
        module: { badge: "MOD", color: "bg-fuchsia-600", icon: "📦" },
        variable: { badge: "VAR", color: "bg-amber-600", icon: "⚙️" },
        output: { badge: "OUT", color: "bg-sky-600", icon: "📤" },
        local: { badge: "LCL", color: "bg-orange-600", icon: "🏷" },
    };

    // Fallback para resources e data sources
    const defaultConfig = { badge: "RES", color: "bg-emerald-600", icon: "☁️" };

    $: config = typeConfig[data.tfType] || defaultConfig;
</script>

<div
    class="px-4 py-3 shadow-xl rounded-lg bg-slate-800 border border-slate-600 min-w-[180px] max-w-[260px] transition-transform hover:scale-105"
>
    <div class="flex items-center mb-1 gap-1.5">
        <div
            class={`rounded text-[9px] font-bold px-1.5 py-0.5 text-white ${config.color}`}
        >
            {config.badge}
        </div>
        <div
            class="text-sm font-bold text-slate-100 truncate"
            title={data.label}
        >
            {data.label}
        </div>
    </div>

    <div
        class="text-[10px] text-slate-400 font-mono mt-1 break-all bg-slate-900 rounded p-1"
    >
        {data.tfType}
    </div>

    {#if data.tfType === "variable" && data.attributes?.default}
        <div
            class="text-[9px] text-amber-400/80 mt-1 truncate"
            title={data.attributes.default}
        >
            default: {data.attributes.default}
        </div>
    {/if}

    {#if data.tfType === "output" && data.attributes?.value}
        <div
            class="text-[9px] text-sky-400/80 mt-1 truncate"
            title={data.attributes.value}
        >
            → {data.attributes.value}
        </div>
    {/if}

    {#if data.tfType === "local" && data.attributes?.value}
        <div
            class="text-[9px] text-orange-400/80 mt-1 truncate"
            title={data.attributes.value}
        >
            = {data.attributes.value}
        </div>
    {/if}

    <Handle
        type="target"
        position={Position.Top}
        class="w-4 h-4 !bg-slate-500 border-2 !border-slate-800"
    />
    <Handle
        type="source"
        position={Position.Bottom}
        class="w-4 h-4 !bg-emerald-500 border-2 !border-slate-800"
    />
</div>
