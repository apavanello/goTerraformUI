package main

import (
	"context"
	"fmt"
	"goTerraformUI/internal/hclparser"
	"goTerraformUI/internal/models"

	"github.com/wailsapp/wails/v2/pkg/runtime"
)

// App struct
type App struct {
	ctx context.Context
}

// NewApp creates a new App application struct
func NewApp() *App {
	return &App{}
}

// startup is called when the app starts. The context is saved
// so we can call the runtime methods
func (a *App) startup(ctx context.Context) {
	a.ctx = ctx
}

// SelectDirectory abre o diálogo nativo do sistema operacional e devolve o caminho
func (a *App) SelectDirectory() (string, error) {
	dir, err := runtime.OpenDirectoryDialog(a.ctx, runtime.OpenDialogOptions{
		Title: "Selecione o diretório do projeto Terraform",
	})
	if err != nil {
		return "", err
	}
	return dir, nil
}

// GetTerraformGraph executa a leitura local e devolve a serialização de grafos
func (a *App) GetTerraformGraph(path string) (*models.GraphPayload, error) {
	graph, err := hclparser.ParseDirectory(path)
	if err != nil {
		return nil, fmt.Errorf("Erro ao parsear dados via hcl: %v", err)
	}
	return graph, nil
}
