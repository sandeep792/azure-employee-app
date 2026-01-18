variable "resource_group_name" {
  default = "rg-employee-frontend"
}

variable "location" {
  default = "eastus"
}

variable "environment" {
  description = "Environment name (e.g., dev, test, prod)"
  type        = string
}
