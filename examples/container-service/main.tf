terraform {
  # This module is now only being tested with Terraform 0.14.x.
  required_version = ">= 0.14.0"
}

module "container_service" {
    source = "../../"

    name = "container_service_module_test"
}

output repository_url {
    value = module.container_service.repository_url
}