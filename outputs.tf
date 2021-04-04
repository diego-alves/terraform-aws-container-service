output repository_url {
  value = module.service.repository_url
  description = "This is the url of the docker repository"
}

output default_target_group {
  value = module.load_balancer.default_target_group
  description = "Default Target Grupo ID"
}

output target_groups {
  value = module.load_balancer.target_groups
  description = "Default Target Grupo ID"
}