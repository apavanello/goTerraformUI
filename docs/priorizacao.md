# Priorização de Funcionalidades (MoSCoW)

Este documento avalia e prioriza as funcionalidades mapeadas para o MVP do Visualizador de Repositórios Terraform, utilizando o método **MoSCoW** (Must Have, Should Have, Could Have, Won't Have).

| Feature / Funcionalidade | Escopo | MoSCoW | Esforço (T-) | Complexidade | Observações / Detalhamento Técnico |
| :--- | :--- | :---: | :---: | :---: | :--- |
| **1. Descoberta e Parsing de Código Terraform** | Funcional (Backend) | **MUST** | Médio | Média | Core da ferramenta. Deve ler os arquivos `.tf`, `.tfvars` e estruturar a AST utilizando `hcl/v2`. |
| **2. Gestão de Estado em Memória (Cache)** | Não-funcional (Backend) | **MUST** | Simples | Baixa | Crucial para garantir performance na UI ao não reler discos a cada interação da árvore do usuário. |
| **3. Renderização do Diagrama Node-Based** | Funcional (Frontend) | **MUST** | Complexo | Alta | O coração visual do MVP. Deve desenhar os recursos, módulos e ligações com layouting auto-organizado (DAG - Directed Acyclic Graph). |
| **4. Inspeção de Nós (Detalhes Estruturados)** | Funcional (Frontend) | **MUST** | Simples | Baixa | Painel lateral com metadados em formato Chave-Valor legível (nome, provider, tipo, status de resolução). Sem exibir raw HCL. |
| **5. Navegação: Zoom e Pan** | Funcional (Frontend) | **MUST** | Simples | Baixa | Essencial para repositórios que gerem mais de uma dezena de recursos na tela. Nativo na maioria das libs Node-Based. |
| **6. Empacotamento Desktop Nativo (Wails)** | Não-funcional (DevOps) | **SHOULD** | Simples | Baixa | Facilita a adoção por Plenos. Pode ser adiado (rodando como WebApp local no browser temporariamente) se o parsing e o diagrama atrasarem, mas é altamente desejado. |
| **7. Sistema de Filtros e Busca Omnibox** | Funcional (Frontend) | **SHOULD** | Médio | Média | Muito importante para repositórios gigantes, porém não impeditivo para um MVP funcional provar seu valor inicial. |
| **8. Resolução de Módulos Externos (Git/Registry)** | Funcional (Backend) | **COULD** | Complexo | Alta | Como mencionado, se falhar ou não der tempo pro MVP, recursos opacos já geram valor. O download e resolução recursiva de módulos na nuvem entra como um diferencial futuro ou escopo flexível nesta fase. |
| **9. Suporte a Renderização Grande (> 500 nós)** | Não-funcional (Frontend) | **MUST** | Médio | Média | Uso de lazy loading / clustering via UI lib para evitar travamentos em grandes repositórios. |
| **10. Tempo de Parse Máximo (< 20s)** | Não-funcional (Backend) | **MUST** | Simples | Média | Backend usa goroutines sem forçar hardware de SRE desnecessariamente. Loader visual é mandatório. |
| **11. Atualização via Timer (Refresh Semi-Auto)** | Funcional / Integrado | **SHOULD** | Médio | Alta | Em vez de *hot-reload* que carrega tudo a cada salvamento rápido, oferecer um timer ajustável para recarregar. |
| **12. Zero-Secrets (Acesso Git/Registry Passivo)** | Não-funcional (Segurança) | **MUST** | Simples | Baixa | Nenhuma entrada ou criptografia de keys; tudo é transacionado passivamente confiando nos tokens/agentes do OS host. |
