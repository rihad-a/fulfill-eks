# Outputs to be used by other modules

output "worker_queue_arn" {
  value = aws_sqs_queue.worker_queue.arn
}

output "worker_dlq_arn" {
  value = aws_sqs_queue.worker_dlq.arn
}