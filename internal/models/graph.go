package models

// GraphPayload é o envelope final enviado para o Webview (Svelte)
type GraphPayload struct {
	Nodes []Node `json:"nodes"`
	Edges []Edge `json:"edges"`
}

// Node representa um Resource, Data ou Module no Svelte Flow
type Node struct {
	ID       string   `json:"id"`
	Type     string   `json:"type"` // "resourceNode", "moduleNode"
	Position Position `json:"position"`
	Data     NodeData `json:"data"`
}

type Position struct {
	X float64 `json:"x"`
	Y float64 `json:"y"`
}

type NodeData struct {
	Label      string            `json:"label"`
	TFType     string            `json:"tfType"` // ex: "aws_instance"
	Provider   string            `json:"provider"`
	IsResolved bool              `json:"isResolved"`
	Attributes map[string]string `json:"attributes"` // Key-value dump
}

// Edge representa uma conexão dependente entre dois Nodes
type Edge struct {
	ID           string `json:"id"`
	Source       string `json:"source"`
	Target       string `json:"target"`
	Label        string `json:"label"` // ex: "depends_on" ou "implicit"
	Type         string `json:"type"`  // Svelte flow edge type (ex: "smoothstep")
	LabelBgStyle string `json:"labelBgStyle,omitempty"`
	LabelStyle   string `json:"labelStyle,omitempty"`
}
