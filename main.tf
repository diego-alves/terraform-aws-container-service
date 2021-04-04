# ----------------------------------------------------------------------------------------------------------------------
# REQUIRE A SPECIFIC TERRAFORM VERSION OR HIGHER
# ----------------------------------------------------------------------------------------------------------------------

terraform {
  # This module is now only being tested with Terraform 0.14.x.
  required_version = ">= 0.14.0"
}

# ---------------------------------------------------------------------------------------------------------------------
# Data Module
# ---------------------------------------------------------------------------------------------------------------------

module "data" {
  source  = "diego-alves/data/aws"
  version = "0.0.5"
}

module "load_balancer" {
  source = "./modules/elb"

  name    = var.name
  vpc_id  = module.data.vpc_id
  subnets = module.data.subnet_ids.app
  zone    = var.zone
  rules = {
    api = {
      paths   = ["/api/*", "/docs"]
      hc_path = "/api/v1/health/"
      port    = 80
    }
  }
}

module "service" {
  source = "./modules/ecs"

  name         = var.name
  cluster_name = var.cluster_name
  vpc_id       = module.data.vpc_id
  subnets      = module.data.subnet_ids.app
  target_group = module.load_balancer.default_target_group

}
