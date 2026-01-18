resource "azurerm_storage_account" "sa" {
  name                     = var.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_service_plan" "plan" {
  name                = "plan-${var.function_app_name}"
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Linux"
  sku_name            = "EP1" # Elastic Premium required for VNet integration private endpoint reachability typically, or Standard. Consumption VNet integration is possible now but sometimes tricky. I'll use EP1 for enterprise.
}

resource "azurerm_linux_function_app" "func" {
  name                = var.function_app_name
  resource_group_name = var.resource_group_name
  location            = var.location

  storage_account_name       = azurerm_storage_account.sa.name
  storage_account_access_key = azurerm_storage_account.sa.primary_access_key
  service_plan_id            = azurerm_service_plan.plan.id

  site_config {
    application_stack {
      node_version = "20"
    }
    vnet_route_all_enabled = true
  }

  virtual_network_subnet_id = var.func_subnet_id

  identity {
    type = "SystemAssigned"
  }

  app_settings = {
    "COSMOS_ENDPOINT"                = var.cosmos_endpoint
    "COSMOS_DATABASE"                = var.cosmos_database
    "COSMOS_CONTAINER"               = var.cosmos_container
    "BUILD_FLAGS"                    = "UseExpressBuild"
    "ENABLE_ORYX_BUILD"              = "true"
    "SCM_DO_BUILD_DURING_DEPLOYMENT" = "true"
  }
}
