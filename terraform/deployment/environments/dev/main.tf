# The module components for EKS cluster deployment

module "vpc" {
  source = "../../vpc"

  # VPC Variables

  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  interface_endpoints  = var.interface_endpoints
}

module "eks" {
  source = "../../eks"

  # Module Variables

  private_subnet_ids = module.vpc.private_subnet_ids
  worker_queue_arn   = module.sqs.worker_queue_arn
  worker_dlq_arn     = module.sqs.worker_dlq_arn

  # EKS Variables

  environment                      = var.environment
  cluster_name                     = var.cluster_name
  cluster_version                  = var.cluster_version
  node_group_name                  = var.node_group_name
  node_group_desired_size          = var.node_group_desired_size
  node_group_max_size              = var.node_group_max_size
  node_group_min_size              = var.node_group_min_size
  admin_user_arn                   = var.admin_user_arn
  eks_public_access_cidrs          = var.eks_public_access_cidrs
  sqs_pod_identity_role_name       = var.sqs_pod_identity_role_name
  sqs_pod_identity_policy_name     = var.sqs_pod_identity_policy_name
  sqs_pod_identity_service_account = var.sqs_pod_identity_service_account
}

module "sqs" {
  source = "../../sqs"

  # SQS Variables

  environment                = var.environment
  worker_queue_name          = var.worker_queue_name
  worker_dlq_name            = var.worker_dlq_name
  visibility_timeout_seconds = var.visibility_timeout_seconds
  max_receive_count          = var.max_receive_count
}