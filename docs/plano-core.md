# Plano: Desenvolvimento das Funcionalidades Core (Engine Go+Wails)

Este plano contém o desenvolvimento intrínseco de Base (Core) de integração e Parse local.

## Core: Parsing e Modelagem (Golang)
- [ ] Definir as Structs (`models/graph.go`) com as assinaturas de Nodes e Edges
- [ ] Implementar a CLI nativa com Wails File Dialog (Seletor de Diretórios Nativos do OS Desktop)
- [ ] Criar o Parse Engine Básico `hclparser/parser.go` usando `hcl/v2`
- [ ] Implementar `filepath.Walk` para buscar recursivamente em toda root (ignorando `.git` e validando o `.terraform`)
- [ ] Criar rotina de parse para extrair ID do Recurso, Type (ex: `aws_instance`) e Name do Recurso
- [ ] Construir o resolvedor de relacionamentos (`depends_on` e Interpolação de Strings `${type.name}`) e salvar na Store local do Go

## Integração (Bindings)
- [ ] Mapear o struct no `app.go` (Bind do Wails) chamado `GetTerraformGraph(path string)`
- [ ] Fazer Go devolver o JSON puro (`json.Marshal`) das Structs populadas para o JS Client-Side
- [ ] Injetar mecanismo de Timer e Auto-Refresh em Go (usando `wails.EventsEmit`) para notificar UI de mudanças a cada X segundos
