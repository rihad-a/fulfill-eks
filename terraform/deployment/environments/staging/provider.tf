terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.71.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "aws" {
  region = "eu-west-2"
  default_tags {
      tags = merge(
        var.aws_tags,
        {
          Environment = var.environment
        }
      )
    }
}
