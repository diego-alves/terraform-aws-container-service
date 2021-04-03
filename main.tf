# ----------------------------------------------------------------------------------------------------------------------
# REQUIRE A SPECIFIC TERRAFORM VERSION OR HIGHER
# ----------------------------------------------------------------------------------------------------------------------

terraform {
  # This module is now only being tested with Terraform 0.14.x.
  required_version = ">= 0.14.0"
}

# ---------------------------------------------------------------------------------------------------------------------
# Data Module
# ---------------------------------------------------------------------------------------------------------------------

module "data" {
  source  = "diego-alves/data/aws"
  version = "0.0.5"
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE A DOCKER REPOSITORY
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_ecr_repository" "ecr" {
  name                 = var.name
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
  
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE A LIFECYCLE POLICY FOR THE DOCKER REPOSITORY
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_ecr_lifecycle_policy" "policy" {
  repository = aws_ecr_repository.ecr.name

  policy = jsonencode({
    rules : [{
      rulePriority : 1,
      description : "Keep only the early 5 images",
      selection : {
        tagStatus : "any",
        countType : "imageCountMoreThan",
        countNumber : 5
      },
      action : {
        type : "expire"
      }
    }]
  })
}
