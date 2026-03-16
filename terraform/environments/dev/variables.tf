variable "env" {
    description = "Name of the environment"
    type = string
}

variable "vpc_cidr" {
    description = "The CIDR block for the VPC"
    type = string
}

variable "public_subnets" {
    description = "List of CIDR blocks for the public subnets"
    type = list(string)
}

variable "private_subnets" {
    description = "List of CIDR blocks for the private subnets"
    type = list(string)
}

variable "availability_zones" {
    description = "List of AZs for the subnets"
    type = list(string)
    default = ["eu-west-2a", "eu-west-2b"]
}

variable "cluster_name" {
    description = "The name of the EKS cluster"
    type = string
}

variable "capacity_type" {
    description = "Type of capacity for the node group"
    type = string
    default = "SPOT"
}

variable "instance_types" {
    description = "Instance types for the nodes"
    type = list(string)
}

variable "scaling_config" {
    description = "Scaling configuration for the node group"
    type = object ({
        desired_size = number
        min_size = number
        max_size = number
    })
}

variable "repository_name" {
    description = "Name of ECR repository"
    type = string
}