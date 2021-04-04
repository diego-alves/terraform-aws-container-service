output "repository_url" {
  value       = aws_ecr_repository.ecr.repository_url
  description = "This is the url of the docker repository"
}

output "name" {
  value = aws_ecs_service.service.name
  description = "The service name"
}
