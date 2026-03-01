<p align="center">
  <img src="build/appicon.png" width="120" alt="GoTerraformUI Logo"/>
</p>

<h1 align="center">GoTerraformUI</h1>

<p align="center">
  <strong>Visualizador interativo de infraestrutura Terraform</strong><br/>
  Analise grafos de dependências, inspecione recursos e navegue pela sua IaC de forma visual.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Go-1.21+-00ADD8?logo=go&logoColor=white" alt="Go"/>
  <img src="https://img.shields.io/badge/Svelte-5-FF3E00?logo=svelte&logoColor=white" alt="Svelte"/>
  <img src="https://img.shields.io/badge/Wails-2.11-1F1F1F?logo=wails&logoColor=white" alt="Wails"/>
  <img src="https://img.shields.io/badge/Platform-Windows-0078D4?logo=windows&logoColor=white" alt="Windows"/>
</p>

---

## 📸 Visão Geral

GoTerraformUI é uma aplicação desktop nativa que parseia arquivos `.tf` (HCL) e renderiza um **grafo interativo de dependências** com layout hierárquico automático. Desenvolvido em Go (backend) + Svelte (frontend), empacotado com [Wails](https://wails.io).

### ✨ Features

| Feature | Descrição |
|---------|-----------|
| 🗂 **Seleção Nativa de Diretório** | Diálogo nativo do OS para selecionar projetos Terraform |
| 🧠 **Parse Inteligente de HCL** | Extrai `resource`, `data`, `module`, `variable`, `output` e `locals` |
| 📊 **Grafo Hierárquico** | Layout automático por camadas (topological sort) — dependências fluem de cima para baixo |
| 🎨 **Nós Coloridos por Tipo** | RES 🟢, MOD 🟣, VAR 🟡, OUT 🔵, LCL 🟠 |
| 🔍 **Busca Inteligente** | Filtra nós e **esconde edges irrelevantes**, mantendo apenas o subgrafo de dependências visível |
| 🔒 **Nós Ocultos Travados** | Nós filtrados ficam invisíveis e não podem ser arrastados acidentalmente |
| 📋 **Painel de Inspeção** | Clique em qualquer nó para ver o tipo, nome e todos os atributos HCL extraídos |
| 🌙 **Dark Theme Nativo** | Interface escura com tema integrado do SvelteFlow |
| ⚡ **Sem Dependências Externas** | Executável único, sem necessidade de Terraform, Node.js ou qualquer runtime |

---

## 🏗 Arquitetura

```
goTerraformUI/
├── app.go                    # Wails bindings (SelectDirectory, GetTerraformGraph)
├── main.go                   # Entrypoint Wails
├── internal/
│   ├── hclparser/
│   │   └── parser.go         # Parse HCL + inferência de edges + layout hierárquico
│   └── models/
│       └── graph.go          # Structs: Node, Edge, GraphPayload
├── frontend/
│   ├── src/
│   │   ├── App.svelte        # Canvas SvelteFlow + filtro reativo
│   │   ├── app.css           # Dark theme global
│   │   ├── components/
│   │   │   ├── TfNode.svelte # Nó customizado com badge por tipo
│   │   │   ├── TopBar.svelte # Barra superior com busca + botão carregar
│   │   │   └── Sidebar.svelte# Painel lateral de inspeção
│   │   └── stores/
│   │       └── graph.ts      # Svelte stores + loadDirectory()
│   └── package.json
├── examples/                 # Exemplos de Terraform para teste
│   ├── 01-simple-ec2/
│   ├── 02-vpc-network/
│   ├── 03-complex/
│   └── 04-enterprise/        # ~57 recursos (stress test)
└── wails.json
```

---

## 🚀 Pré-requisitos

| Ferramenta | Versão Mínima | Instalação |
|------------|---------------|------------|
| **Go** | 1.21+ | [go.dev/dl](https://go.dev/dl/) |
| **Wails CLI** | 2.11+ | `go install github.com/wailsapp/wails/v2/cmd/wails@latest` |
| **Bun** | 1.0+ | [bun.sh](https://bun.sh) |
| **WebView2** | (Windows) | Já incluso no Windows 10/11 |

---

## ⚡ Quick Start

### 1. Clonar o repositório

```bash
git clone https://github.com/apavanello/goTerraformUI.git
cd goTerraformUI
```

### 2. Instalar dependências do frontend

```bash
cd frontend && bun install && cd ..
```

### 3. Build de produção

```bash
wails build
```

O executável será gerado em:
```
build/bin/goTerraformUI.exe
```

### 4. Modo desenvolvimento (hot-reload)

```bash
wails dev
```

---

## 📖 Como Usar

1. **Abra o aplicativo** (`goTerraformUI.exe`)
2. Clique em **"Carregar Raiz"** na barra superior
3. Selecione um diretório contendo arquivos `.tf`
4. O grafo de dependências será gerado automaticamente
5. **Navegue** com scroll/drag, **busque** recursos pelo nome ou tipo
6. **Clique** em qualquer nó para inspecionar os atributos HCL no painel lateral

---

## 🔍 Sistema de Busca

A busca filtra de forma inteligente em **3 camadas de visibilidade**:

| Camada | Opacidade | Interação |
|--------|-----------|-----------|
| **Match direto** (nome/tipo contém a busca) | 100% | Clicável + arrastável |
| **Vizinhos** (conectados por edge ao match) | 85% | Clicável + arrastável |
| **Irrelevantes** | ~4% (invisível) | Bloqueado (sem drag/click) |

As **edges** (setas de dependência) também são filtradas — apenas conexões entre nós visíveis permanecem no grafo.

---

## 🧪 Exemplos Incluídos

| Pasta | Complexidade | Descrição |
|-------|-------------|-----------|
| `01-simple-ec2` | Básico | EC2 instance simples |
| `02-vpc-network` | Médio | VPC com subnets e security groups |
| `03-complex` | Alto | Módulos locais com dependências cruzadas |
| `04-enterprise` | Stress Test | ~57 recursos AWS (VPC, EKS, RDS, Lambda, CloudFront, WAF, etc.) |

---

## 🛠 Stack Tecnológica

- **Backend:** Go 1.21+ com [hashicorp/hcl/v2](https://github.com/hashicorp/hcl) para parsing nativo
- **Frontend:** Svelte 5 + [SvelteFlow](https://svelteflow.dev) (xyflow) para grafos interativos
- **Styling:** TailwindCSS 3 com dark theme customizado
- **Desktop:** [Wails v2](https://wails.io) — empacota Go + WebView2 num executável nativo
- **Package Manager:** [Bun](https://bun.sh) para o frontend

---

## 📝 Licença

MIT © [Alexandre Pavanello e Silva](mailto:apavanello@live.com)
