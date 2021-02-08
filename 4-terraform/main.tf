terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.26.0"
    }
  }
  # backend "s3" {
  #   profile = "default"
  #   bucket  = "ramp-up-devops-psl"
  #   key     = "jose.posadam/terraform_state_perf/terraform.tfstate"
  #   region  = "us-west-1"
  #   encrypt = true
  # }
}

provider "aws" {
  region  = var.region
  profile = "default"
}


