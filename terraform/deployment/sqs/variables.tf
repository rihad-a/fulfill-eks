# General Variables

variable "environment" {
  description = "The environment name (e.g., dev, staging, prod)"
  type        = string
}

# SQS Variables

variable "worker_queue_name" {
  description = "Base name for the worker event bus"
  type        = string
}

variable "worker_dlq_name" {
  description = "Base name for the worker dead letter queue"
  type        = string
}

variable "visibility_timeout_seconds" {
  description = "How long a message is hidden from other workers while being processed"
  type        = number
}

variable "max_receive_count" {
  description = "Number of times a message can fail before moving to the DLQ"
  type        = number
}