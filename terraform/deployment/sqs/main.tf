# Creating the main SQS queue for worker events

resource "aws_sqs_queue" "worker_queue" {
  name                       = "${var.environment}-${var.worker_queue_name}"
  delay_seconds              = 0
  max_message_size           = 262144 # 256 KB
  message_retention_seconds  = 345600 # 4 Days
  receive_wait_time_seconds  = 20
  visibility_timeout_seconds = var.visibility_timeout_seconds

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.worker_dlq.arn
    maxReceiveCount     = var.max_receive_count
  })
}

# Creating the Dead Letter Queue (DLQ)

resource "aws_sqs_queue" "worker_dlq" {
  name                      = "${var.environment}-${var.worker_dlq_name}"
  message_retention_seconds = 1209600 # 14 Days
}

resource "aws_sqs_queue_redrive_allow_policy" "dlq_allow_policy" {
  queue_url = aws_sqs_queue.worker_dlq.id

  redrive_allow_policy = jsonencode({
    redrivePermission = "byQueue",
    sourceQueueArns   = [aws_sqs_queue.worker_queue.arn]
  })
}