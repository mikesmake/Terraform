output "backup_policy" {
  value       = azurerm_backup_policy_vm.backup_policy.name
  description = "The name of the backup policy"
}

output "backup_vault_name" {
  value       = azurerm_recovery_services_vault.vault.name
  description = "The name of the backup policy"
}
