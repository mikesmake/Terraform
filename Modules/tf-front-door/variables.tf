#resource group nname
variable "resource_group_name" {
  type        = string
  description = "Existing resource group name"
  default     = "azure-model"
}

#Azure FrontDoor service
#FrontDoor Service Configuration
variable "frontdoor_name" {
  type        = string
  description = "front door name"
  default     = "azure-frontdoor-demo-latest"
}

variable "tags" {
  type        = map(any)
  description = "Tags to identify web app"
}

variable "backend_timeout" {
  type        = number
  description = "backend pool timeout. in seconds"
  default     = 50
}

#Routing Rule Configuration
variable "routing_rule" {
  description = "routing rules for the frontdoor service"
  type = map(object({
    accepted_protocols = list(string)
    patterns_to_match  = list(string)
    frontend_endpoints = list(string)
    forwarding_configuration = list(object({
      forwarding_protocol           = string
      backend_pool_name             = string
      cache_enabled                 = bool
      cache_use_dynamic_compression = bool
    }))
  }))
  default = {
    "routing-rule-one" = {
      accepted_protocols = ["Http", "Https"]
      patterns_to_match  = ["/backend-one"]
      frontend_endpoints = ["azure-frontdoor-demo-latest"]
      forwarding_configuration = [{
        forwarding_protocol           = "MatchRequest"
        backend_pool_name             = "backend-one"
        cache_enabled                 = false
        cache_use_dynamic_compression = false
      }]
    },
    "routing-rule-two" = {
      accepted_protocols = ["Http", "Https"]
      patterns_to_match  = ["/backend-two"]
      frontend_endpoints = ["azure-frontdoor-demo-latest"]
      forwarding_configuration = [{
        forwarding_protocol           = "MatchRequest"
        backend_pool_name             = "backend-two"
        cache_enabled                 = false
        cache_use_dynamic_compression = false
      }]
    }
  }
}

variable "routing_rule_redirect" {
  description = "routing rules for the frontdoor service"
  type = map(object({
    accepted_protocols = list(string)
    patterns_to_match  = list(string)
    frontend_endpoints = list(string)
    redirect_configuration = list(object({
      redirect_protocol = string
      redirect_type     = string
      custom_host       = string
    }))
  }))
  default = {
    "routing-rule-redirect-one" = {
      accepted_protocols = ["Http"]
      patterns_to_match  = ["/backend-one-two"]
      frontend_endpoints = ["azure-frontdoor-demo-latest"]
      redirect_configuration = [{
        redirect_protocol = "HttpsOnly"
        redirect_type     = "Found"
        custom_host       = "medicalprotection.org"

      }]
    } /*,
        "routing-rule-two" = {
            accepted_protocols = ["Http","Https"]
            patterns_to_match = ["/backend-two"]
            frontend_endpoints = ["azure-frontdoor-demo-latest"]
            forwarding_configuration = [{
                forwarding_protocol = "MatchRequest"
                backend_pool_name = "backend-two"
            }]
        }*/
  }
}

#Backend Pool Configuration
variable "backend_pool" {
  description = "backend pool for the front door service"
  type = map(object({
    health_probe_name   = string
    load_balancing_name = string
    backend = list(object({
      host_header = string
      address     = string
      http_port   = number
      https_port  = number
      priority    = number
      weight      = number
    }))
  }))

  default = {
    "backend-one" = {
      health_probe_name   = "healthprobename"
      load_balancing_name = "lbname"
      backend = [{
        host_header = "www.facebook.com"
        address     = "www.facebook.com"
        http_port   = 80
        https_port  = 443
        priority    = 1
        weight      = 50
        },
        {
          host_header = "www.google.com"
          address     = "www.google.com"
          http_port   = 80
          https_port  = 443
          priority    = 1
          weight      = 50
      }]
    }
    "backend-two" = {
      health_probe_name   = "healthprobename"
      load_balancing_name = "lbname"
      backend = [{
        host_header = "www.bing.com"
        address     = "www.bing.com"
        http_port   = 80
        https_port  = 443
        priority    = 1
        weight      = 50
        },
        {
          host_header = "www.terraform.io"
          address     = "www.terraform.io"
          http_port   = 80
          https_port  = 443
          priority    = 1
          weight      = 50
      }]
    }
  }
}

