terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  backend "azurerm" {}
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.resource_group_name}-${var.environment}"
  location = var.location
  tags = {
    environment = var.environment
  }
}

resource "azurerm_storage_account" "web" {
  name                     = "stweb${var.environment}${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = var.environment == "prod" ? "GRS" : "LRS" # Redundancy for Prod
  account_kind             = "StorageV2"

  static_website {
    index_document     = "index.html"
    error_404_document = "index.html"
  }
}

resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

output "web_endpoint" {
  value = azurerm_storage_account.web.primary_web_endpoint
}

output "storage_account_name" {
  value = azurerm_storage_account.web.name
}

output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}
