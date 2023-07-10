#nsg
##Purpose
This module is to manage an network security group

##Usage
Use this module to manage an NSG that has all the default rules as required to allow peering back to "The hub". This will also allow additional rules to be added. 
###Examples

This an example of the main.tf config

```
# Create an NSG that will link to the "hosts" subnet
module "nsg"{
    source = "./nsg"
    resource_group_name = data.azurerm_resource_group.rg.name
    nsg_name = var.nsg_name
    hosts_subnet = var.hosts_subnet
    bastion_subnet = var.bastion_subnet
    security_rules = var.security_rules

    depends_on = [data.azurerm_resource_group.rg]
}
```

This is an example of the tfvars file that populates the variables


```
hosts_subnet = "10.81.3.0/25"
bastion_subnet = "10.80.0.192/26"
nsg_name = "nsg-OneMPS-prod"

security_rules =  {
    Allow_Internet                      = {
    priority                   = 300
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "Internet" 
    }

}

```

##External Dependencies
1. An Azure Resource Group