# =============================================================================
# Security Groups, KMS, WAF
# =============================================================================

resource "aws_security_group" "alb" {
  name_prefix = "${var.project}-alb-"
  vpc_id      = aws_vpc.main.id
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(local.common_tags, { Name = "${var.project}-sg-alb" })
}

resource "aws_security_group" "app" {
  name_prefix = "${var.project}-app-"
  vpc_id      = aws_vpc.main.id
  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(local.common_tags, { Name = "${var.project}-sg-app" })
}

resource "aws_security_group" "rds" {
  name_prefix = "${var.project}-rds-"
  vpc_id      = aws_vpc.main.id
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }
  tags = merge(local.common_tags, { Name = "${var.project}-sg-rds" })
}

resource "aws_security_group" "redis" {
  name_prefix = "${var.project}-redis-"
  vpc_id      = aws_vpc.main.id
  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }
  tags = merge(local.common_tags, { Name = "${var.project}-sg-redis" })
}

resource "aws_security_group" "vpc_endpoints" {
  name_prefix = "${var.project}-vpce-"
  vpc_id      = aws_vpc.main.id
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }
  tags = merge(local.common_tags, { Name = "${var.project}-sg-vpce" })
}

# --- KMS ---
resource "aws_kms_key" "main" {
  description             = "Chave mestra do ${var.project}"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  tags                    = local.common_tags
}

resource "aws_kms_alias" "main" {
  name          = "alias/${var.project}"
  target_key_id = aws_kms_key.main.id
}

# --- WAF ---
resource "aws_wafv2_web_acl" "main" {
  name        = "${var.project}-waf"
  scope       = "REGIONAL"
  default_action { allow {} }
  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.project}-waf-metric"
    sampled_requests_enabled   = true
  }
  rule {
    name     = "block-bad-bots"
    priority = 1
    action { block {} }
    statement {
      byte_match_statement {
        search_string         = "BadBot"
        positional_constraint = "CONTAINS"
        field_to_match { single_header { name = "user-agent" } }
        text_transformation { priority = 0; type = "LOWERCASE" }
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "block-bad-bots"
      sampled_requests_enabled   = true
    }
  }
  tags = local.common_tags
}
