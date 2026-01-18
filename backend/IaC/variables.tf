variable "resource_group_name" {
  description = "Base name for the resource group"
  type        = string
  default     = "rg-employee-app"
}

variable "location" {
  type    = string
  default = "eastus"
}

variable "environment" {
  description = "Environment name (e.g., dev, test, prod)"
  type        = string
}
