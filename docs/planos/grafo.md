# Plano: Construção das Funcionalidades Funcionais (Grafo Visual)

Este é o plano de alto nível focado no produto final: O Frontend que consome a Engine Go e desenha a UI.

## Feature: Renderização do Diagrama (UI/UX)
- [ ] Construir o Store do Svelte (`src/stores/graph.ts`) para manter Nodes e Edges do Go
- [ ] Configurar um componente Main contendo o canvas do `Svelte Flow` (`<SvelteFlow .../>`)
- [ ] Definir Componentes Customizados (Custom Nodes) para cada Recurso/Módulo no estilo Lucidchart com ícones
- [ ] Implementar Algoritmo de Layout (Dagre.js ou Elastik) integrado ao Svelte Flow para que os nós não fiquem sobrepostos (DAG auto-layout)
- [ ] Ligar Nodes com Edges e desenhar setas direcionais corretas com Tooltips de ("depends_on" / interpolação)

## Feature: Navegação e Inspeção de Metadados
- [ ] Ocultar HCL: Criar Sidebar fixa à direita ("Data Panel") da Webview
- [ ] Escutar Evento Svelte Flow (`onNodeClick`) e preencher o Painel com os Key/Values do DTO Go
- [ ] Customizar Zoom e Minimap Panel nativo do Svelte Flow com CSS Tailwind para "Dark Mode"
- [ ] Adicionar botão de `Refresh` forçado chamando `window.go.main.App.ParseDirectory`

## Feature: Sistema de Filtros (Omnibox) e Otimização (>500 nós)
- [ ] Implementar Caixa de Busca "Omnibox" superior no DOM
- [ ] Adicionar reatividade (watch do Vue/Svelte) na string de busca vs IDs de Node na Store
- [ ] Adicionar Classe CSS `.dimmed` ou `.hidden` nas Custom Nodes via Svelte bindings quando o array cru não der match.
- [ ] Configurar Viewport Rendering Limit no Svelte Flow (Ocultar visuais de nós fora da tela ou lazy rendering) se array crescer mais que 1000 nós *[Dependência Backend - Complexidade Alta]*
- [ ] Feature Final: Exibir nós opacos (vermelhos) para módulos Git que o App não resolveu via CLI Nativa.
