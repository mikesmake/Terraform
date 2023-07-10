#key-vault
##Purpose
This module is to manage an Azure Key vault

##Usage
Use this module to manage an Azure key vault as part of a larger composition
###Examples

####Simple key vault module usage

```
module "key_vault" {
  source = "./kv"
  providers = {
    azurerm.hub   = azurerm.hub
    azurerm.spoke = azurerm.spoke
  }
  resource_group_name            = azurerm_resource_group.rg.name
  resource_group_location        = azurerm_resource_group.rg.location
  key_vault_name                 = "key-vault-test32131432"
  public_access                  = false
  endpoint_name                  = "ep-KV-test"
  subnet_name                    = "hosts"
  virtual_network_name           = "vnet-ianvss-dev"
  virtual_network_resource_group = "rg-SharedResources-land"




  tags = local.common_tags

  depends_on = [azurerm_resource_group.rg]
}
```

####Key vault usage without terraform access policy

```
module "key_vault" {
  source = "./kv"
  providers = {
    azurerm.hub   = azurerm.hub
    azurerm.spoke = azurerm.spoke
  }
  resource_group_name            = azurerm_resource_group.rg.name
  resource_group_location        = azurerm_resource_group.rg.location
  key_vault_name                 = "key-vault-test32131432"
  public_access                  = false
  endpoint_name                  = "ep-KV-test"
  subnet_name                    = "hosts"
  virtual_network_name           = "vnet-ianvss-dev"
  virtual_network_resource_group = "rg-SharedResources-land"
  create_terraform_access_policy = false




  tags = local.common_tags

  depends_on = [azurerm_resource_group.rg]
}
```

##External Dependencies

1. An Azure Resource Group
2. VNET
3. subnet
4. private DNS zone (linked to vnet)
