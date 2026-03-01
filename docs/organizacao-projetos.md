# Organização de Projetos

Este documento prescreve a estrutura de diretórios, gerenciamento de dependências e a esteira do ciclo de vida para o repositório **GoTerraformUI**, baseado no modelo **Monorepo Enxuto**.

## Estrutura do Repositório (Monorepo)

O projeto será inteiramente gerenciado pela Root, onde o CLI do Wails orquestrará tanto o build do pacote Go quanto o build da SPA em Svelte/Vue.

```text
goTerraformUI/
├── build/                # Artefatos do Wails (Ícones do App, Manifestos do Windows)
├── frontend/             # O projeto da UI (Node.js Workspace)
│   ├── index.html        # Entrypoint do Vite
│   ├── package.json      # Dependências NPM (Svelte Flow, Tailwind)
│   ├── src/
│   │   ├── App.svelte    # Componente Principal
│   │   ├── components/   # Painel Lateral, Barra de Busca, Loader
│   │   ├── stores/       # Gerenciamento de Estado (Nodes, Edges, Themes)
│   │   └── wailsjs/      # (Auto-Gerado pelo Wails) Bindings exportados do Go
│   └── vite.config.js    # Config do bundler da Webview
├── internal/             # Código fonte principal do Backend em Go
│   ├── app/
│   │   └── app.go        # A Struct principal exposta para o Wails (Wails Bindings)
│   ├── hclparser/        # O core de negócio (leitura e AST)
│   │   ├── discovery.go  # Lógica de encontrar arquivos *.tf e *.tfvars
│   │   └── parser.go     # Utilização do `hcl/v2` para extrair entidades
│   ├── models/
│   │   └── graph.go      # Structs (DTOs) que virarão JSON (Nodes e Edges)
│   └── resolver/
│       └── git.go        # Wrapper para chamadas os/exec do Git na máquina
├── main.go               # Entrypoint do Go (Sobe a janela Desktop do Wails)
├── go.mod                # Dependências Go (hcl/v2, wailsapp, etc.)
└── wails.json            # Configuração do projeto Wails
```

## Bibliotecas e Frameworks Escolhidos
- **CLI/Bundler Foundation:** `Wails v2` (Fornece a Webview nativa e compilação multiplataforma).
- **Backend (Language):** Golang `1.22+` (Para performance e uso corporativo robusto).
- **Backend (Core Lib):** `github.com/hashicorp/hcl/v2` (A API oficial da Hashicorp para ler as entranhas do formato `.tf`).
- **Frontend (Framework):** `Svelte/SvelteKit` (Svelte gera bundles menores que React/Vue e possui store super limpa).
- **Frontend (UI Graph):** `@xyflow/svelte` (Também conhecido como Svelte Flow - Biblioteca standard da indústria Node-Based madura para desenhar o diagrama interativo).
- **Frontend (Styling):** `Tailwind CSS` (Para desenvolvimento das tooltips e painel lateral com aparência SRE-friendly: dark-mode nativo).

## Fluxo de Pipeline (CI/CD Local ou GitHub Actions)
Sendo um aplicativo Desktop OS-Dependent e um MVP, o pipeline será enxuto:
1. **Lint e Testes:** `go vet`, `go test ./...` e `npm run lint` no folder frontend.
2. **Build Local (Desenvolvimento):** O comando `wails dev` levantará todo o stack (vite no browser para frontend + go em watcher para hot-reload).
3. **Build Release:** O comando `wails build -windows` criará um executável autônomo `.exe` transparente e não assinado. Para uso em SREs localmente o binário deverá ser distribuído solto. No futuro (V2), pipeline complexo no GitHub Actions fará cross-compile para Mac/Windows/Linux.