#FrontEnd Endpoints Configuration
variable "frontend_endpoint" {
  description = "frontend endpoints for front door service"
  type = map(object({
    host_name = string
  }))
  default = {
    "azure-frontdoor-demo-latest" = {
      host_name = "azure-frontdoor-demo-latest.azurefd.net"
    }
  }
}

#Loadbalancing Rules & Health Probe Configuration
variable "fd_load_balancing_name" {
  type        = string
  description = "front door load balancing name"
  default     = "frontend-loadbalancer-mpsl"
}

variable "fd_health_probe_name" {
  type        = string
  description = "front door health probe name"
  default     = "frontend-healthprobe-mpsl"
}

#backend_pool_health_probe Configuration
# name must be fd_load_balancing_name
variable "backend_pool_health_probe" {
  description = "backend pool rules for the frontdoor service"
  type = map(object({
    protocol     = string
    probe_method = string
    path         = string
  }))
  default = {
    "fd_health_probe_name_one" = {
      protocol     = "Https"
      probe_method = "HEAD"
      path         = "/"
    },
    "fd_health_probe_name-two" = {
      protocol     = "Https"
      probe_method = "HEAD"
      path         = "/"
    }
  }
}

#Windows Azure Firewall Policy COnfiguration
/*variable "front-door-waf-object" {
  description = "Required AFD Settings of the Azure  Front Door to be created"  
}*/

variable "waf_redirect_url" {
  type        = string
  description = "WAF redirect Url"
  default     = "https://www.google.com"
}

/*variable "waf_custom_block_response_body"  {
    type = string
    description = "waf custom block response body if custom rule block action type is block."
    default = "PGh0bWw+CjxoZWFkZXI+PHRpdGxlPkhlbGxvPC90aXRsZT48L2hlYWRlcj4KPGJvZHk+CkhlbGxvIHdvcmxkCjwvYm9keT4KPC9odG1sPg=="
}*/

variable "waf_policy_name" {
  type        = string
  description = "WAF policy name"
  default     = "frontdoorpolicy"
}

variable "waf_mode" {
  type        = string
  description = "WAF mode name should be given here. values can be Detection or Prevention.Prevention would be setted by default"
  default     = "Prevention"
}

variable "waf_response_status_code" {
  type        = number
  description = "WAF response status code would require if custom rule block action type is block. for eg: 200,403,405,406 or 429"
  default     = "403"
}

variable "custom_rule" {
  type = map(object({
    enabled                        = bool
    priority                       = number
    rate_limit_duration_in_minutes = number
    rate_limit_threshold           = number
    type                           = string
    action                         = string
    match_condition = list(object({
      match_variable     = string
      operator           = string
      negation_condition = bool
      match_values       = list(string)
    }))
  }))
  description = "match condiiton for the rules"
  default = {
    "ruleone" = {
      enabled                        = true
      priority                       = 1
      rate_limit_duration_in_minutes = 1
      rate_limit_threshold           = 10
      type                           = "MatchRule"
      action                         = "Block"
      match_condition = [{
        match_variable     = "RemoteAddr"
        operator           = "IPMatch"
        negation_condition = false
        match_values       = ["192.168.1.0/24", "10.0.0.0/24"]
      }]
    }
    "ruletwo" = {
      enabled                        = true
      priority                       = 2
      rate_limit_duration_in_minutes = 1
      rate_limit_threshold           = 10
      type                           = "MatchRule"
      action                         = "Block"
      match_condition = [{
        match_variable     = "RemoteAddr"
        operator           = "IPMatch"
        negation_condition = false
        match_values       = ["192.168.1.0/24"]
      }]
    }
  }
}

#Custom Https Configuration
variable "azurerm_frontdoor_custom_https_configuration" {
  description = "azure frontdoor custom https configuration"
  type = map(object({
    custom_https_provisioning_enabled = bool
  }))

  default = {
    "azure-frontdoor-demo-latest" = {
      custom_https_provisioning_enabled = true
    }
  }
}

variable "log_analytics_workpace_rg" {
  type        = string
  description = "The resource group that hosts the LAW"
}

variable "log_analytics_workpace_name" {
  type        = string
  description = "The LAW name"
}

variable "fd_diag_logs" {
  description = "Frontdoor Monitoring Category details for Azure Diagnostic setting"
  default     = ["FrontdoorAccessLog", "FrontdoorWebApplicationFirewallLog"]
}