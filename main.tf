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

  vpc_id  = module.data.vpc_id
  subnets = module.data.subnet_ids.app

  name  = var.name
  zone  = var.zone
  rules = var.extra_services
  default_rule = {
    hc_path = var.default_service.hc_path
    port    = var.default_service.port
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# DEFAULT SERVICE (REQUIRED)
# ---------------------------------------------------------------------------------------------------------------------

module "default_service" {
  source = "./modules/ecs"

  vpc_id       = module.data.vpc_id
  subnets      = module.data.subnet_ids.app
  target_group = module.load_balancer.default_target_group

  cluster_name = var.cluster_name
  name         = var.default_service.suffix == null || var.default_service.suffix == "" ? var.name : "${var.name}-${var.default_service.suffix}"
  cpu          = var.default_service.cpu
  mem          = var.default_service.mem
  port         = var.default_service.port
  replicas     = var.default_service.replicas

  environment = var.default_service.environment
  secrets     = var.default_service.secrets
}

# ---------------------------------------------------------------------------------------------------------------------
# EXTRA SERVICES (OPTIONAL)
# ---------------------------------------------------------------------------------------------------------------------

module "extra_services" {
  for_each = var.extra_services
  source   = "./modules/ecs"

  vpc_id       = module.data.vpc_id
  subnets      = module.data.subnet_ids.app
  target_group = module.load_balancer.target_groups[each.key]

  cluster_name = var.cluster_name
  name         = "${var.name}-${each.key}"

  cpu         = each.value.cpu
  mem         = each.value.mem
  port        = each.value.port
  replicas    = each.value.replicas
  environment = each.value.environment
  secrets     = each.value.secrets
}
