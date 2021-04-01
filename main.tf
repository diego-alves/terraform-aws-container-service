# ----------------------------------------------------------------------------------------------------------------------
# REQUIRE A SPECIFIC TERRAFORM VERSION OR HIGHER
# ----------------------------------------------------------------------------------------------------------------------

terraform {
  # This module is now only being tested with Terraform 0.13.x. However, to make upgrading easier, we are setting
  # 0.12.26 as the minimum version, as that version added support for required_providers with source URLs, making it
  # forwards compatible with 0.13.x code.
  required_version = ">= 0.12.26"
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE A DOCKER REPOSITORY
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_ecr_repository" "ecr" {
  name                 = var.name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(var.refs.common_tags, {
    ApplicationRole = "${var.name}-ecr"
  })
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE A LIFECYCLE POLICY FOR THE DOCKER REPOSITORY
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_ecr_lifecycle_policy" "policy" {
  repository = aws_ecr_repository.ecr.name

  policy = jsonencode({
    rules : [{
      rulePriority : 1,
      description : "Expire images older than 14 days",
      selection : {
        tagStatus : "untagged",
        countType : "sinceImagePushed",
        countUnit : "days",
        countNumber : 14
      },
      action : {
        type : "expire"
      }
    }]
  })
}
