terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.30.0"
    }
  }
}

#############################################################################################
# data providers
#############################################################################################

data "azurerm_resource_group" "frontdoor" {
  name = var.resource_group_name
}

data "azurerm_log_analytics_workspace" "log" {
  name                = var.log_analytics_workpace_name
  resource_group_name = var.log_analytics_workpace_rg
}

#############################################################################################
# resource providers
#############################################################################################

#provisioning firewall policy for the front door service
resource "azurerm_frontdoor_firewall_policy" "waf_policies" {
  name                              = var.waf_policy_name
  resource_group_name               = data.azurerm_resource_group.frontdoor.name
  enabled                           = true
  mode                              = var.waf_mode
  redirect_url                      = var.waf_redirect_url
  custom_block_response_status_code = var.waf_response_status_code
  tags                              = var.tags
  #custom_block_response_body        = var.waf_custom_block_response_body #"PGh0bWw+CjxoZWFkZXI+PHRpdGxlPkhlbGxvPC90aXRsZT48L2hlYWRlcj4KPGJvZHk+CkhlbGxvIHdvcmxkCjwvYm9keT4KPC9odG1sPg=="

  dynamic "custom_rule" {
    for_each = var.custom_rule
    content {
      name                           = custom_rule.key
      enabled                        = custom_rule.value["enabled"]
      priority                       = custom_rule.value["priority"]
      rate_limit_duration_in_minutes = custom_rule.value["rate_limit_duration_in_minutes"]
      rate_limit_threshold           = custom_rule.value["rate_limit_threshold"]
      type                           = custom_rule.value["type"]
      action                         = custom_rule.value["action"]

      dynamic "match_condition" {
        for_each = custom_rule.value["match_condition"]
        content {
          match_variable     = match_condition.value["match_variable"]
          operator           = match_condition.value["operator"]
          negation_condition = match_condition.value["negation_condition"]
          match_values       = match_condition.value["match_values"]
        }
      }
    }
  }

  managed_rule {
    type    = "Microsoft_DefaultRuleSet"
    version = "1.1"
  }

  managed_rule {
    type    = "Microsoft_BotManagerRuleSet"
    version = "1.0"
  }
}

#provisioning azure FrontDoor service
resource "azurerm_frontdoor" "frontdoor" {
  name                = var.frontdoor_name
  resource_group_name = data.azurerm_resource_group.frontdoor.name
  tags                = var.tags

  backend_pool_settings {
    enforce_backend_pools_certificate_name_check = false
    backend_pools_send_receive_timeout_seconds   = var.backend_timeout
  }

  #configuring frontend endpoints for the FrontDoor service
  dynamic "frontend_endpoint" {
    for_each = var.frontend_endpoint
    content {
      name                                    = frontend_endpoint.key
      host_name                               = frontend_endpoint.value["host_name"]
      web_application_firewall_policy_link_id = azurerm_frontdoor_firewall_policy.waf_policies.id
    }
  }

  #configruing backend pools for the FrontDoor service
  dynamic "backend_pool" {
    for_each = var.backend_pool
    content {
      name                = backend_pool.key
      health_probe_name   = backend_pool.value["health_probe_name"]
      load_balancing_name = backend_pool.value["load_balancing_name"]
      dynamic "backend" {
        for_each = backend_pool.value["backend"]
        content {
          host_header = backend.value["host_header"]
          address     = backend.value["address"]
          http_port   = backend.value["http_port"]
          https_port  = backend.value["https_port"]
          priority    = backend.value["priority"]
          weight      = backend.value["weight"]
        }
      }
    }
  }

  #configuring routing rules for the FrontDoor service
  dynamic "routing_rule" {
    for_each = var.routing_rule
    content {
      name               = routing_rule.key
      accepted_protocols = routing_rule.value["accepted_protocols"]
      patterns_to_match  = routing_rule.value["patterns_to_match"]
      frontend_endpoints = routing_rule.value["frontend_endpoints"]
      dynamic "forwarding_configuration" {
        for_each = routing_rule.value["forwarding_configuration"]
        content {
          forwarding_protocol           = forwarding_configuration.value["forwarding_protocol"]
          backend_pool_name             = forwarding_configuration.value["backend_pool_name"]
          cache_enabled                 = forwarding_configuration.value["cache_enabled"]
          cache_use_dynamic_compression = forwarding_configuration.value["cache_use_dynamic_compression"]
        }
      }
    }
  }

  dynamic "routing_rule" {
    for_each = var.routing_rule_redirect
    content {
      name               = routing_rule.key
      accepted_protocols = routing_rule.value["accepted_protocols"]
      patterns_to_match  = routing_rule.value["patterns_to_match"]
      frontend_endpoints = routing_rule.value["frontend_endpoints"]
      dynamic "redirect_configuration" {
        for_each = routing_rule.value["redirect_configuration"]
        content {
          redirect_protocol = redirect_configuration.value["redirect_protocol"]
          redirect_type     = redirect_configuration.value["redirect_type"]
          custom_host       = redirect_configuration.value["custom_host"]
        }
      }
    }
  }

  #configuring loadbalancing rules & health probe for the FrontDoor Service
  backend_pool_load_balancing {
    name = var.fd_load_balancing_name
  }

  dynamic "backend_pool_health_probe" {
    for_each = var.backend_pool_health_probe
    content {
      name         = backend_pool_health_probe.key
      protocol     = backend_pool_health_probe.value["protocol"]
      probe_method = backend_pool_health_probe.value["probe_method"]
      path         = backend_pool_health_probe.value["path"]
    }
  }

  depends_on = [azurerm_frontdoor_firewall_policy.waf_policies]
}

#configuring frontend endpoints for custom domains within frontends in the FrontDoor Service
resource "azurerm_frontdoor_custom_https_configuration" "example_custom_https_false" {
  frontend_endpoint_id              = azurerm_frontdoor.frontdoor.frontend_endpoints[var.frontdoor_name]
  custom_https_provisioning_enabled = false

  depends_on = [azurerm_frontdoor.frontdoor]
}

resource "azurerm_frontdoor_custom_https_configuration" "example_custom_https_true" {
  for_each                          = var.azurerm_frontdoor_custom_https_configuration
  frontend_endpoint_id              = azurerm_frontdoor.frontdoor.frontend_endpoints[each.key]
  custom_https_provisioning_enabled = each.value["custom_https_provisioning_enabled"]

  custom_https_configuration {
    certificate_source = "FrontDoor"
  }

  depends_on = [azurerm_frontdoor.frontdoor]
}

#############################################################################################
# WAF logging 
#############################################################################################


resource "azurerm_monitor_diagnostic_setting" "fd-diag" {
  name                       = lower("${var.frontdoor_name}-diag")
  target_resource_id         = azurerm_frontdoor.frontdoor.id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.log.id

  dynamic "log" {
    for_each = var.fd_diag_logs
    content {
      category = log.value
      enabled  = true

      retention_policy {
        enabled = false
        days    = 0
      }
    }
  }

  metric {
    category = "AllMetrics"

    retention_policy {
      enabled = false
      days    = 0
    }
  }

  lifecycle {
    ignore_changes = [log, metric]
  }

  depends_on = [azurerm_frontdoor.frontdoor, data.azurerm_log_analytics_workspace.log, data.azurerm_resource_group.frontdoor]

}