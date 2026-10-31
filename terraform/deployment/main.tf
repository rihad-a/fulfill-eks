# The module components for EKS cluster deployment

module "vpc" {
  source = "./vpc"

  # VPC Variables

  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  interface_endpoints  = var.interface_endpoints
}