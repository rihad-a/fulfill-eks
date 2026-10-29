terraform {
    required_providers{
        aws = {
            source = "hashicorp/aws"
            version = "6.71.0"
        }

        cloudflare = {
            source = "cloudflare/cloudflare"
            version = "5.28.1"
        }
    }
}

provider "aws" {
    region = "eu-west-2"
    default_tags {
        tags = var.aws_tags
    }
}

provider "cloudflare" {
}