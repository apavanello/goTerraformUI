# Plano: Setup de Infraestrutura (Build e Deploy)

Como é um app Desktop distribuído pelo framework Wails (Zero-Secrets cloud), a infraestrutura está ligada à esteira de CI local e remota.

## Construção do Repositório e CI

- [ ] Definir o `.gitignore` para a IDE, binários compilados (`build/bin/`) e pastas de Node/Go
- [ ] Criar arquivo `Makefile` ou `scripts.ps1` com os aliases de compilação principais (`build`, `dev`, `clean`)
- [ ] Construir arquivo `.github/workflows/build.yml`
  - [ ] Action: Configurar setup do Go e Node
  - [ ] Action: Run `go fmt` e `npm run lint`
  - [ ] Action: Compilador do Wails para o OS de teste (ex: Ubuntu-latest com GTK3 dependencies instaladas para build)
- [ ] Documentar no `README.md` da base o processo para SREs rodarem localmente o `wails build`
- [ ] Garantir que o binário gerado carrega ícones Custom (`build/appicon.png`)
