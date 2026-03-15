variable "env" {
    description = "Name of the environment"
    type = string
}

variable "cluster_name" {
    description = "The name of the EKS cluster"
    type = string
}

variable "vpc_id" {
    description = "The ID of the VPC"
    type = string
}

variable "public_subnets_ids" {
    description = "The ID of the public subnets"
    type = list(string)
}

variable "private_subnets_ids" {
    description = "The ID of the private subnets"
    type = list(string)
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
