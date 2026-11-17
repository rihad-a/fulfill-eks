# General Variables

variable "environment" {
  description = "The environment name (e.g., dev, staging, prod)"
  type        = string
}

# Secrets Manager Variables

variable "postgres_secret_name" {
  description = "The name of the PostgreSQL secret"
  type        = string
}