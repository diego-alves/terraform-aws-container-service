terraform {
  # This module is now only being tested with Terraform 0.14.x.
  required_version = ">= 0.14.0"
}

module "container_service" {
    source = "../../"

    name = "module-test"
}

output repository_url {
    value = module.container_service.repository_url
}

output default_target_group {
  value = module.container_service.default_target_group
}

output target_groups {
  value = module.container_service.target_groups
}