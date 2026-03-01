# Requisitos Não-Funcionais

Este documento detalha os requisitos técnicos (Performance, Escalabilidade, Segurança, UX) que balizarão o desenho de arquitetura do MVP do Visualizador de Repositórios Terraform.

## 1. Performance e Escalabilidade (Rendering & Parsing)
- **Volume de Nós (UI):** O Frontend deve suportar a renderização fluida (sem *lag* de scroll) de diagramas de tamanho **Grande (~500 recursos/módulos)** de forma simultânea. Requer o uso apropriado de *lazy loading* ou controle de visibilidade (ex: agrupamento de Sub-grafos/Clusters) nativo da biblioteca de Grafos.
- **Tempo de Resposta (Load Inicial):** O tempo desde a seleção do diretório até o gráfico completo ser exibido tem como meta o **limite máximo de 10 a 20 segundos**. O Backend Golang deve balancear a otimização da árvore de análise (concorrência leve), sabendo que o público-alvo (SREs) costuma deter hardware com bons recursos (CPU/RAM).
- **Indicador de Processamento:** Obrigatoriamente, a interface deve não bloquear e apresentar um Loader/Spinner claro e informativo do progresso (ex: "Parsing 45 de 200 arquivos .tf...").

## 2. Fluidez de UX e Integração ao Fluxo de Trabalho
- **Atualização Semiestática com Watcher:** O fluxo de vida esperado é a ferramenta ficar aberta *side-by-side* com a IDE (VSCode). Para não forçar um *Reload Total* pesadíssimo:
  - O sistema deve implementar um mecanismo de Refresh opcional baseado em **Timer (ex: a cada 15, 30 segundos, ou Auto-Refresh Desligado)**.
  - Para garantir a fluidez da UI e evitar flicker de recarregamento, o motor de Golang tentará fazer um parse incremental ou o frontend realizará comparações do estado atual vs. o novo para redesenhar o grafo sem reiniciar a visão do usuário completamente.
  - Como *fallback*, um botão manual "Recarregar Árvore" deve existir.

## 3. Segurança e Acesso a Recursos
- **Gestão de Segredos / Credenciais:** Requisito rigoroso: **Nenhum**. A aplicação seguirá o princípio de Confiança no OS Host (Passiva/Transparente). 
- **Execução do Git/Terraform:** O Golang fará chamadas usando subprocessos locais confiando que o ambiente e terminal do desenvolvedor já possui a configuração devida de SSH (*ssh-agent*) e credenciais de Registry (em `~/.terraform.d/credentials.tfrc.json`). Se a clonagem falhar por "Acesso Negado", o erro deve ser tratado no Backend e reportado na UI pacificamente como um módulo externo não-resolvido.

## 4. Portabilidade (Empacotamento)
- **Formato Final:** A aplicação será um **binário estático ou standalone** no formato Desktop gerado pelo Wails (Windows `.exe`, macOS `.app`, Linux). Não dependerá da inicialização do NodeJS por parte do usuário final, reduzindo drasticamente o esforço de adoção da ferramenta por novos membros dos times.
