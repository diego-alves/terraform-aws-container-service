# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------

variable "name" {
  description = "ECS Service Name"
  type        = string
}

variable "cluster_name" {
  description = "ECS Cluster Name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnets" {
  description = "List of Subnets to include in the ECS Service"
  type        = set(string)
}

variable "target_group" {
  description = "Target Group"
  type        = string
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------

# ---------------------------------------------------------------------------------------------------------------------
# TASK CPU AND MEMORY FOR FARGATE
# 
# The table below show the valid combinations of task-level CPU and Memory. 
# 
#  CPU  Memory
#  256  512, 1024, 2048
#  512  1024-4096
# 1024  2048-8192
# 2048  4096-16384
# 4096  8192-30720
variable "cpu" {
  description = "Then number of cpu units used by the task. (256, 512, 1024, 2048, 4096)"
  type        = number
  default     = 256
}

variable "mem" {
  description = "The amount (in MiB) of memory used by the task. (512, 1024, 2048, 4096, ...)"
  type        = number
  default     = 512
}

variable "port" {
  description = "The port witch the application responds to"
  type        = number
  default     = 80
}

variable "environment" {
  description = "Environment Variables"
  type        = map(string)
  default     = {}
}

variable "secrets" {
  description = "Secrets from Systems Manager Parameter Storage"
  type        = map(string)
  default     = {}
}

variable "task_role" {
  description = "Task Role Arn"
  type        = string
  default     = null
}
