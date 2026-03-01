# Diagrama de Sequência

Este documento contém o diagrama de sequência focado no principal desafio técnico da Arquitetura: a comunicação entre a interface (Svelte/Vue) e a engine local (Go/Wails) para ler discos, montar o grafo e responder sem travar a interface do usuário local.

## Sequência de Inicialização e Refresh

Abaixo, detalhamos o fluxo síncrono/assíncrono da montagem do Grafo de Visualização.

```mermaid
sequenceDiagram
    participant U as SRE (Usuário)
    participant UI as Svelte Flow (Frontend)
    participant W as Wails IPC Bridge
    participant Go as Go Engine (Backend)
    participant FS as File System local

    U->>UI: Clica em "Carregar Diretório"
    UI->>UI: Ativa estado "Loading=true"
    UI->>W: window.go.main.App.ParseDirectory("/caminho/")
    
    W->>Go: Chamada Binding (ParseDirectory)
    Go->>FS: os.ReadDir() & filepath.Walk()
    FS-->>Go: Retorna lista de *.tf
    
    loop Para cada arquivo
        Go->>Go: hclv2.Parse() para AST
        Go->>Go: Identifica Blocks (Resource, Module)
    end
    
    Go->>Go: Constrói Grafo Otimizado em Memória
    Go->>Go: Gera payload JSON (Nodes + Edges)
    
    Go-->>W: Retorna Array JSON String/Struct
    W-->>UI: Promise resolvida (Nodes, Edges)
    
    UI->>UI: store.set(Nodes); store.set(Edges)
    UI->>UI: Força Svelte Flow a recalcular Layout
    UI->>UI: Desativa estado "Loading=false"
    UI-->>U: Grafo visualizado na tela
    
    %% Opcional: Timer Engine
    opt Auto-Refresh Ligado
        loop A cada 30 Segundos
            Go-->>W: wails.EventsEmit("refresh_ready")
            W-->>UI: Event Listener reage
            UI->>W: Chama window.go.main.App.ParseDirectory("/caminho/")
            Note right of UI: Repete o ciclo atualizando a Store silenciosamente (sem o Loader blockante)
        end
    end
```
