# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# These variables must be set in the module block when using this module.
# ---------------------------------------------------------------------------------------------------------------------

variable "name" {
  description = "The name of the Service"
}

variable "zone" {
  description = "Route53 zone"
}

variable "cluster_name" {
  description = "ECS Cluster Name"
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These variables have default values and don't have to be set to use this module.
# You may set these variables to override their default values.
# ---------------------------------------------------------------------------------------------------------------------

variable "default_service" {
  description = "Default Service options"
  type = object({
    suffix      = string
    hc_path     = string
    cpu         = number
    mem         = number
    port        = number
    replicas    = number
    environment = map(string)
    secrets     = map(string)
  })
  default = {
    suffix      = null
    hc_path     = "/"
    cpu         = 256
    mem         = 512
    port        = 80
    replicas    = 2
    environment = {}
    secrets     = {}
  }
}

variable "extra_services" {
  description = "Map of extra services"
  type = map(object({
    paths       = list(string)
    hc_path     = string
    cpu         = number
    mem         = number
    port        = number
    replicas    = number
    environment = map(string)
    secrets     = map(string)
  }))
  default = {}
}
