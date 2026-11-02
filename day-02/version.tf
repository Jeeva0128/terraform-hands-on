terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.57"
    }
  }

  backend "s3" {
    bucket       = "terraform-state-lab-2026-random123" # Your existing backend bucket
    key          = "day04/terraform.tfstate"
    region       = "ap-south-1"
    encrypt      = true
    use_lockfile = true
  }
}