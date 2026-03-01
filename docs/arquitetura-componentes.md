# Arquitetura de Componentes

Este documento descreve a arquitetura do **GoTerraformUI**, um aplicativo desktop focado na visualização de repositórios Terraform, baseado no framework Wails.

A decisão arquitetural principal baseia-se em um **Monorepo Enxuto** com comunicação via **Bindings Nativos (Wails)** e um **Store Global de UI** no Frontend.

## Diagrama de Contexto (C4 Nível 1)

```mermaid
C4Context
      title Diagrama de Contexto do Sistema - GoTerraformUI

      Person(sre, "Engenheiro SRE / DevOps", "Usuário que precisa visualizar dependências de infraestrutura Terraform.")

      System(goterraformui, "GoTerraformUI", "Aplicativo Desktop gerado via Wails. Fornece visualização visual (read-only) de infraestruturas locais.")

      System_Ext(filesystem, "File System (Local)", "Diretórios contendo arquivos .tf, .tfvars locais e cache do .terraform.")
      System_Ext(git_ssh, "Git / SSH Agent (Local)", "Motor do SO para autenticação transparente e clone de módulos remotos.")

      Rel(sre, goterraformui, "Abre a UI e escolhe o diretório do projeto Terraform")
      Rel(sre, filesystem, "Edita arquivos via IDE em paralelo")
      Rel(goterraformui, filesystem, "Carrega arquivos .tf e faz parsing HCL")
      Rel(goterraformui, git_ssh, "Delega chamadas para clone de módulos remotos")
```

## Diagrama de Container (C4 Nível 2)

```mermaid
C4Container
    title Diagrama de Containers - GoTerraformUI

    Person(sre, "Engenheiro SRE", "Interage com a UI nativa.")

    Container_Boundary(wails_app, "Binário Wails (GoTerraformUI.exe / .app)") {
        Container(frontend, "Frontend SPA (Svelte/Vue)", "Webview", "Renderiza a UI nativa, desenha o Node-Based Graph (Flow) e mantém as Stores de Memória.")
        Container(backend, "Go Engine (Backend)", "Golang", "Processa o FS local, roda o Parser HCLv2 e expõe Nativos pro Frontend.")
    }

    System_Ext(filesystem, "Sistema de Arquivos", "Arquivos Locais")
    System_Ext(git_ssh, "Git CLI (Host)", "Utilitário nativo de rede do host")

    Rel(sre, frontend, "Interage com Canvas (Zoom, Pan, Busca)")
    Rel(frontend, backend, "Invoca funções via Wails Bindings JS (IPC)")
    Rel(backend, frontend, "Emite Wails Events (Refresh/Logs)")
    Rel(backend, filesystem, "I/O (Read-Only) nos arquivos .tf")
    Rel(backend, git_ssh, "Executa 'git clone' via os/exec se achar módulos no registry remoto")
```

## Organização de Componentes Internos
- **Frontend SPA**: Framework Svelte ou Vue (com Vite). Uso da lib `Svelte Flow` ou `Vue Flow` para plotagem das caixas. Uso de Pinia ou Svelte Stores para manter a listagem de *nodes* e *edges*.
- **Backend (Go)**:
  - `parser`: Pacote envolvendo `hashicorp/hcl/v2` para ler AST.
  - `resolver`: Pacote para interpretar caminhos de módulos (local vs. Git).
  - `wails_bindings`: Structs exportadas com os métodos que serão chamados pelo JS (`GetTerraformGraph(path string)`).
