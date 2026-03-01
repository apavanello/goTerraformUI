# Plano: Setup de Desenvolvimento

Este documento foca na configuração basal do ambiente e repositório.

## Tarefas de Construção de Repositório

- [ ] Instalar [Wails v2](https://wails.io/docs/gettingstarted/installation) na máquina local
- [ ] Inicializar o projeto (`wails init -n goTerraformUI -t svelte-ts`)
- [ ] Configurar o arquivo `go.mod` inicial
- [ ] Adicionar dep do parser Terraform (`go get github.com/hashicorp/hcl/v2/...`)
- [ ] Instalar dependências Frontend (`cd frontend && npm install`)
- [ ] Instalar as bibliotecas base de UI do Svelte (`npm i @xyflow/svelte tailwindcss`)
- [ ] Configurar TailwindCSS no frontend (`tailwind.config.js` e `app.css`)
- [ ] Ajustar o `wails.json` para refletir o nome do binário e comandos de build do Vite
- [ ] Validar ambiente rodando `wails dev` e confirmando Hello World do Svelte na janela Nativas
