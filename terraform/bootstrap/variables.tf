# General Variables

variable "aws_tags" {
  description = "Tags for Resources"
  type        = map(string)
}

# Bootstrap Variables

variable "hosted_zone_name" {
  type        = string
  description = "The name of the hosted zone to create"
}

variable "domain_zone_id" {
  type        = string
  description = "The ID of the Cloudflare zone to link to"
}