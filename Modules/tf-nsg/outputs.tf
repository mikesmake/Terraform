output "nsg_name" {
  value       = azurerm_network_security_group.nsg.name
  description = "The name of the nsg"
}

output "nsg_rules" {
  value       = azurerm_network_security_group.nsg.security_rule
  description = "The rules"
}

output "id" {
  value       = azurerm_network_security_group.nsg.id
  description = "The ID of the vnet"
}
