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


#############################################################################################
# Data Blocks
#############################################################################################
data "azurerm_resource_group" "rg" {
  provider = azurerm.spoke
  name     = var.resource_group_name
}

data "azurerm_subnet" "subnet" {
  count                = var.private_endpoint ? 1 : 0
  provider             = azurerm.spoke
  name                 = var.subnet_name
  virtual_network_name = var.virtual_network_name
  resource_group_name  = var.virtual_network_resource_group
}

data "azurerm_private_dns_zone" "blob_dns_zone" {
  count               = var.private_endpoint ? 1 : 0
  provider            = azurerm.hub
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = "rg-dns-prod"
}

data "azurerm_private_dns_zone" "file_dns_zone" {
  count               = var.private_endpoint ? 1 : 0
  provider            = azurerm.hub
  name                = "privatelink.file.core.windows.net"
  resource_group_name = "rg-dns-prod"
}


#############################################################################################
# Storage Account 
#############################################################################################

resource "azurerm_storage_account" "st" {
  provider                      = azurerm.spoke
  name                          = var.storage_account_name
  resource_group_name           = data.azurerm_resource_group.rg.name
  location                      = var.resource_group_location
  account_tier                  = var.storage_account_tier
  account_replication_type      = var.storage_replication_type
  account_kind                  = var.storage_account_kind
  min_tls_version               = "TLS1_2"
  enable_https_traffic_only     = "true"
  public_network_access_enabled = var.allow_public_access

  depends_on = [data.azurerm_resource_group.rg]

}

#############################################################################################
# Storage Container
#############################################################################################

resource "azurerm_storage_container" "sc" {
  count = var.create_blob_storage ? 1 : 0

  provider              = azurerm.spoke
  name                  = var.storage_container_name
  storage_account_name  = azurerm_storage_account.st.name
  container_access_type = var.container_access_type

  depends_on = [azurerm_storage_account.st]
}

#############################################################################################
# Storage Blob
#############################################################################################

resource "azurerm_storage_blob" "blob" {
  count = var.create_blob_storage ? 1 : 0

  provider               = azurerm.spoke
  name                   = var.blob_name
  storage_account_name   = azurerm_storage_account.st.name
  storage_container_name = azurerm_storage_container.sc[0].name
  type                   = var.storage_blob_type

  depends_on = [azurerm_storage_account.st, azurerm_storage_container.sc]
}

#############################################################################################
# File Share
#############################################################################################

resource "azurerm_storage_share" "file_share" {
  count = var.create_file_share ? 1 : 0

  provider             = azurerm.spoke
  name                 = var.file_share_name
  storage_account_name = azurerm_storage_account.st.name
  quota                = var.file_sharequota

  depends_on = [azurerm_storage_account.st]
}


#############################################################################################
# Private Endpoint
#############################################################################################

resource "azurerm_private_endpoint" "blob_endpoint" {
  count               = var.private_endpoint ? 1 : 0
  provider            = azurerm.spoke
  name                = "${var.endpoint_name}-blob"
  location            = var.resource_group_location
  resource_group_name = data.azurerm_resource_group.rg.name
  subnet_id           = data.azurerm_subnet.subnet[0].id

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [data.azurerm_private_dns_zone.blob_dns_zone[0].id]
  }

  private_service_connection {
    name                           = "privateserviceconnection"
    private_connection_resource_id = azurerm_storage_account.st.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  depends_on = [azurerm_storage_account.st, data.azurerm_private_dns_zone.blob_dns_zone, data.azurerm_resource_group.rg, data.azurerm_subnet.subnet]
}


resource "azurerm_private_endpoint" "file_endpoint" {
  count               = var.private_endpoint ? 1 : 0
  provider            = azurerm.spoke
  name                = "${var.endpoint_name}-file"
  location            = var.resource_group_location
  resource_group_name = data.azurerm_resource_group.rg.name
  subnet_id           = data.azurerm_subnet.subnet[0].id

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [data.azurerm_private_dns_zone.file_dns_zone[0].id]
  }

  private_service_connection {
    name                           = "privateserviceconnection"
    private_connection_resource_id = azurerm_storage_account.st.id
    subresource_names              = ["file"]
    is_manual_connection           = false
  }

  depends_on = [azurerm_storage_account.st, data.azurerm_private_dns_zone.file_dns_zone, data.azurerm_resource_group.rg, data.azurerm_subnet.subnet]

}
