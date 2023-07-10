## cdn
## Purpose
This module is to manage an Azure CDN Service

## Usage
Use this module to manage an Azure CDN Service as part of a larger composition
### Examples

#### Simple Web App module usage
```
module "cdn" {
    source                                  = "./cdn"
    cdn_profile_name                        = module.naming.cdn_profile.name_unique
    resource_group_name                     = "rg"
    az_region                               = "East Us"
    sku                                     = "Standard_Verizon"
    cdn_endpoint_name                       = module.naming.cdn_endpoint.name_unique
    origin_name                             = "frontdoororigin"
    origin_host_name                        = "" #TODO frontdoor endpoint host name to be added here for connecting it with frontdoor service
}
```
## External Dependencies
1. An Azure Resource Group