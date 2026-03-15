resource "aws_iam_role" "control_plane" {
    name = "${var.env}-${var.cluster_name}-cluster-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Principal = {
                Service = "eks.amazonaws.com"
            }
        }]
    })
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.control_plane.name
}


resource "aws_iam_role" "nodes" {
    name = "${var.env}-${var.cluster_name}-nodes-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Principal = {
                Service = "ec2.amazonaws.com"
            }
        }]
    })
}

resource "aws_iam_role_policy_attachment" "node_policy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
    role       = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "nodes-AmazonEKS_CNI_Policy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
    role = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "nodes-AmazonEC2ContainerRegistryReadOnly" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
    role = aws_iam_role.nodes.name
}

resource "aws_eks_cluster" "main" {
    name = "${var.cluster_name}"
    role_arn = aws_iam_role.control_plane.arn
    
    vpc_config {
        subnet_ids = concat(var.public_subnets_ids, var.private_subnets_ids)
    }
}

data "tls_certificate" "eks" {
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

resource "aws_eks_node_group" "node_group" {
    cluster_name = aws_eks_cluster.main.name
    node_role_arn = aws_iam_role.nodes.arn
    subnet_ids = var.private_subnets_ids
    instance_types = var.instance_types
    capacity_type = var.capacity_type

    scaling_config {
        desired_size = var.scaling_config.desired_size
        max_size = var.scaling_config.max_size
        min_size = var.scaling_config.min_size
    }
}

resource "aws_iam_openid_connect_provider" "default" {
    url = aws_eks_cluster.main.identity[0].oidc[0].issuer
    client_id_list = ["sts.amazonaws.com"]
    thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
}