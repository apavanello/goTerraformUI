package hclparser

import (
	"fmt"
	"io/fs"
	"os"
	"path/filepath"
	"strings"

	"goTerraformUI/internal/models"

	"github.com/hashicorp/hcl/v2"
	"github.com/hashicorp/hcl/v2/hclsyntax"
)

// ParseDirectory escaneia um diretório recursivamente e monta o Grafo JSON
func ParseDirectory(rootPath string) (*models.GraphPayload, error) {
	graph := &models.GraphPayload{
		Nodes: make([]models.Node, 0),
		Edges: make([]models.Edge, 0),
	}

	err := filepath.WalkDir(rootPath, func(path string, d fs.DirEntry, err error) error {
		if err != nil {
			return err
		}

		// Pula pastas escondidas como .git e .terraform
		if d.IsDir() && strings.HasPrefix(d.Name(), ".") {
			return filepath.SkipDir
		}

		if !d.IsDir() && strings.HasSuffix(d.Name(), ".tf") {
			// Processa um arquivo Terraform
			if err := parseFile(path, graph); err != nil {
				fmt.Printf("Erro parseando %s: %v\n", path, err)
			}
		}
		return nil
	})

	if err != nil {
		return nil, fmt.Errorf("falha ao ler diretório: %w", err)
	}

	// ---- Passo 1: Inferir Edges (dependências) ----
	edgeSet := make(map[string]bool)
	// Índice de nós por ID e por Label para busca rápida
	idSet := make(map[string]int)
	for i, n := range graph.Nodes {
		idSet[n.ID] = i
	}

	for _, n1 := range graph.Nodes {
		for _, n2 := range graph.Nodes {
			if n1.ID == n2.ID {
				continue
			}
			for _, v := range n1.Data.Attributes {
				if strings.Contains(v, n2.ID) {
					edgeID := fmt.Sprintf("e-%s-%s", n2.ID, n1.ID)
					if !edgeSet[edgeID] {
						edgeSet[edgeID] = true
						graph.Edges = append(graph.Edges, models.Edge{
							ID:     edgeID,
							Source: n2.ID,
							Target: n1.ID,
							Label:  "depends_on",
							Type:   "smoothstep",
						})
					}
				}
			}
		}
	}

	// ---- Passo 2: Calcular profundidade hierárquica (topological layers) ----
	// Monta o grafo de dependências: inDegree e adjacência
	inDegree := make(map[string]int)
	children := make(map[string][]string)
	for _, n := range graph.Nodes {
		inDegree[n.ID] = 0
	}
	for _, e := range graph.Edges {
		inDegree[e.Target]++
		children[e.Source] = append(children[e.Source], e.Target)
	}

	// BFS por camadas (Kahn's algorithm)
	depth := make(map[string]int)
	queue := make([]string, 0)
	for _, n := range graph.Nodes {
		if inDegree[n.ID] == 0 {
			queue = append(queue, n.ID)
			depth[n.ID] = 0
		}
	}

	for len(queue) > 0 {
		current := queue[0]
		queue = queue[1:]
		for _, child := range children[current] {
			if depth[current]+1 > depth[child] {
				depth[child] = depth[current] + 1
			}
			inDegree[child]--
			if inDegree[child] == 0 {
				queue = append(queue, child)
			}
		}
	}

	// Nós sem camada definida (ciclos ou órfãos) recebem camada 0
	for _, n := range graph.Nodes {
		if _, ok := depth[n.ID]; !ok {
			depth[n.ID] = 0
		}
	}

	// ---- Passo 3: Distribuir nós por camada ----
	layers := make(map[int][]int) // layer -> [índices de nó]
	for i, n := range graph.Nodes {
		d := depth[n.ID]
		layers[d] = append(layers[d], i)
	}

	const nodeWidth = 300.0
	const nodeHeight = 180.0

	for layerIdx, nodeIndices := range layers {
		y := float64(layerIdx) * nodeHeight
		layerWidth := float64(len(nodeIndices))
		for col, idx := range nodeIndices {
			// Centraliza a camada horizontalmente
			x := (float64(col) - layerWidth/2.0) * nodeWidth
			graph.Nodes[idx].Position = models.Position{X: x, Y: y}
		}
	}

	return graph, nil
}

