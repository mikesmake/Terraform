#vnet-simple
##Purpose
This module is to manage a vnet that is peered to "the hub"

##Usage
Use this module to manage an Azure VNET that will need connectivity back to on-prem. 
Subnets may be passed in as a complex object type, allowing for flexibility of the subnet structure.
###Examples

This an example of the main.tf config

```module "tf-vnet-peering"{
    source = "./vnet-peering"
    providers = {
        azurerm.hub = azurerm.hub
        azurerm.spoke = azurerm.spoke
    }
    resource_group_name = data.azurerm_resource_group.rg.name
    vnet_name = var.vnet_name
    address_space = var.address_space
    dns_servers = var.dns_servers
    subnets = var.subnets

    depends_on = [data.azurerm_resource_group.rg]
}
```

This is an example of the tfvars file that populates the variables


```vnet_name = "vnet-OneMPS-prod"

address_space = ["10.81.3.0/24"]
dns_servers = ["10.80.0.133", "10.80.1.133"]
}

subnets = {
        hosts = {
            address_prefix = ["10.81.3.0/25"]
            delegation_name = ""
        }
    }

```

##External Dependencies
1. An Azure Resource Group