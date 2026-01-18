output "vnet_id" {
  value = azurerm_virtual_network.vnet.id
}

output "func_subnet_id" {
  value = azurerm_subnet.func_subnet.id
}

output "pe_subnet_id" {
  value = azurerm_subnet.pe_subnet.id
}
