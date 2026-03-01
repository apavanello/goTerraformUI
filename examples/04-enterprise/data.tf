# =============================================================================
# Dados: RDS PostgreSQL, ElastiCache Redis, S3, DynamoDB
# =============================================================================

# --- RDS ---
resource "aws_db_subnet_group" "main" {
  name       = "${var.project}-db-subnets"
  subnet_ids = [aws_subnet.db_a.id, aws_subnet.db_b.id]
  tags       = local.common_tags
}

resource "aws_rds_cluster" "aurora" {
  cluster_identifier      = "${var.project}-aurora"
  engine                  = "aurora-postgresql"
  engine_version          = "15.4"
  database_name           = "appdb"
  master_username         = "dbadmin"
  master_password         = "CHANGE_ME_USE_SECRETS_MANAGER"
  db_subnet_group_name    = aws_db_subnet_group.main.name
  vpc_security_group_ids  = [aws_security_group.rds.id]
  storage_encrypted       = true
  kms_key_id              = aws_kms_key.main.arn
  backup_retention_period = 7
  skip_final_snapshot     = true
  tags                    = local.common_tags
}

resource "aws_rds_cluster_instance" "aurora_writer" {
  identifier         = "${var.project}-aurora-writer"
  cluster_identifier = aws_rds_cluster.aurora.id
  instance_class     = "db.r6g.large"
  engine             = aws_rds_cluster.aurora.engine
  engine_version     = aws_rds_cluster.aurora.engine_version
  tags               = merge(local.common_tags, { Role = "writer" })
}

resource "aws_rds_cluster_instance" "aurora_reader" {
  identifier         = "${var.project}-aurora-reader"
  cluster_identifier = aws_rds_cluster.aurora.id
  instance_class     = "db.r6g.large"
  engine             = aws_rds_cluster.aurora.engine
  engine_version     = aws_rds_cluster.aurora.engine_version
  tags               = merge(local.common_tags, { Role = "reader" })
}

# --- ElastiCache Redis ---
resource "aws_elasticache_subnet_group" "redis" {
  name       = "${var.project}-redis-subnets"
  subnet_ids = [aws_subnet.private_a.id, aws_subnet.private_b.id]
}

resource "aws_elasticache_replication_group" "redis" {
  replication_group_id = "${var.project}-redis"
  description          = "Redis cluster para cache e sessões"
  node_type            = "cache.r6g.large"
  num_cache_clusters   = 2
  engine_version       = "7.0"
  port                 = 6379
  subnet_group_name    = aws_elasticache_subnet_group.redis.name
  security_group_ids   = [aws_security_group.redis.id]
  at_rest_encryption_enabled = true
  transit_encryption_enabled = true
  tags                 = local.common_tags
}

# --- S3 Buckets ---
resource "aws_s3_bucket" "assets" {
  bucket = "${var.project}-assets-${var.environment}"
  tags   = merge(local.common_tags, { Purpose = "static-assets" })
}

resource "aws_s3_bucket_versioning" "assets" {
  bucket = aws_s3_bucket.assets.id
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "assets" {
  bucket = aws_s3_bucket.assets.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.main.arn
    }
  }
}

resource "aws_s3_bucket" "logs" {
  bucket = "${var.project}-logs-${var.environment}"
  tags   = merge(local.common_tags, { Purpose = "centralized-logs" })
}

resource "aws_s3_bucket" "backups" {
  bucket = "${var.project}-backups-${var.environment}"
  tags   = merge(local.common_tags, { Purpose = "database-backups" })
}

# --- DynamoDB ---
resource "aws_dynamodb_table" "locks" {
  name         = "${var.project}-distributed-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
  point_in_time_recovery { enabled = true }
  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.main.arn
  }
  tags = local.common_tags
}

resource "aws_dynamodb_table" "sessions" {
  name         = "${var.project}-sessions"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "SessionID"
  attribute {
    name = "SessionID"
    type = "S"
  }
  ttl {
    attribute_name = "ExpiresAt"
    enabled        = true
  }
  tags = local.common_tags
}
