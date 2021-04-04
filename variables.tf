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

variable "extra_services" {
  description = "Map of extra services"
  type = map(object({ paths = list(string), hc_path = string, port = number }))
  default = {}
}