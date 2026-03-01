# Fluxos do Sistema

Este documento ilustra a jornada do usuário e os fluxos de dados do processo essencial (core) do MVP.

## Fluxo Principal de Carregamento

Descreve o caminho desde o momento que o usuário abre o App até visualizar a árvore.

```mermaid
flowchart TD
    A[Início: App Aberto] --> B[Usuário Clica em 'Abrir Pasta Terraform...']
    
    B --> C{Pasta Válida?}
    C -->|Não| D[Exibir Erro na UI]
    D --> B
    
    C -->|Sim| E[UI Mostra Spinner de Parsing]
    
    E --> F((Wails Binding: ParseDirectory))
    
    subgraph Backend Go
        F --> G[Caminhar pelos arquivos *.tf]
        G --> H[Extrair nós `hcl/v2` AST]
        H --> I{Tem Múltiplos Módulos?}
        I -->|Não| K[Construir JSON Grafo]
        I -->|Sim| J[Tentar Resolver Sources via .terraform ou Git]
        J --> K
    end
    
    K --> L((Retornar Payload JSON ao JS))
    
    subgraph Frontend Svelte/Vue
        L --> M[Receber Nodes/Edges]
        M --> N[Store recebe JSON de nós e arestas]
        N --> O[Svelte Flow / Vue Flow renderiza posições do DAG]
        O --> P[Carregamento Concluído e Spinner Oculto]
    end
```

## Fluxo Lógico do Motor de Busca / Filtro

Como os dados estão cacheados no frontend, a busca é instantânea e ocorre 100% no *client-side* webview.

```mermaid
flowchart LR
    A[Usuário digita na barra Search] --> B[Store dispara Mutação Reativa]
    B --> C{Termo confere com Node ID/Name/Type?}
    C -->|Sim| D[Atribuir Classe CSS 'highlight' ao Nó]
    C -->|Não| E[Atribuir Classe CSS 'dimmed/hidden' ao Nó]
    D --> F[Biblioteca de Graph Atualiza Render]
    E --> F
```
