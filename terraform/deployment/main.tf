# The module components for EKS cluster deployment

module "vpc" {
  source = "./vpc"

  # VPC Variables

  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  interface_endpoints  = var.interface_endpoints
}

module "eks" {
  source = "./eks"

  # Module Variables

  private_subnet_ids = module.vpc.private_subnet_ids

  # EKS Variables

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  node_group_name = var.node_group_name
  node_group_desired_size = var.node_group_desired_size
  node_group_max_size     = var.node_group_max_size
  node_group_min_size     = var.node_group_min_size
  admin_user_arn = var.admin_user_arn

}