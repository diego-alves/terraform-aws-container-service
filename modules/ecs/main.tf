
# ---------------------------------------------------------------------------------------------------------------------
# TASK DEFINITION
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_ecs_task_definition" "task" {
  family = var.name
  cpu    = var.cpu
  memory = var.mem

  #   task_role_arn      = data.aws_iam_role.task_role.arn
  execution_role_arn = aws_iam_role.task_execution_role.arn

  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  #   tags = merge(var.refs.common_tags, {
  #     ApplicationRole = "${var.name}-task"
  #   })

  container_definitions = jsonencode([
    {
      name      = var.name
      image     = "${aws_ecr_repository.ecr.repository_url}:latest"
      essential = true
      portMappings = [
        {
          #   protocol      = "tcp"
          containerPort = var.port
          hostPort      = var.port
        }
      ],
      "environment" : [for k, v in var.environment : { name : k, value : v }],
      "secrets" : [for k, v in var.secrets : { name : k, valueFrom : v }],
      #   "logConfiguration" : {
      #     "logDriver" : "awslogs",
      #     "options" : {
      #       "awslogs-group" : "/${var.cluster_name}/${var.name}",
      #       "awslogs-region" : var.region,
      #       "awslogs-stream-prefix" : "${var.name}-task"
      #     }
      #   }
    }
  ])
}

# ---------------------------------------------------------------------------------------------------------------------
# TASK EXECUTION ROLE
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_iam_role" "task_execution_role" {
  name                = "${var.name}TaskExecutionRole"
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"]
  assume_role_policy = jsonencode(
    {
      Version : "2012-10-17",
      Statement : [
        {
          Action : "sts:AssumeRole"
          Effect : "Allow",
          Sid : "",
          Principal : {
            Service : "ecs-tasks.amazonaws.com"
          }
        }
      ]
  })

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