func parseFile(fullPath string, graph *models.GraphPayload) error {
	content, err := os.ReadFile(fullPath)
	if err != nil {
		return err
	}

	file, diags := hclsyntax.ParseConfig(content, fullPath, hcl.InitialPos)
	if diags.HasErrors() {
		return fmt.Errorf("erros diag: %s", diags.Error())
	}

	body, ok := file.Body.(*hclsyntax.Body)
	if !ok {
		return fmt.Errorf("body invãlido")
	}

	for _, block := range body.Blocks {
		switch block.Type {
		case "resource", "data":
			// ex: resource "aws_instance" "web"
			if len(block.Labels) < 2 {
				continue
			}
			tfType := block.Labels[0] // aws_instance
			name := block.Labels[1]   // web

			nodeID := fmt.Sprintf("%s.%s", tfType, name)

			node := models.Node{
				ID:   nodeID,
				Type: "resourceNode",
				Data: models.NodeData{
					Label:      name,
					TFType:     tfType,
					IsResolved: true,
					Attributes: extractAttributes(block, content),
				},
			}
			graph.Nodes = append(graph.Nodes, node)

		case "module":
			// ex: module "network"
			if len(block.Labels) < 1 {
				continue
			}
			name := block.Labels[0]

			node := models.Node{
				ID:   fmt.Sprintf("module.%s", name),
				Type: "moduleNode",
				Data: models.NodeData{
					Label:      name,
					TFType:     "module",
					IsResolved: false,
					Attributes: extractAttributes(block, content),
				},
			}
			graph.Nodes = append(graph.Nodes, node)

		case "variable":
			// ex: variable "region" { default = "us-east-1" }
			if len(block.Labels) < 1 {
				continue
			}
			name := block.Labels[0]
			attrs := extractAttributes(block, content)

			node := models.Node{
				ID:   fmt.Sprintf("var.%s", name),
				Type: "variableNode",
				Data: models.NodeData{
					Label:      name,
					TFType:     "variable",
					IsResolved: true,
					Attributes: attrs,
				},
			}
			graph.Nodes = append(graph.Nodes, node)

		case "output":
			// ex: output "vpc_id" { value = aws_vpc.main.id }
			if len(block.Labels) < 1 {
				continue
			}
			name := block.Labels[0]
			attrs := extractAttributes(block, content)

			node := models.Node{
				ID:   fmt.Sprintf("output.%s", name),
				Type: "outputNode",
				Data: models.NodeData{
					Label:      name,
					TFType:     "output",
					IsResolved: true,
					Attributes: attrs,
				},
			}
			graph.Nodes = append(graph.Nodes, node)

		case "locals":
			// locals é um bloco sem labels, com múltiplos atributos
			attrs := extractAttributes(block, content)
			for localName, localVal := range attrs {
				node := models.Node{
					ID:   fmt.Sprintf("local.%s", localName),
					Type: "localNode",
					Data: models.NodeData{
						Label:      localName,
						TFType:     "local",
						IsResolved: true,
						Attributes: map[string]string{"value": localVal},
					},
				}
				graph.Nodes = append(graph.Nodes, node)
			}
		}
	}

	return nil
}

// extractAttributes cria um mapa seguro dos metadados extraídos
func extractAttributes(block *hclsyntax.Block, content []byte) map[string]string {
	attrs := make(map[string]string)
	for name, attr := range block.Body.Attributes {
		// Simplificação bruta para um key = expression code
		// A extração real necessitaria do `cty.Value` mas string do Source Range atende o MVP
		rawContent := string(attr.Expr.Range().SliceBytes(content))
		// Trata aspas que a range string pode trazer para primitivos
		attrs[name] = rawContent
	}
	return attrs
}
