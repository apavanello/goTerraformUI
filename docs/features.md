# Funcionalidades Desejadas (Features)

Este documento detalha as funcionalidades macro do MVP do Visualizador de Repositórios Terraform, com base na intenção inicial.

## 1. Descoberta e Parsing de Código Terraform
- **Descrição:** O sistema deve ser capaz de ler um diretório local contendo código Terraform e extrair toda a estrutura de recursos, data sources, variáveis, outputs e módulos.
- **Responsabilidades:** Backend (Golang).
- **Skills:** Conhecimento da biblioteca `hcl/v2`, manipulação de arquivos e parsing de AST (Abstract Syntax Tree).
- **Esforço Estimado:** Médio.

## 2. Resolução de Módulos Externos (Git/Registry)
- **Descrição:** O sistema deve tentar resolver e baixar módulos referenciados externamente (ex: Git, Terraform Registry) para enriquecer a árvore de visualização. Se falhar (ex: módulo em repositório privado inacessível), deve tratar o erro graciosamente, exibindo o módulo como um "recurso externo desconhecido/opaco" sem quebrar a renderização do restante do diagrama.
- **Responsabilidades:** Backend (Golang).
- **Skills:** Interação com Git via CLI ou biblioteca Go, tratativas de rede, controle de concorrência e tratamento de falhas resiliente.
- **Esforço Estimado:** Complexo.

## 3. Gestão de Estado em Memória (Cache Inicial)
- **Descrição:** Para evitar lentidão de I/O em repositórios grandes, a estrutura parseada do Terraform e os metadados resolvidos devem ser carregados e mantidos em memória no backend. A UI consultará essa estrutura em memória.
- **Responsabilidades:** Backend (Golang).
- **Skills:** Estruturação de dados otimizada em Go (structs, maps, pointers), gerenciamento de ciclo de vida de dados e cache.
- **Esforço Estimado:** Simples/Médio (Go é muito eficiente nisso por natureza).

## 4. Renderização do Diagrama Node-Based (Estilo Lucidchart)
- **Descrição:** A interface deve renderizar os objetos extraídos do Terraform como nós interativos em um canvas em branco, ligando dependências lógicas (explícitas `depends_on` e implícitas via interpolação de variáveis/outputs).
- **Responsabilidades:** Frontend (Svelte/Vue envolto em Wails).
- **Skills:** Domínio de bibliotecas de grafos (Svelte Flow / Vue Flow), roteamento de arestas (edges), layouting automático (para não jogar todos os nós um em cima do outro).
- **Esforço Estimado:** Complexo.

## 5. Inspeção de Nós (Detalhes Estruturados)
- **Descrição:** Ao clicar em um nó (recurso ou módulo), um painel lateral deve se abrir exibindo os metadados detalhados em um formato limpo de chave-valor (sem exibir o HCL puro cru), permitindo entender como aquele objeto está configurado de forma legível.
- **Responsabilidades:** Frontend (Componentização UI) / Backend (Fornecimento do payload JSON).
- **Skills:** Construção de componentes UI reativos, estilização CSS (Tailwind ou similar).
- **Esforço Estimado:** Simples.

## 6. Navegação: Zoom e Pan
- **Descrição:** O canvas principal deve suportar operações de arrastar (pan) e zoom in/out (scroll do mouse ou botões de UI) para permitir a exploração de repositórios gigantes.
- **Responsabilidades:** Frontend.
- **Skills:** Utilização dos recursos nativos do Svelte Flow / Vue Flow.
- **Esforço Estimado:** Simples (já vem embutido em bibliotecas maduras).

## 7. Sistema de Filtros e Busca Omnibox
- **Descrição:** Permitir ao usuário buscar recursos por nome, filtrar por tipo (apenas `aws_instance`, apenas módulos, etc.) e isolar a visualização. Um filtro ativo deve destacar nós correspondentes e, opcionalmente, ocultar/esfumaçar nós irrelevantes.
- **Responsabilidades:** Frontend (Lógica de filtro visual) / Backend (Search engine rápido em memória).
- **Skills:** Algoritmos de busca (fuzzy search), reatividade avançada na UI do grafo.
- **Esforço Estimado:** Médio.

## 8. Empacotamento Desktop Nativo (Wails)
- **Descrição:** O aplicativo deve ser distribuído como um executável de desktop único, sem necessitar que o usuário instale dependências extras (como Node.js) ou abra um terminal paralelo.
- **Responsabilidades:** DevOps/Build.
- **Skills:** Experiência com o ciclo de vida do Wails CLI, geração de binários Go para target Windows.
- **Esforço Estimado:** Simples.
