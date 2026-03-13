output "vpc_id" {
    description = "The ID of the VPC"
    value = aws_vpc.main.id
}

output "public_subnets_ids" {
    description = "The ID of the public subnets"
    value = aws_subnet.public[*].id
}

output "private_subnets_ids" {
    description = "The ID of the private subnets"
    value = aws_subnet.private[*].id
}