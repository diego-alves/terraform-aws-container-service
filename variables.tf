# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
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
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------

variable "extra_services" {
  description = "Map of extra services"
  type = map(object({ paths = list(string), hc_path = string, port = number }))
  default = {}
}