# S3 Bucket Creation

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "s3bucket" {
  bucket = "eks-fulfill-${data.aws_caller_identity.current.account_id}"
}

resource "aws_s3_bucket_versioning" "s3bucket" {
  bucket = aws_s3_bucket.s3bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}
resource "aws_s3_bucket_public_access_block" "s3bucket" {
  bucket = aws_s3_bucket.s3bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


# Hosted Zone Creation

resource "aws_route53_zone" "networking" {
  name = var.hosted_zone_name
}

output "ns" {
  value = aws_route53_zone.networking.name_servers
}

# Linkage Of Route53 Hosted Zone NS' to Cloudflare


data "cloudflare_zone" "domain_zone" {
  zone_id = var.domain_zone_id
}

resource "cloudflare_dns_record" "route53-ns" {
  name    = "networking"
  count   = length(aws_route53_zone.networking.name_servers)
  ttl     = 300
  type    = "NS"
  content = element(aws_route53_zone.networking.name_servers, count.index)
  zone_id = data.cloudflare_zone.domain_zone.zone_id
}