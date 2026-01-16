terraform {
  required_version = ">= 1.5.7" # 1.12.1
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
  }
  kubernetes = {
    source  = "hashicorp/kubernetes"
    version = "3.0.1"
  }
}
}

terraform {
  backend "s3" {
    bucket  = "state-bucket-307946636515"
    key     = "class31/k8s-app-infra/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
    # assume_role = {
    #   role_arn    = "arn:aws:iam::01234567890:role/role_in_account_b"
    # }
  }
}

