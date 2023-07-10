#nsg
##Purpose
This module is to manage an AKS instance

##Usage
Use this module to manage an instance. 
###Examples

This an example of the main.tf config

```
# Create a load balancer with a backend pool, front end, health probe and routing rule.
module "aks" {
    source = "../../Modules/aks"
    resource_group_name = azurerm_resource_group.rg.name
    kubernetes_cluster_name = var.kubernetes_cluster_name
    kubernetes_cluster_dns_prefix = var.kubernetes_cluster_dns_prefix


    depends_on = [azurerm_resource_group.rg]
    
}
```

This is an example of the tfvars file that populates the variables


```

kubernetes_cluster_dns_prefix = "mps-chbeu-name"
kubernetes_cluster_name = "mps-terraform-name"


```

##External Dependencies
1. An Azure Resource Group