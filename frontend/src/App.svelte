<script lang="ts">
  import { SvelteFlow, Background, Controls, MiniMap } from "@xyflow/svelte";
  import "@xyflow/svelte/dist/style.css";

  // Custom Components
  import TopBar from "./components/TopBar.svelte";
  import Sidebar from "./components/Sidebar.svelte";
  import TfNode from "./components/TfNode.svelte";

  // Stores
  import {
    nodesStore,
    edgesStore,
    selectedNode,
    activeSearchQuery,
  } from "./stores/graph";

  const nodeTypes = {
    resourceNode: TfNode,
    moduleNode: TfNode,
    variableNode: TfNode,
    outputNode: TfNode,
    localNode: TfNode,
  };

  // Reactivity: Handle node click to populate the sidebar
  function handleNodeClick({ node, event }) {
    if (node) {
      selectedNode.set(node);
    }
  }

  // Reactivity: filtragem inteligente de nós e edges
  $: matchedIds = new Set(
    $activeSearchQuery === ""
      ? $nodesStore.map((n) => n.id)
      : $nodesStore
          .filter(
            (n) =>
              n.id.toLowerCase().includes($activeSearchQuery.toLowerCase()) ||
              n.data?.tfType
                ?.toLowerCase()
                .includes($activeSearchQuery.toLowerCase()),
          )
          .map((n) => n.id),
  );

  // Nós vizinhos diretos (conectados por edge a um nó matched)
  $: neighborIds = new Set(
    $activeSearchQuery === ""
      ? []
      : $edgesStore
          .filter((e) => matchedIds.has(e.source) || matchedIds.has(e.target))
          .flatMap((e) => [e.source, e.target]),
  );

  // Todos os nós visíveis (matched + vizinhos)
  $: visibleIds = new Set([...matchedIds, ...neighborIds]);

  $: reactiveNodes = $nodesStore.map((node) => {
    const isDirectMatch = matchedIds.has(node.id);
    const isNeighbor = neighborIds.has(node.id);
    const isVisible = $activeSearchQuery === "" || isDirectMatch || isNeighbor;
    return {
      ...node,
      class: !isVisible
        ? "dimmed"
        : isNeighbor && !isDirectMatch
          ? "neighbor"
          : "",
      draggable: isVisible,
      selectable: isVisible,
    };
  });

  // Edges: só exibe edges onde AMBOS os nós são visíveis e pelo menos um é matched
  $: reactiveEdges = $edgesStore.map((edge) => {
    const sourceVisible = visibleIds.has(edge.source);
    const targetVisible = visibleIds.has(edge.target);
    const oneIsMatch =
      matchedIds.has(edge.source) || matchedIds.has(edge.target);
    const show =
      $activeSearchQuery === "" ||
      (sourceVisible && targetVisible && oneIsMatch);
    return {
      ...edge,
      hidden: !show,
    };
  });
</script>

<main class="w-screen h-screen relative bg-slate-900 border-none m-0 p-0">
  <TopBar />
  <Sidebar />

  <!-- Svelte Flow Canvas -->
  <div class="absolute inset-0 pt-14">
    <SvelteFlow
      nodes={reactiveNodes}
      edges={reactiveEdges}
      {nodeTypes}
      onnodeclick={handleNodeClick}
      colorMode="dark"
      fitView
    >
      <Background bgColor="#0f172a" patternColor="#334155" />
      <Controls />
      <MiniMap
        nodeStrokeColor="#10b981"
        nodeColor="#1e293b"
        maskColor="rgba(15, 23, 42, 0.7)"
      />
    </SvelteFlow>
  </div>
</main>
