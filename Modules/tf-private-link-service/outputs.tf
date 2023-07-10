output "location" {
  value       = azurerm_private_link_service.pls.location
  description = "The name of the key vault managed by this module"
}

output "id" {
  value       = azurerm_private_link_service.pls.id
  description = "The id of the key vault managed by this module"
}
