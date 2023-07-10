# apim
##Purpose
This module is to manage an API Management Service
## Usage
Use this module to publish APIs to external, partner, and employee developers securely and at scale. 
### Examples

#### Simple apim module usage


```
module "apim-mps" {
  source                    = "../apim"

  apim_name                 = var.apim_name
  resource_group_name       = data.azurerm_resource_group.resource_group.name
  apim_publisher_name       = var.apim_publisher_name
  apim_publisher_email      = var.apim_publisher_email
  apim_sku_name             = var.apim_sku_name
  
  apim_content_format       = var.apim_content_format
  apim_content_value        = var.apim_content_value
  apim_prod_display_name    = var.apim_prod_display_name
  
  apim_api_path             = var.apim_api_path
  apim_backend_protocol     = var.apim_backend_protocol
  apim_backend_url          = var.apim_backend_url
  
  apim_prodid               = var.apim_prodid
  apim_api_name             = var.apim_api_name
  apim_api_revision         = var.apim_api_revision
  apim_api_display_name     = var.apim_api_display_name
  apim_protocols            = var.apim_protocols
  apim_backend_name         = var.apim_backend_name

  application_insights_name = var.application_insights_name

  vnet_subnet_name          = var.nic_subnet_name_apim
  vnet_resource_group_name  = var.vnet_resource_group_name
  vnet_name                 = var.vnet_name
  api_virtual_network_type  = var.api_virtual_network_type

  apim_logger_name          = var.apim_logger_name
  identifier                = var.identifier
  sampling_percentage       = var.sampling_percentage
  verbosity                 = var.verbosity
  http_correlation_protocol = var.http_correlation_protocol
  policy_content_value      = var.policy_content_value

  named_value = var.named_value
}
```

## External Dependencies
1. An Azure Resource Group
2. A reference to the Backend VM api
3. Policies.xml file for defining policies for the Apis
4. Swagger.json file for defining Apis