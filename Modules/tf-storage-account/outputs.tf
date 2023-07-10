output "storage_account_name" {
  value       = azurerm_storage_account.st.name
  description = "The storage account name"
}

output "primary_blob_connection_string" {
  value       = azurerm_storage_account.st.primary_blob_connection_string
  description = "The connection string associated with the primary blob location."
}

output "storage_file_share_id" {
  value       = var.create_file_share ? azurerm_storage_share.file_share[0].id : ""
  description = "The id of the file share created under the storage account."
}

output "storage_container_name" {
  value       = var.create_blob_storage ? azurerm_storage_container.sc[0].name : ""
  description = "The name of the container created under the storage account."
}