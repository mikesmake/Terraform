#############################################################################################
# Environment
#############################################################################################

terraform {
  required_providers {
    azurerm = {
      source                = "hashicorp/azurerm"
      configuration_aliases = [azurerm.hub, azurerm.spoke]
      version               = "=3.30.0"
    }
  }
}

data "azurerm_client_config" "current" {}

#############################################################################################
# Data Blocks
#############################################################################################

data "azurerm_resource_group" "resource_group" {
  provider = azurerm.spoke
  name     = var.resource_group_name
}

data "azurerm_key_vault" "key_store" {
  provider            = azurerm.spoke
  name                = var.key_vault_name
  resource_group_name = var.resource_group_name
}

data "azurerm_storage_account" "sql_audit_store" {
  provider            = azurerm.spoke
  name                = var.audit_storage_account
  resource_group_name = var.audit_storage_account_resource_group
}

data "azurerm_subnet" "subnet" {
  provider             = azurerm.spoke
  name                 = var.subnet_name
  virtual_network_name = var.virtual_network_name
  resource_group_name  = var.virtual_network_resource_group
}

data "azurerm_virtual_network" "vnet" {
  provider            = azurerm.spoke
  name                = var.virtual_network_name
  resource_group_name = var.virtual_network_resource_group
}

data "azurerm_private_dns_zone" "dns_zone" {
  provider            = azurerm.hub
  name                = "privatelink.database.windows.net"
  resource_group_name = "rg-dns-prod"
}

#############################################################################################
# SQL Server Credentials 
#############################################################################################

resource "random_id" "storage_name" {
  byte_length = 6
}

resource "random_id" "sql_admin_user" {
  byte_length = 7
}

resource "random_password" "sql_admin_password" {
  length           = 16
  special          = true
  override_special = "!@#*()[]{}<>:" #Restricted special characters for compatibility reasons.
}

resource "azurerm_key_vault_secret" "sql_admin_username" {
  name         = "${var.sql_server_name}-admin-username"
  value        = random_id.sql_admin_user.hex
  key_vault_id = data.azurerm_key_vault.key_store.id
}

resource "azurerm_key_vault_secret" "sql_admin_password" {
  name         = "${var.sql_server_name}-admin-password"
  value        = random_password.sql_admin_password.result
  key_vault_id = data.azurerm_key_vault.key_store.id
}

#############################################################################################
# SQL Server
#############################################################################################

resource "azurerm_mssql_server" "sql_server" {
  provider                      = azurerm.spoke
  name                          = var.sql_server_name
  resource_group_name           = data.azurerm_resource_group.resource_group.name
  location                      = var.resource_group_location
  version                       = "12.0"
  administrator_login           = random_id.sql_admin_user.hex
  administrator_login_password  = random_password.sql_admin_password.result
  minimum_tls_version           = "1.2"
  public_network_access_enabled = var.public_access

  azuread_administrator {
    login_username = var.azure_activedirectory_admin["login_username"]
    object_id      = var.azure_activedirectory_admin["object_id"]
  }

}

#############################################################################################
# SQL Audit
#############################################################################################

resource "azurerm_mssql_server_extended_auditing_policy" "sql_audit_policy" {
  provider = azurerm.spoke
  count    = var.enable_audit ? 1 : 0

  server_id                               = azurerm_mssql_server.sql_server.id
  storage_endpoint                        = data.azurerm_storage_account.sql_audit_store.primary_blob_endpoint
  storage_account_access_key              = data.azurerm_storage_account.sql_audit_store.primary_access_key
  storage_account_access_key_is_secondary = false
  retention_in_days                       = 30

  depends_on = [azurerm_mssql_server.sql_server]

}

resource "azurerm_mssql_server_security_alert_policy" "sql_sec_alert_policy" {
  provider = azurerm.spoke
  count    = var.enable_audit ? 1 : 0

  resource_group_name        = data.azurerm_resource_group.resource_group.name
  server_name                = azurerm_mssql_server.sql_server.name
  state                      = "Enabled"
  storage_endpoint           = data.azurerm_storage_account.sql_audit_store.primary_blob_endpoint
  storage_account_access_key = data.azurerm_storage_account.sql_audit_store.primary_access_key
  retention_days             = 30
  email_account_admins       = true
  email_addresses            = ["dbateam@mps.org.uk"]

  depends_on = [azurerm_mssql_server.sql_server]
}

#############################################################################################
# SQL Firewall Rules
#############################################################################################

resource "azurerm_mssql_firewall_rule" "sql_firewall_rule_azaccess" {
  provider = azurerm.spoke
  count    = var.allow_azure_access_to_sql ? 1 : 0

  name             = "sql_fw_allow_azure"
  server_id        = azurerm_mssql_server.sql_server.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"

  depends_on = [azurerm_mssql_server.sql_server]
}

resource "azurerm_mssql_firewall_rule" "sql_firewall_rule_ldsaccess" {
  count = var.allow_access_from_leeds_office ? 1 : 0

  name             = "leeds_office"
  server_id        = azurerm_mssql_server.sql_server.id
  start_ip_address = "81.134.223.15"
  end_ip_address   = "81.134.223.15"

  depends_on = [azurerm_mssql_server.sql_server]
}

#############################################################################################
# Private Endpoint
#############################################################################################

resource "azurerm_private_endpoint" "endpoint" {
  provider            = azurerm.spoke
  name                = var.endpoint_name
  location            = var.resource_group_location
  resource_group_name = data.azurerm_resource_group.resource_group.name
  subnet_id           = data.azurerm_subnet.subnet.id

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [data.azurerm_private_dns_zone.dns_zone.id]
  }

  private_service_connection {
    name                           = "privateserviceconnection"
    private_connection_resource_id = azurerm_mssql_server.sql_server.id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }

}

#############################################################################################
# Database
#############################################################################################


resource "azurerm_mssql_database" "sql_database" {
  provider     = azurerm.spoke
  for_each     = var.sql_dbs
  name         = each.value["name"]
  server_id    = azurerm_mssql_server.sql_server.id
  license_type = "LicenseIncluded"
  sku_name     = each.value["sku_name"]

  lifecycle {
    ignore_changes = [
      sku_name,
      license_type
    ]
  }

  depends_on = [azurerm_mssql_server.sql_server]
}

#############################################################################################
# Database Audit
#############################################################################################

resource "azurerm_mssql_database_extended_auditing_policy" "sql_database_audit_policy" {
  provider = azurerm.spoke
  for_each = var.sql_dbs

  database_id                             = azurerm_mssql_database.sql_database[each.key].id
  storage_endpoint                        = data.azurerm_storage_account.sql_audit_store.primary_blob_endpoint
  storage_account_access_key              = data.azurerm_storage_account.sql_audit_store.primary_access_key
  storage_account_access_key_is_secondary = false
  retention_in_days                       = 6

  depends_on = [azurerm_mssql_database.sql_database]
}
