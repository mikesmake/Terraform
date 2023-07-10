# front-door

##Purpose
To create a private link service

## Usage

Used to provide a private network route between certain resource types

### Examples

#### Simple Front Door module usage

```
module "private_link_service" {
  source                   = "./PrivateLink"
  resource_group_name      = azurerm_resource_group.rg.name
  resource_group_location  = azurerm_resource_group.rg.location
  pls_name                 = "pls-${local.service}${lower(trimprefix(terraform.workspace, local.service))}"
  approved_subscription_id = ["ffffffff-ffff-ffff-ffff-ffffffffff"]

  subnet_id = data.azurerm_subnet.subnet.id

  nlb_id = module.nlb.frontend_ip_configuration_id


  tags = local.common_tags

  depends_on = [azurerm_resource_group.rg, module.vm, module.nlb]
}
```

## External Dependencies

1. An Azure Resource Group
2. A VNET to deply to (can be in a shared subnet with other resources)
3. Network load balancer
