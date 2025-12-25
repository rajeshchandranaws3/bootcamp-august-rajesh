terraform {
  required_version = ">= 1.8.1"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0.0" # >= 6.0.0 and < 7.0.0
    }

    random = {
      source  = "hashicorp/random"
      version = ">= 3.0.0" # >= 3.0.0 and < 4.0.0
    }
  }
}


terraform {
  backend "s3" {
    bucket  = "state-bucket-307946636515"
    key     = "class27/oidc/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project = "august-bootcamp"
      class   = "21december"
      repo    = "bootcamp-august-rajesh/class27"
    }
  }
}