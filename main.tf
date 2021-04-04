# ----------------------------------------------------------------------------------------------------------------------
# REQUIRE A SPECIFIC TERRAFORM VERSION OR HIGHER
# ----------------------------------------------------------------------------------------------------------------------

terraform {
  # This module is now only being tested with Terraform 0.14.x.
  required_version = ">= 0.14.0"
}

# ---------------------------------------------------------------------------------------------------------------------
# DATA MODULE
# ---------------------------------------------------------------------------------------------------------------------

module "data" {
  source  = "diego-alves/data/aws"
  version = "0.0.5"
}

# ---------------------------------------------------------------------------------------------------------------------
# LOAD BALANCER
# ---------------------------------------------------------------------------------------------------------------------

module "load_balancer" {
  source = "./modules/elb"

  name    = var.name
  vpc_id  = module.data.vpc_id
  subnets = module.data.subnet_ids.app
  zone    = var.zone
  rules   = var.extra_services
}

# ---------------------------------------------------------------------------------------------------------------------
# DEFAULT SERVICE (REQUIRED)
# ---------------------------------------------------------------------------------------------------------------------

module "default_service" {
  source = "./modules/ecs"

  name         = var.name
  target_group = module.load_balancer.default_target_group

  cluster_name = var.cluster_name
  vpc_id       = module.data.vpc_id
  subnets      = module.data.subnet_ids.app
  task_role    = var.task_role
}

# ---------------------------------------------------------------------------------------------------------------------
# EXTRA SERVICES (OPTIONAL)
# ---------------------------------------------------------------------------------------------------------------------

module "extra_services" {
  for_each = var.extra_services
  source   = "./modules/ecs"

  name         = "${var.name}-${each.key}"
  target_group = module.load_balancer.target_groups[each.key]

  cluster_name = var.cluster_name
  vpc_id       = module.data.vpc_id
  subnets      = module.data.subnet_ids.app

}
