#rsv
##Purpose
This module is to manage an recovery services vault

##Usage
Use this module to manage an NSG that has a deafult backup policy that matches MPSs backup policy. 
###Examples

This an example of the main.tf config

```
module "recovery_services_vault"{
    source = "./recovery-services"
    resource_group_name = data.azurerm_resource_group.rg.name
    recovery_services_vault_name = module.naming-back.recovery_services_vault.name
    recovery_services_vault_location = var.back_recovery_services_vault_location
    recovery_services_vault = module.naming-back.recovery_services_vault.name
    backup_policy_name = var.backup_policy_name


    depends_on = [data.azurerm_resource_group.rg]
}
```

This is an example of the tfvars file that populates the variables


```
recovery_services_vault_location = "UKSOUTH"
backup_policy_name = "pol-OneMPS-prod"



```

##External Dependencies
1. An Azure Resource Group