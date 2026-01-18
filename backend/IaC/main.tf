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

module "network" {
  source              = "./modules/network"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  vnet_name           = "vnet-emp-${var.environment}"
  address_space       = var.environment == "prod" ? ["10.100.0.0/16"] : ["10.0.0.0/16"] # Example of diff CIDR
  func_subnet_prefix  = var.environment == "prod" ? "10.100.1.0/24" : "10.0.1.0/24"
  pe_subnet_prefix    = var.environment == "prod" ? "10.100.2.0/24" : "10.0.2.0/24"
}

module "database" {
  source              = "./modules/database"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  account_name        = "cosmos-emp-${var.environment}-${random_string.suffix.result}"
  vnet_id             = module.network.vnet_id
  pe_subnet_id        = module.network.pe_subnet_id
}

module "app" {
  source               = "./modules/app"
  resource_group_name  = azurerm_resource_group.rg.name
  location             = azurerm_resource_group.rg.location
  function_app_name    = "func-emp-${var.environment}-${random_string.suffix.result}"
  storage_account_name = "saemp${var.environment}${random_string.suffix.result}"
  func_subnet_id       = module.network.func_subnet_id
  cosmos_endpoint      = module.database.account_endpoint
  cosmos_database      = module.database.database_name
  cosmos_container     = module.database.container_name
}

resource "random_string" "suffix" {
  length  = 4 # Shortened to keep total length manageable
  special = false
  upper   = false
}

# Cosmos DB Data Plane RBAC Assignment
resource "azurerm_cosmosdb_sql_role_assignment" "role" {
  resource_group_name = azurerm_resource_group.rg.name
  account_name        = module.database.account_name # Needs output update
  role_definition_id  = "${module.database.account_id}/sqlRoleDefinitions/00000000-0000-0000-0000-000000000002"
  principal_id        = module.app.principal_id
  scope               = module.database.account_id
}
