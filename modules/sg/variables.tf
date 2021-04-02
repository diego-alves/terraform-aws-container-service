# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------

variable "name" {
  description = "Nome do Security Group"
}

variable "vpc_id" {
    description = "Id da VPC"
}

variable "ingresses" {
  description = "Lista de ingress"
  type = list(object({
    port     = number
    protocol = string
    cidrs    = list(string)
  }))
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------

variable "egresses" {
  description = "Lista de egress"
  type = list(object({
    port     = number
    protocol = string
    cidrs    = list(string)
  }))
  default = []
}