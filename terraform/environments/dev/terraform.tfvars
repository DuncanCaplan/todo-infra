vpc_cidr = "10.0.0.0/16"

env = "dev"

public_subnets = ["10.0.1.0/24", "10.0.2.0/24"]

private_subnets = ["10.0.11.0/24", "10.0.12.0/24"]

availability_zones = ["eu-west-2a", "eu-west-2b"]

cluster_name = "todo-cluster"

capacity_type = "SPOT"

instance_types = ["t3.medium", "t3a.medium"]

scaling_config = {
    desired_size = 1
    min_size = 1
    max_size = 2
}