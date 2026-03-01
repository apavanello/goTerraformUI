# Modelo de Dados

Este documento mapeia o modelo de dados conceptual que será extraído do Terraform (Backend) e convertido em formatos consumíveis para renderização de Nós (Nodes) e Arestas (Edges) no Frontend (Svelte/Vue Flow).

## Diagrama de Entidade-Relacionamento (ERD)

Esse é o modelo relacional lógico.

```mermaid
erDiagram
    TF_WORKSPACE ||--o{ TF_MODULE : contains
    TF_WORKSPACE ||--o{ TF_RESOURCE : contains

    TF_MODULE {
        string id PK "Path absoluto ou Git URI"
        string name "Nome do módulo no source"
        string source "Origem (local, git, registry)"
        string version "Versão vinculada"
        boolean is_resolved "Se conseguiu baixar (para remote)"
    }
    
    TF_RESOURCE {
        string id PK "module.foo.aws_instance.web"
        string type "aws_instance, data, null_resource"
        string name "Nome identificador do resource"
        string provider "aws, google, azurerm"
    }

    TF_VARIABLE {
        string name PK
        string type "string, list, map"
        string default_value "valor fallback"
    }

    TF_OUTPUT {
        string name PK
        string value_reference "referência do valor"
    }

    TF_MODULE ||--o{ TF_RESOURCE : encapsulates
    TF_MODULE ||--o{ TF_VARIABLE : receives
    TF_MODULE ||--o{ TF_OUTPUT : exports

    %% Lógica de Grafos (Arestas)
    TF_RESOURCE }o--o{ TF_RESOURCE : depends_on (implicito/explicito)
    TF_MODULE }o--o{ TF_MODULE : calls (sub-módulos)
```

## Estrutura de Transferência (DTO) - Backend para Frontend
Para alimentar a biblioteca de Flow (Grafo), o Backend Go irá planificar essa estrutura em dois arrays JSON principais:

### 1. `nodes` (Os Blocos Visuais)
Representa qualquer entidade (Módulo, Recurso, Data Source).

```json
[
  {
    "id": "module.vpc.aws_vpc.main",
    "type": "resourceNode", 
    "data": {
      "label": "main",
      "tfType": "aws_vpc",
      "provider": "aws",
      "attributes": { "cidr_block": "10.0.0.0/16" }
    },
    "position": { "x": 0, "y": 0 } // Será calculado pelo layouting
  }
]
```

### 2. `edges` (As Linhas de Conexão)
Representa a dependência explícita (`depends_on`) ou implícita (interpolação `${aws_vpc.main.id}`).

```json
[
  {
    "id": "edge-vpc-subnet",
    "source": "module.vpc.aws_vpc.main",
    "target": "module.vpc.aws_subnet.public",
    "label": "depends_on"
  }
]
```
