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
