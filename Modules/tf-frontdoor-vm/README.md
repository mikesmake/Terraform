# front-door-vm

##Purpose
This module is used to provide global external access, along with all the benifits of front door, to a website hosted on an Azure VM.

## Usage

Use this module provides built-in DDoS protection and application layer security and caching

### Examples

#### Simple Front Door module usage

```
module "frontdoor" {
  source = "./tf-frontdoor-vm"
  providers = {
    azurerm.hub   = azurerm.hub
    azurerm.spoke = azurerm.spoke
  }
  dns_zone_name           = "mps-dev.org"
  dns_zone_resource_group = "rg-dns-prod"

  resource_group_name         = azurerm_resource_group.rg.name
  resource_group_location     = azurerm_resource_group.rg.location
  frontdoor_name              = "fd-${local.service}${lower(trimprefix(terraform.workspace, local.service))}"
  origin_name                 = "origin-${local.service}${lower(trimprefix(terraform.workspace, local.service))}"
  nlb_ip                      = module.nlb.ip_address
  host_name                   = var.host_name[terraform.workspace]
  host_header                 = var.host_header[terraform.workspace]
  private_link_target_id      = module.private_link_service.id
  endpoint_name               = "endpoint-${local.service}${lower(trimprefix(terraform.workspace, local.service))}"
  log_analytics_workpace_rg   = var.log_analytics_workpace_rg
  log_analytics_workpace_name = var.log_analytics_workpace_name[terraform.workspace]
  environment_short_name      = var.environment_short_name[terraform.workspace]
  service                     = local.service
  tags                        = local.common_tags
  nlb_frontend_ip             = tolist([module.nlb.ip_address])



  depends_on = [module.private_link_service, azurerm_resource_group.rg]

}
```

## External Dependencies

1. An Azure Resource Group
2. DNS Zone
3. VM with NLB front end
4. Private Link Serivce
5. Log Analytics Workspace
