resource "azurerm_cosmosdb_account" "acc" {
  name                = var.account_name
  location            = var.location
  resource_group_name = var.resource_group_name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location          = var.location
    failover_priority = 0
  }

  # Disable local auth if using strictly RBAC, but for simplicity/terraform capability sometimes keys are used. 
  # User requested managed identity. 
  # local_authentication_disabled = true # optional, good security practice
}

resource "azurerm_cosmosdb_sql_database" "db" {
  name                = "EmployeeDB"
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.acc.name
}

resource "azurerm_cosmosdb_sql_container" "container" {
  name                  = "Employees"
  resource_group_name   = var.resource_group_name
  account_name          = azurerm_cosmosdb_account.acc.name
  database_name         = azurerm_cosmosdb_sql_database.db.name
  partition_key_paths   = ["/department"]
  partition_key_version = 1
}

# Private Endpoint
resource "azurerm_private_endpoint" "pe" {
  name                = "pe-cosmos-${var.account_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.pe_subnet_id

  private_service_connection {
    name                           = "psc-cosmos"
    private_connection_resource_id = azurerm_cosmosdb_account.acc.id
    subresource_names              = ["Sql"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.dns.id]
  }
}

resource "azurerm_private_dns_zone" "dns" {
  name                = "privatelink.documents.azure.com"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "link" {
  name                  = "vnet-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.dns.name
  virtual_network_id    = var.vnet_id
}
