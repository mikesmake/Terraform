<!-- BEGIN_TF_DOCS -->

# tf-storage-account

## Purpose

This module is to create a storage account

## Usage

Use this module to deploy and manage an Azure storage account as part of a larger composition.

### Examples

Create a storage account with public access and no endpoints

```module "storage" {
  source = "./storage"

  providers = {
    azurerm.hub   = azurerm.hub
    azurerm.spoke = azurerm.spoke
  }

  resource_group_name      = azurerm_resource_group.rg.name
  resource_group_location  = "UKSouth"
  storage_account_name     = "samikesprivatetest"
  storage_account_kind     = "StorageV2"
  allow_blob_public_access = true

  depends_on = [azurerm_resource_group.rg]

}
```

You can use the booleans "create_blob_storage" and "create_file_share" to create the respective sub accounts.

```module "storage" {
  source = "./storage"

  providers = {
    azurerm.hub   = azurerm.hub
    azurerm.spoke = azurerm.spoke
  }

  resource_group_name      = azurerm_resource_group.rg.name
  resource_group_location  = "UKSouth"
  storage_account_name     = "samikesprivatetest"
  storage_account_kind     = "StorageV2"
  allow_blob_public_access = true

  create_blob_storage      = true
  storage_container_name   = "container_name"
  container_access_type    = "StorageV2"
  blob_name                = "blob.txt"
  storage_blob_type        = "Block"

  depends_on = [azurerm_resource_group.rg]

}
```

Storage account with private endpoints

```module "storage" {
  source = "./storage"

  providers = {
    azurerm.hub   = azurerm.hub
    azurerm.spoke = azurerm.spoke
  }

  resource_group_name            = azurerm_resource_group.rg.name
  resource_group_location        = "UKSouth"
  storage_account_name           = "samikesprivatetest"
  storage_account_kind           = "StorageV2"
  allow_public_access            = false
  private_endpoint               = true
  subnet_name                    = "hosts"
  virtual_network_name           = "vnet-ATest-prod"
  virtual_network_resource_group = "rg-SharedServices-land"
  endpoint_name                  = "pe-Mike-test"


  depends_on = [azurerm_resource_group.rg]

}
```

## External Dependencies

1. An Azure Resource Group
2. VNET (when using private endpoints)
