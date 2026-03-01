# =============================================================================
# Exemplo Enterprise: Plataforma Completa na AWS
# ~55 recursos distribuídos entre: VPC, Subnets, EKS, RDS, ElastiCache,
# S3, CloudFront, ALB, WAF, Route53, ACM, SNS, SQS, Lambda, IAM, KMS, etc.
# =============================================================================

terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
  }
  backend "s3" {
    bucket = "tf-state-enterprise"
    key    = "infra/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.region
}

# ---------- Variáveis ----------
variable "region"      { default = "us-east-1" }
variable "environment" { default = "production" }
variable "project"     { default = "enterprise-app" }
variable "domain_name" { default = "app.empresa.com.br" }

locals {
  common_tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}
