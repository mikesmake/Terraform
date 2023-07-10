output "key_vault_name" {
  value       = azurerm_key_vault.key_store.name
  description = "The name of the key vault managed by this module"
}

output "key_vault_id" {
  value       = azurerm_key_vault.key_store.id
  description = "The id of the key vault managed by this module"
}