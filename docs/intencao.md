# Resumo da Intenção: Visualizador de Repositórios Terraform

## Visão Geral
Construir um MVP de uma ferramenta (focada em uso local) para gerar uma interface visual descritiva e em modo Somente Leitura (Read-Only) para repositórios Terraform complexos, repletos de módulos. A ferramenta criará diagramas semelhantes aos do Lucidchart, focando-se no código-fonte em tempo de design (estado antes da primeira execução ou pré-plan). 

## Estágio do Projeto
- **Nível de Maturidade:** MVP (Minimum Viable Product). O objetivo é construir uma versão inicial viável, focada no fluxo essencial, para validação de uso pelos times de engenharia.

## Problema Endereçado
- **Dor principal:** Dificuldade de se rastrear chamadas e dependências em repositórios gigantes, assim como a lentidão/dificuldade para realizar análises de impacto apenas olhando para arquivos de texto hierárquicos.
- **Proposta de Valor:** Transformar o código Terraform em um panorama visual claro do que será criado e manipulado, melhorando a análise de dependências antes mesmo de um `terraform plan`.

## Público-Alvo
- Engenheiros DevOps e SREs focados em infraestrutura, com objetivo principal de ajudar o quadro de profissionais de nível Pleno a se contextualizarem mais rapidamente em infraestruturas sofisticadas, provendo um mapa arquitetural claro.

## Design e Experiência do Usuário (Inspiração)
- **Visualização:** Fluxos estilo diagrama de blocos conectáveis (ex: Lucidchart).
- **Entidades:** Cada caixa/nó no diagrama representará resources, data sources, modules e possivelmente conexões de outputs/variáveis.
- **Interação:** Estritamente Read-Only. Servirá para navegação, zoom-in/zoom-out e consumo visual de metadados dos recursos, não para edição gráfica da infraestrutura.

## Considerações sobre a Arquitetura (Fyne vs Alternativas Web)
Embora a intenção inicial fosse usar **Golang + Fyne** para tudo (Backend e Frontend Desktop), o Fyne não possui controles nativos robustos para lidar facilmente com renderização de nós interativos e arestas com auto-cálculo de posicionamento ("node-based graph UIs"). A construção desse tipo de interface visual estilo Lucidchart do zero no Fyne seria extremamente custosa.
*   **Recomendação Arquitetural:** Empregar o **Golang** de forma brilhante no backend (usando pacote oficial `hcl/v2` ou via binários) para realizar o "lexical parsing" de todo o Terraform, descobrindo as dependências e relações. 
*   **Para a Interface (UI):** Adotar **Svelte** ou **Vue.js**, tirando proveito de pacotes específicos e maduros para grafos, como `Svelte Flow` ou `Vue Flow`.
*   **Para formato Desktop:** Podemos empacotar o Golang + Frontend Web utilizando o framework **Wails** (que gera um executável nativo usando webview leve em vez de embutir um browser completo, mantendo a sensação de app desktop).
