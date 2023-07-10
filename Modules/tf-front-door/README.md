# front-door
##Purpose
This module is a  highly available and scalable web application acceleration platform and global HTTP(s) load balancer.

## Usage
Use this module provides built-in DDoS protection and application layer security and caching
### Examples

#### Simple Front Door module usage
```
module "frontdoor-module" {
  resource_group_name                           = var.resource_group_name

  frontdoor_name                                = var.frontdoor_name
  backend_timeout                               = var.backend_timeout
  enforce_backend_pools_certificate_name_check  = false

  frontend_endpoint                             = var.frontend_endpoint

  backend_pool                                  = var.backend_pool
  
  routing_rule                                  = var.routing_rule
  routing_rule_redirect                         = var.routing_rule_redirect
  
  fd_load_balancing_name                        = var.fd_load_balancing_name

  fd_health_probe_name                          = var.fd_health_probe_name
  health_probe_protocol                         = var.health_probe_protocol

  waf_redirect_url                              = var.waf_redirect_url
  waf_policy_name                               = var.waf_policy_name
  waf_mode                                      = var.waf_mode
  waf_response_status_code                      = var.waf_response_status_code
  custom_rule                                   = var.custom_rule

  log_analytics_workpace_rg                     = azurerm_resource_group.rg.name
  log_analytics_workpace_name                   = var.log_analytics_workpace_name

  azurerm_frontdoor_custom_https_configuration  = var.azurerm_frontdoor_custom_https_configuration
}
```

## External Dependencies
1. An Azure Resource Group
2. A reference to the Backend webapp url