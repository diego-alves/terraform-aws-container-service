terraform {
  # This module is now only being tested with Terraform 0.14.x.
  required_version = ">= 0.14.0"
}

module "container_service" {
  source = "../../"

  name         = "module-test"
  zone         = ""
  cluster_name = ""
}
