#nsg
##Purpose
This module is to manage an Azure Function App.

##Usage
Use this module to manage an Azure Function App. 
###Examples

This an example of the main.tf config

```

module "function" {
    source = "../../Modules/tf-function-app"
    name                       = var.function_app_name
    loaction                   = azurerm_resource_group.rg.location
    resource_group_name        = azurerm_resource_group.rg.name
    app_service_plan_id        = azurerm_app_service_plan.app_plan.id
    storage_account_name       = data.azurerm_storage_account.storage.name
    storage_account_access_key = data.azurerm_storage_account.storage.primary_access_key


    depends_on = [azurerm_resource_group.rg]
    
}

```

This is an example of the tfvars file that populates the variables


```

var.function_app_name = "MyFunctionApp"


```

##External Dependencies
1. An Azure Resource Group