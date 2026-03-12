variable "vpc_cidr" {
    description = "The CIDR block for the VPC"
    type = string
}

variable "env" {
    description = "Name of the environment"
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
    default = ["eu-west-2a", "eu-west-2b]
}