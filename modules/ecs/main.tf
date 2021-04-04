# ---------------------------------------------------------------------------------------------------------------------
# ECS SERVICE
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_ecs_service" "service" {
  name                    = var.name
  cluster                 = data.aws_ecs_cluster.selected.id
  task_definition         = aws_ecs_task_definition.task.arn
  desired_count           = 2
  launch_type             = "FARGATE"
  force_new_deployment    = true
  enable_ecs_managed_tags = true
  propagate_tags          = "SERVICE"

  network_configuration {
    subnets          = var.subnets
    security_groups  = [aws_security_group.secgroup.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.target_group
    container_name   = var.name
    container_port   = var.port
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# TASK DEFINITION
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_ecs_task_definition" "task" {
  family = var.name
  cpu    = var.cpu
  memory = var.mem

  task_role_arn = var.task_role
  execution_role_arn = aws_iam_role.task_execution_role.arn

  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  container_definitions = jsonencode([
    {
      name      = var.name
      image     = "${aws_ecr_repository.ecr.repository_url}:latest"
      essential = true
      portMappings = [{
        containerPort = var.port
        hostPort      = var.port
      }]
      environment = [for k, v in var.environment : { name : k, value : v }]
      secrets     = [for k, v in var.secrets : { name : k, valueFrom : v }]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-region        = "us-east-1"
          awslogs-group         = aws_cloudwatch_log_group.cw_lg.name
          awslogs-stream-prefix = "${var.name}-task"
        }
      }
    }
  ])
}

# ---------------------------------------------------------------------------------------------------------------------
# CLOUDWATCH LOG GROUP
# ---------------------------------------------------------------------------------------------------------------------

resource aws_cloudwatch_log_group cw_lg {
  name = "/${var.cluster_name}/${var.name}"
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

# ---------------------------------------------------------------------------------------------------------------------
# SECURITY GROUP
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_security_group" "secgroup" {
  name   = "${var.name}-ecs-sg"
  vpc_id = var.vpc_id
  ingress {
    from_port   = var.port
    to_port     = var.port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Data
# ---------------------------------------------------------------------------------------------------------------------

data "aws_ecs_cluster" "selected" {
  cluster_name = var.cluster_name
}

