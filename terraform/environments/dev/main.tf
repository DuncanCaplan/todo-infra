module "vpc" {
    source = "../../modules/vpc"
    vpc_cidr = var.vpc_cidr
    env = var.env
    public_subnets = var.public_subnets
    private_subnets = var.private_subnets
    availability_zones = var.availability_zones
}

module "eks" {
    source = "../../modules/eks"
    env = var.env
    cluster_name = var.cluster_name
    vpc_id = module.vpc.vpc_id
    public_subnets_ids = module.vpc.public_subnets_ids
    private_subnets_ids = module.vpc.private_subnets_ids
    capacity_type = var.capacity_type
    instance_types = var.instance_types
    scaling_config = var.scaling_config
}