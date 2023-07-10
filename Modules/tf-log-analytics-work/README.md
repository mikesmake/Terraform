#Log-analytics-work
##Purpose
This module is to create a log analytics workspace

##Usage
Use this module to deploy and manage a log analytics workspace as part of a larger composition.

###Examples

```
module "law" {
    source = "../../Modules/log-analytics-work"
    resource_group_name = azurerm_resource_group.rg.name
	law_name = "law-Service-Test"

    depends_on = [azurerm_resource_group.rg]

}
```
##External Dependencies
1. An Azure Resource Group