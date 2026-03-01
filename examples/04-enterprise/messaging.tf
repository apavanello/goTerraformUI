# =============================================================================
# Messaging: SNS, SQS, Lambda, EventBridge
# =============================================================================

# --- SNS ---
resource "aws_sns_topic" "alerts" {
  name              = "${var.project}-alerts"
  kms_master_key_id = aws_kms_key.main.id
  tags              = local.common_tags
}

resource "aws_sns_topic_subscription" "email_alert" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = "ops@empresa.com.br"
}

# --- SQS ---
resource "aws_sqs_queue" "events_dlq" {
  name                      = "${var.project}-events-dlq"
  message_retention_seconds = 1209600
  kms_master_key_id         = aws_kms_key.main.id
  tags                      = merge(local.common_tags, { Purpose = "dead-letter" })
}

resource "aws_sqs_queue" "events" {
  name                       = "${var.project}-events"
  visibility_timeout_seconds = 120
  kms_master_key_id          = aws_kms_key.main.id
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.events_dlq.arn
    maxReceiveCount     = 3
  })
  tags = local.common_tags
}

# --- Lambda ---
resource "aws_lambda_function" "event_processor" {
  function_name = "${var.project}-event-processor"
  runtime       = "provided.al2023"
  handler       = "bootstrap"
  role          = aws_iam_role.lambda_processor.arn
  filename      = "placeholder.zip"
  memory_size   = 512
  timeout       = 60
  environment {
    variables = {
      TABLE_NAME  = aws_dynamodb_table.sessions.name
      BUCKET_NAME = aws_s3_bucket.assets.bucket
      QUEUE_URL   = aws_sqs_queue.events.id
    }
  }
  vpc_config {
    subnet_ids         = [aws_subnet.private_a.id, aws_subnet.private_b.id]
    security_group_ids = [aws_security_group.app.id]
  }
  tags = local.common_tags
}

resource "aws_lambda_event_source_mapping" "sqs_trigger" {
  event_source_arn = aws_sqs_queue.events.arn
  function_name    = aws_lambda_function.event_processor.arn
  batch_size       = 10
}

# --- CloudWatch Alarms ---
resource "aws_cloudwatch_metric_alarm" "rds_cpu" {
  alarm_name          = "${var.project}-rds-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_actions       = [aws_sns_topic.alerts.arn]
  dimensions = {
    DBClusterIdentifier = aws_rds_cluster.aurora.cluster_identifier
  }
  tags = local.common_tags
}

resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_name          = "${var.project}-lambda-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 300
  statistic           = "Sum"
  threshold           = 5
  alarm_actions       = [aws_sns_topic.alerts.arn]
  dimensions = {
    FunctionName = aws_lambda_function.event_processor.function_name
  }
  tags = local.common_tags
}
