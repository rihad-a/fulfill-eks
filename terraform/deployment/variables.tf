# General Variables

variable "aws_tags" {
  description = "Tags for Resources"
  type        = map(string)
}

# VPC Variables

variable "public_subnet_cidrs" {
  type        = map(string)
  description = "The CIDR block for the public subnets"
}

variable "private_subnet_cidrs" {
  type        = map(string)
  description = "The CIDR block for the private subnets"
}

variable "interface_endpoints" {
  type        = map(string)
  description = "The values for the different interface endpoints to be created"
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

