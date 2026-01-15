provider "aws" {
  region = "us-east-1"
  # assume_role {
  #   role_arn    = "arn:aws:iam::01234567890:role/role_in_account_b"
  # }
  default_tags {
    tags = {
      class = "aws-eks-tf"
    }
  }
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint #Output from eks module, provided in eks.tf 
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  # token                  = data.aws_eks_cluster_auth.cluster.token #Data source defined in data.tf
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}

# Configure Helm Provider
provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args = [
        "eks",
        "get-token",
        "--cluster-name",
        module.eks.cluster_name,
        "--region",
        "us-east-1"
      ]
    }
  }
}


