import { writable, derived } from 'svelte/store';
import type { Node, Edge } from '@xyflow/svelte';
import { GetTerraformGraph } from '../../wailsjs/go/main/App';

// Stores base derivadas do XYFlow
export const nodesStore = writable<Node[]>([]);
export const edgesStore = writable<Edge[]>([]);

// Stores de interface e filtro
export const isLoading = writable(false);
export const activeSearchQuery = writable("");
export const selectedNode = writable<any>(null); // Metadados do nó selecionado

// Ação de carregar o projeto nativamente pela ponte do Wails Go backend
export async function loadDirectory(path: string) {
    try {
        isLoading.set(true);
        // Reseta painel lateral
        selectedNode.set(null);

        // Chamada Assíncrona pro Golang (`app.go -> GetTerraformGraph`)
        const payload = await GetTerraformGraph(path);

        if (payload && payload.nodes) {
            nodesStore.set(payload.nodes as unknown as Node[]);
            edgesStore.set(payload.edges.map(e => ({
                ...e,
                animated: false,
                style: "stroke: #94a3b8; stroke-width: 1.5"
            })) as unknown as Edge[]);
        }
    } catch (e) {
        console.error("Erro ligando Wails:", e);
        alert("Erro no parsing: " + e);
    } finally {
        isLoading.set(false);
    }
}
