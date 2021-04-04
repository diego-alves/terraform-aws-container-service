output "default_service" {
  value = {
    name   = module.default_service.name
    docker = module.default_service.repository_url
    url    = "https://${module.load_balancer.domain}"
  }
  description = "Default Service attributes"
}

output "extra_services" {
  value = tomap({
    for k, v in var.extra_services : k => {
      name   = module.extra_services[k].name
      docker = module.extra_services[k].repository_url
      url    = "https://${module.load_balancer.domain}${var.extra_services[k].paths[0]}"
    }
  })
  description = "Extra Services attributes"
}
