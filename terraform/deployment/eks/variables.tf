# General Variables

variable "environment" {
  description = "The environment name (e.g., dev, staging, prod)"
  type        = string
}

# EKS Variables

variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "The Kubernetes version for the EKS cluster"
  type        = string
}

variable "node_group_name" {
  description = "The name of the EKS node group"
  type        = string
}

variable "node_group_desired_size" {
  description = "Desired number of worker nodes"
  type        = number
}

variable "node_group_max_size" {
  description = "Maximum number of worker nodes"
  type        = number
}

variable "node_group_min_size" {
  description = "Minimum number of worker nodes"
  type        = number
}

variable "admin_user_arn" {
  description = "The ARN to grant the admin user CLI access to the EKS cluster"
  type        = string
}

variable "eks_public_access_cidrs" {
  description = "List of CIDR blocks that can access the Amazon EKS public API server endpoint"
  type        = list(string)
}

variable "sqs_pod_identity_role_name" {
  description = "The name of the IAM role for the SQS pod identity association"
  type        = string
}

variable "sqs_pod_identity_policy_name" {
  description = "The name of the IAM policy for the SQS pod identity association"
  type        = string
}

variable "sqs_pod_identity_service_account" {
  description = "The service account for the SQS pod identity association"
  type        = string
}


# Module Variables

variable "private_subnet_ids" {
  description = "List of private subnet IDs from the VPC module"
  type        = list(string)
}

variable "worker_queue_arn" {
  description = "The ARN of the SQS worker queue"
  type        = string
}

variable "worker_dlq_arn" {
  description = "The ARN of the SQS dead letter queue"
  type        = string
}