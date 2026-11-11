# Terraform remote state backend configuration for the dev environment

terraform {
  backend "s3" {
    key          = "dev/terraform.tfstate" 
    region       = "eu-west-2"
    encrypt      = true
    use_lockfile = true

  }
}