# Terraform remote state backend configuration for the staging environment

terraform {
  backend "s3" {
    key          = "staging/terraform.tfstate" 
    region       = "eu-west-2"
    encrypt      = true
    use_lockfile = true

  }
}