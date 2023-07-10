###################################################################################################
# Environment
###################################################################################################

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


data "azurerm_subnet" "subnet" {
  provider             = azurerm.spoke
  name                 = var.subnet_name
  virtual_network_name = var.virtual_network_name
  resource_group_name  = var.virtual_network_resource_group
}


data "azurerm_private_dns_zone" "dns_zone" {
  provider            = azurerm.hub
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = "rg-dns-prod"
}


###################################################################################################
# Key Vault
###################################################################################################


resource "azurerm_key_vault" "key_store" {
  name                          = var.key_vault_name
  location                      = var.resource_group_location
  resource_group_name           = var.resource_group_name
  enabled_for_disk_encryption   = true
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days    = 90
  purge_protection_enabled      = false
  sku_name                      = var.sku_name
  public_network_access_enabled = var.public_access
  tags                          = var.tags
}


###################################################################################################
# Access Policy
###################################################################################################


resource "azurerm_key_vault_access_policy" "tf_deployment_access_policy" {
  #Only create the resource if the flag "create_terraform_access_policy" has been set to true
  count = var.create_terraform_access_policy ? 1 : 0

  key_vault_id = azurerm_key_vault.key_store.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  key_permissions = [
    "Create",
    "Get",
  ]

  secret_permissions = [
    "Set",
    "Get",
    "Delete",
    "Purge",
    "Recover",
    "List"
  ]

  depends_on = [azurerm_key_vault.key_store]
}


#############################################################################################
# Private Endpoint
#############################################################################################

resource "azurerm_private_endpoint" "endpoint" {
  provider            = azurerm.spoke
  name                = var.endpoint_name
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  subnet_id           = data.azurerm_subnet.subnet.id

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [data.azurerm_private_dns_zone.dns_zone.id]
  }

  private_service_connection {
    name                           = "privateserviceconnection"
    private_connection_resource_id = azurerm_key_vault.key_store.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }

  depends_on = [azurerm_key_vault.key_store]
}
