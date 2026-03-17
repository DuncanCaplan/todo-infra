# todo-infra

Infrastructure, Helm charts, and Terraform modules for the [GitOps Todo API](https://github.com/DuncanCaplan/todo-app) project.

This repo manages the AWS infrastructure and Kubernetes deployment configuration for a microservices todo application. The application is deliberately simple — the infrastructure and pipeline are the showcase.

## Architecture

```
Internet
    │
    ▼
Internet Gateway
    │
    ▼
┌─────────────────────────────────────────────────┐
│  VPC (10.0.0.0/16)                              │
│                                                  │
│  Public Subnets (eu-west-2a, eu-west-2b)        │
│  ├── Load Balancer (NGINX Ingress)              │
│  └── NAT Gateway                                │
│                                                  │
│  Private Subnets (eu-west-2a, eu-west-2b)       │
│  └── EKS Worker Nodes                           │
│      ├── Todo API (FastAPI)                     │
│      └── PostgreSQL (Bitnami)                   │
└─────────────────────────────────────────────────┘
```

## Repo Structure

```
todo-infra/
├── .github/workflows/
│   ├── terraform-plan.yaml      # Runs on PRs — tfsec scan + terraform plan
│   ├── terraform-apply.yaml     # Manual trigger — terraform apply
│   └── terraform-destroy.yaml   # Manual trigger — terraform destroy
├── helm/
│   ├── todo-api/                # Helm chart for the Todo API
│   │   ├── Chart.yaml
│   │   ├── values.yaml
│   │   └── templates/
│   │       ├── deployment.yaml
│   │       ├── service.yaml
│   │       └── ingress.yaml
│   └── todo-db/
│       └── values.yaml          # Bitnami PostgreSQL overrides
├── terraform/
│   ├── modules/
│   │   ├── vpc/                 # VPC, subnets, gateways, route tables
│   │   ├── eks/                 # EKS cluster, node group, IAM roles, OIDC
│   │   └── ecr/                 # ECR repository with lifecycle policies
│   └── environments/
│       └── dev/
│           ├── backend.tf       # S3 remote state config
│           ├── providers.tf     # AWS provider (eu-west-2)
│           ├── main.tf          # Calls all modules
│           ├── variables.tf     # Variable declarations
│           └── terraform.tfvars # Dev environment values
└── cluster/
    └── cluster-config.yaml      # Legacy eksctl config (replaced by Terraform)
```

## Terraform Modules

### VPC

Creates the networking foundation: a VPC with public and private subnets across two availability zones, an internet gateway, a NAT gateway with an Elastic IP, and route tables wiring it all together. Public subnets host the load balancer, private subnets host the EKS worker nodes.

### EKS

Creates the Kubernetes cluster: an EKS control plane, a managed node group (spot instances by default), IAM roles for both the cluster and nodes, and an OIDC provider for IAM Roles for Service Accounts (IRSA).

### ECR

Creates a container image repository with immutable tags, scan-on-push enabled, and lifecycle policies to automatically clean up old images.

## Dev Environment Configuration

| Setting | Value |
|---------|-------|
| Region | eu-west-2 |
| VPC CIDR | 10.0.0.0/16 |
| Public subnets | 10.0.1.0/24, 10.0.2.0/24 |
| Private subnets | 10.0.11.0/24, 10.0.12.0/24 |
| AZs | eu-west-2a, eu-west-2b |
| Cluster name | todo-cluster |
| Node instances | t3.medium, t3a.medium (spot) |
| Node scaling | min 1, max 2, desired 1 |

## CI/CD Workflows

**terraform-plan** runs automatically on pull requests. It scans the Terraform code with tfsec for security misconfigurations, then runs `terraform plan` to show what would change.

**terraform-apply** and **terraform-destroy** are manual triggers (`workflow_dispatch`). This prevents accidental infrastructure creation or destruction — the EKS cluster costs approximately $0.25/hr when running.

## Getting Started

### Prerequisites

- AWS CLI configured with credentials
- Terraform installed
- kubectl installed
- Helm installed

### Create the S3 state bucket (one-time setup)

```bash
aws s3api create-bucket \
  --bucket todo-tfstate-060476966476 \
  --region eu-west-2 \
  --create-bucket-configuration LocationConstraint=eu-west-2

aws s3api put-bucket-versioning \
  --bucket todo-tfstate-060476966476 \
  --versioning-configuration Status=Enabled
```

### Deploy infrastructure

Trigger the **Terraform-apply** workflow from the GitHub Actions tab, or run locally:

```bash
cd terraform/environments/dev
terraform init
terraform plan
terraform apply
```

### Deploy the application stack

After the infrastructure is up:

```bash
# Configure kubectl
aws eks update-kubeconfig --name todo-cluster --region eu-west-2

# Install PostgreSQL
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install todo-db bitnami/postgresql -f helm/todo-db/values.yaml

# Install NGINX Ingress Controller
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm install todo-ingress ingress-nginx/ingress-nginx

# Install Todo API
helm install todo-api ./helm/todo-api
```

### Tear down

Trigger the **Terraform-destroy** workflow from the GitHub Actions tab, or run locally:

```bash
cd terraform/environments/dev
terraform destroy
```

## Cost Management

EKS is not cheap to leave running. The cluster costs approximately $6/day with spot nodes. Always destroy the infrastructure when not actively working. The manual `workflow_dispatch` triggers on apply and destroy are designed to prevent accidental costs.

## Related

- [todo-app](https://github.com/DuncanCaplan/todo-app) — Application source code, Dockerfile, and CI pipeline
