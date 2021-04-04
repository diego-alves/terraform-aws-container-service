# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------
variable "name" {
  description = "A name for the load balance and its dependencies"
  type        = string
}

variable "vpc_id" {
  description = "The Vpc ID"
  type        = string
}

variable "subnets" {
  description = "A list of subnet IDs to attach to the ELB"
  type        = set(string)
}

variable "zone" {
  description = "A Route53 Zone name"
  type        = string
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------

variable "default_rule" {
  description = "Parameters for default rule"
  type        = object({ hc_path = string, port = number })
  default = {
    hc_path = "/"
    port    = 80
  }
}

variable "rules" {
  description = "Context rules: ex api: {paths=['/api'], hc_path='/api/v1/health/'"
  type        = map(object({ paths = list(string), hc_path = string, port = number }))
  default     = {}
}
