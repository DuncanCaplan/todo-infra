resource "aws_ecr_repository" "ecr_repo" {
    name = var.repository_name
    image_tag_mutability = "IMMUTABLE"
    force_delete = true

    image_scanning_configuration {
        scan_on_push = true
    }
}

resource "aws_ecr_lifecycle_policy" "main" {
    repository = aws_ecr_repository.ecr_repo.name
    policy = jsonencode({
        rules = [{
            rulePriority = 1
            description = "Keep last 5 tagged images"
            selection = {
                tagStatus = "tagged"
                countType = "imageCountMoreThan"
                countNumber = 5
            }
            action = {
                type = "expire"
            }
        },
        {
            rulePriority = 2
            description = "Keep the last 3 untagged images"
            selection = {
                tagStatus = "untagged"
                countType = "imageCountMoreThan"
                countNumber = 3
            }
            action = {
                type = "expire"
            }
        }]
    })
}