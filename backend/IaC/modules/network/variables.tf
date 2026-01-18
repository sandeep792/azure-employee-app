variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "vnet_name" {
  type = string
}

variable "address_space" {
  type = list(string)
}

variable "func_subnet_prefix" {
  type = string
}

variable "pe_subnet_prefix" {
  type = string
}
