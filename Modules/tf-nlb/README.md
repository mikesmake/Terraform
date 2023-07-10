#nsg
##Purpose
This module is to manage an internal network load balancer

##Usage
Use this module to manage an internal network load balancer. You can add custom backend pools, front ends, health probes and routing rules. 
###Examples

This an example of the main.tf config

```
# Create a load balancer with a backend pool, front end, health probe and routing rule.
module "nlb"{
    source = "../../Modules/tf-nlb"
    resource_group_name = var.resource_group_name
    vnet_name = var.vnet_name
    vnet_resource_group = var.vnet_resource_group
    subnet_name = var.subnet_name
    nlb_name = var.nlb_name
    front_end_name = var.front_end_name
    backend_pool_name = var.backend_pool_name
    health_probe_port = var.health_probe_port
    health_probe_name = var.health_probe_name
    rule_name = var.rule_name
    back_end_vms = var.back_end_vms
     depends_on = [module.vm]
}
```

This is an example of the tfvars file that populates the variables


```

resource_group_name = "Shared"
vnet_name = "Share_vnet"
vnet_resource_group = "vnet_RG"
subnet_name = "subnet"
nlb_name = "NLB"
front_end_name = "Front End"
backend_pool_name = "Back End"
health_probe_port = 80
health_probe_name = "health probe"
rule_name = "Rule1" 
back_end_vms = {
        ipconfig = {
            nic_id = module.vm.virtual_machine_nic_id
        }
    }


```

##External Dependencies
1. An Azure Resource Group