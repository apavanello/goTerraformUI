# =============================================================================
# Compute: EKS Cluster, Node Groups, ALB, Target Group, ACM
# =============================================================================

# --- ACM Certificate ---
resource "aws_acm_certificate" "main" {
  domain_name       = var.domain_name
  validation_method = "DNS"
  tags              = local.common_tags
  lifecycle { create_before_destroy = true }
}

# --- ALB ---
resource "aws_lb" "main" {
  name               = "${var.project}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [aws_subnet.public_a.id, aws_subnet.public_b.id, aws_subnet.public_c.id]
  tags               = merge(local.common_tags, { Name = "${var.project}-alb" })
}

resource "aws_lb_target_group" "app" {
  name        = "${var.project}-tg"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"
  health_check {
    path                = "/healthz"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    interval            = 15
  }
  tags = local.common_tags
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.main.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = aws_acm_certificate.main.arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

resource "aws_lb_listener" "http_redirect" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# --- WAF Association ---
resource "aws_wafv2_web_acl_association" "alb" {
  resource_arn = aws_lb.main.arn
  web_acl_arn  = aws_wafv2_web_acl.main.arn
}

# --- EKS ---
resource "aws_eks_cluster" "main" {
  name     = "${var.project}-eks"
  role_arn = aws_iam_role.eks_cluster.arn
  version  = "1.30"
  vpc_config {
    subnet_ids              = [aws_subnet.private_a.id, aws_subnet.private_b.id, aws_subnet.private_c.id]
    endpoint_private_access = true
    endpoint_public_access  = true
    security_group_ids      = [aws_security_group.app.id]
  }
  encryption_config {
    provider { key_arn = aws_kms_key.main.arn }
    resources = ["secrets"]
  }
  tags = local.common_tags
}

resource "aws_eks_node_group" "general" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.project}-general"
  node_role_arn   = aws_iam_role.eks_nodes.arn
  subnet_ids      = [aws_subnet.private_a.id, aws_subnet.private_b.id]
  instance_types  = ["m6i.xlarge"]
  scaling_config {
    desired_size = 3
    max_size     = 10
    min_size     = 2
  }
  tags = merge(local.common_tags, { NodeGroup = "general" })
}

resource "aws_eks_node_group" "spot" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.project}-spot"
  node_role_arn   = aws_iam_role.eks_nodes.arn
  subnet_ids      = [aws_subnet.private_a.id, aws_subnet.private_b.id]
  capacity_type   = "SPOT"
  instance_types  = ["m6i.xlarge", "m5.xlarge", "c6i.xlarge"]
  scaling_config {
    desired_size = 2
    max_size     = 20
    min_size     = 0
  }
  tags = merge(local.common_tags, { NodeGroup = "spot" })
}

resource "aws_eks_addon" "vpc_cni" {
  cluster_name = aws_eks_cluster.main.name
  addon_name   = "vpc-cni"
}

resource "aws_eks_addon" "coredns" {
  cluster_name = aws_eks_cluster.main.name
  addon_name   = "coredns"
}
