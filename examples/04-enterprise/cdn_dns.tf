# =============================================================================
# CDN & DNS: CloudFront, Route53
# =============================================================================

# --- CloudFront ---
resource "aws_cloudfront_distribution" "cdn" {
  enabled             = true
  default_root_object = "index.html"
  aliases             = [var.domain_name]
  web_acl_id          = aws_wafv2_web_acl.main.arn

  origin {
    domain_name = aws_lb.main.dns_name
    origin_id   = "alb"
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  origin {
    domain_name = aws_s3_bucket.assets.bucket_regional_domain_name
    origin_id   = "s3-assets"
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.assets.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "alb"
    viewer_protocol_policy = "redirect-to-https"
    forwarded_values {
      query_string = true
      cookies { forward = "all" }
    }
  }

  ordered_cache_behavior {
    path_pattern           = "/static/*"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "s3-assets"
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 86400
    default_ttl            = 604800
    max_ttl                = 2592000
    forwarded_values {
      query_string = false
      cookies { forward = "none" }
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.main.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  restrictions {
    geo_restriction { restriction_type = "none" }
  }

  tags = merge(local.common_tags, { Name = "${var.project}-cdn" })
}

resource "aws_cloudfront_origin_access_identity" "assets" {
  comment = "OAI for ${var.project} S3 assets"
}

# --- Route 53 ---
resource "aws_route53_zone" "main" {
  name = var.domain_name
  tags = local.common_tags
}

resource "aws_route53_record" "app" {
  zone_id = aws_route53_zone.main.zone_id
  name    = var.domain_name
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.cdn.domain_name
    zone_id                = aws_cloudfront_distribution.cdn.hosted_zone_id
    evaluate_target_health = false
  }
}

# =============================================================================
# Outputs
# =============================================================================
output "vpc_id"             { value = aws_vpc.main.id }
output "eks_cluster_name"   { value = aws_eks_cluster.main.name }
output "alb_dns"            { value = aws_lb.main.dns_name }
output "aurora_endpoint"    { value = aws_rds_cluster.aurora.endpoint }
output "redis_endpoint"     { value = aws_elasticache_replication_group.redis.primary_endpoint_address }
output "cloudfront_domain"  { value = aws_cloudfront_distribution.cdn.domain_name }
output "app_url"            { value = "https://${var.domain_name}" }
