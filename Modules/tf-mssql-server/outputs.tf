output "sql_audit_storage_account_name" {
  value       = var.enable_audit ? data.azurerm_storage_account.sql_audit_store.name : ""
  description = "The storage account name of the sql audit store"
}

output "sql_server_name" {
  value       = azurerm_mssql_server.sql_server.name
  description = "The name of the sql server"
}

output "sql_server_id" {
  value       = azurerm_mssql_server.sql_server.id
  description = "The id of the sql server"
}

output "sql_server_admin_username" {
  value       = format("%s-admin-username", azurerm_mssql_server.sql_server.name)
  description = "The name of the key vault secret holding the SQL username"
}

output "sql_server_admin_password" {
  value       = format("%s-admin-password", azurerm_mssql_server.sql_server.name)
  description = "The name of the key vault secret holding the SQL password"
}


output "sql_database_id" {
  value       = [for db in azurerm_mssql_database.sql_database : db.id]
  description = "The id of the SQL databases"
}

output "sql_database_name" {
  value       = [for db in azurerm_mssql_database.sql_database : db.name]
  description = "The name of the SQL databases"
}
