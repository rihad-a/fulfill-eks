# Creating a VPC

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
}

# Creating public and private subnets

resource "aws_subnet" "public" {
  for_each = var.public_subnet_cidrs

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value
  availability_zone       = each.key
  map_public_ip_on_launch = true

  tags = {
    Name                     = "fulfill-eks-public-subnet-${each.key}"
    "kubernetes.io/role/elb" = 1
  }
}

resource "aws_subnet" "private" {
  for_each = var.private_subnet_cidrs

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
  availability_zone = each.key

  tags = {
    Name                              = "fulfill-eks-private-subnet-${each.key}"
    "kubernetes.io/role/internal-elb" = 1,
    "karpenter.sh/discovery"          = "fulfill-eks"
  }
}

# Creating an Internet Gateway and a NAT Gateway

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "naat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = values(aws_subnet.public)[0].id


  depends_on = [aws_internet_gateway.igw]
}

# Creating Route Tables and Associations

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.naat.id
  }
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}

# Creating VPC Endpoints

resource "aws_security_group" "vpc_endpoint" {
  name        = "vpc_endpoint_interface_sg"
  description = "Allow 443 inbound from the VPC cidr for the VPC interface endpoints"
  vpc_id      = aws_vpc.main.id
}

resource "aws_vpc_security_group_ingress_rule" "vpc_endpoint_ingress" {
  security_group_id = aws_security_group.vpc_endpoint.id
  cidr_ipv4         = aws_vpc.main.cidr_block
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

data "aws_region" "current" {}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [aws_route_table.public.id, aws_route_table.private.id]
}

resource "aws_vpc_endpoint" "interfaces" {
  for_each = var.interface_endpoints

  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.${each.value}"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = values(aws_subnet.private)[*].id
  private_dns_enabled = true

  security_group_ids = [
    aws_security_group.vpc_endpoint.id,
  ]

  tags = {
    Name = "fulfill-eks-vpc-endpoint-${each.key}"
  }
}