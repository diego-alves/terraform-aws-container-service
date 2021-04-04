output "repository_url" {
  value = module.container_service.repository_url
}

output "default_target_group" {
  value = module.container_service.default_target_group
}

output "target_groups" {
  value = module.container_service.target_groups
}
