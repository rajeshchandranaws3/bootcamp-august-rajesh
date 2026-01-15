module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.5.0"

  name               = "eks-cluster-tf"
  kubernetes_version = "1.29"

  addons = {
    coredns    = {}
    kube-proxy = {}
    vpc-cni = {
      before_compute = true
    }
  }

  # Enable public access to the EKS cluster endpoint
  endpoint_public_access = true

  # Optional: Adds the current caller identity as an administrator via cluster access entry
  enable_cluster_creator_admin_permissions = true
  
  # vpc configuration
  vpc_id             = module.vpc.vpc_id
  control_plane_subnet_ids = module.vpc.private_subnets

  # Private Subnets for the EKS cluster
  subnet_ids = module.vpc.private_subnets


  # EKS Managed Node Group(s)
  eks_managed_node_groups = {
    example = {
      # ami_type       = "AL2023_x86_64_STANDARD"
      ami_type       = "AL2_x86_64"
      instance_types = ["t3.medium"]

      min_size     = 1
      max_size     = 3
      desired_size = 2
    }
  }

  tags = {
    Terraform = "true"
    repo      = "bootcamp-aug-rajesh"
  }
}