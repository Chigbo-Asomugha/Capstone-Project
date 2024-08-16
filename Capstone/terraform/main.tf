# 1 - Creating a VPC.

provider "aws"{
    region = "us-east-1"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "gbochi-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.3.0/24", "10.0.4.0/24"]

  enable_nat_gateway = true
  
  single_nat_gateway = true
  enable_dns_hostnames = true

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

# 2 - Creating an EKS Cluster.

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "sockshop"
  cluster_version = "1.30"

  cluster_endpoint_public_access  = true

  

  vpc_id                   = module.vpc.vpc_id 
  subnet_ids               = module.vpc.private_subnets
  

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    #instance_types = ["m6i.large", "m5.large", "m5n.large", "m5zn.large"]
    ami_type = "AL2_x86_64"
  }

  eks_managed_node_groups = {
   
    Node1 = {
    
      name = "node-group1"
      instance_types = ["t2.medium"]

      min_size     = 1 
      max_size     = 2
      desired_size = 2
    }


     Node2 = {

        name = "node-group2"
        instance_types = ["t2.medium"]

      min_size     = 1 
      max_size     = 2
      desired_size = 2
    }
 
  }



  # Cluster access entry
  # To add the current caller identity as an administrator
  enable_cluster_creator_admin_permissions = true

  
        
}