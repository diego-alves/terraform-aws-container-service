terraform {
  # This module is now only being tested with Terraform 0.14.x.
  required_version = ">= 0.14.0"
}

module "container_service" {
  source = "../../"

  name         = "module-test"
  zone         = "myzone.com"
  cluster_name = "myecs-cluster"
  extra_services = {
    api = {
      paths   = ["/api/*", "/docs"]
      hc_path = "/api/v1/health/"
      port    = 80
    }
  }
}
