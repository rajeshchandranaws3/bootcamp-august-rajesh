terraform {
  required_version = "1.5.7"
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

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      repo         = "bootcamp-august-rajesh"
      organization = "livingdevops"
      team         = "august bootcamp"
      Terraform    = "true"
    }
  }
}
