output "account_id" {
  value = azurerm_cosmosdb_account.acc.id
}

output "account_name" {
  value = azurerm_cosmosdb_account.acc.name
}

output "account_endpoint" {
  value = azurerm_cosmosdb_account.acc.endpoint
}

output "database_name" {
  value = azurerm_cosmosdb_sql_database.db.name
}

output "container_name" {
  value = azurerm_cosmosdb_sql_container.container.name
}
