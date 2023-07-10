terraform {
  required_providers {
    azurerm = {
      source                = "hashicorp/azurerm"
      version               = "=3.30.0"
      configuration_aliases = [azurerm.hub, azurerm.spoke] # An alias is created for both the "hub" and the "spoke" VNETs 
    }
  }
}

#############################################################################################
# data providers
#############################################################################################

data "azurerm_resource_group" "rg" {
  provider = azurerm.spoke
  name     = var.resource_group_name
}

data "azurerm_log_analytics_workspace" "log" {
  provider            = azurerm.spoke
  name                = var.log_analytics_workpace_name
  resource_group_name = var.log_analytics_workpace_rg
}

data "azurerm_dns_zone" "zone" {
  provider            = azurerm.hub
  name                = var.dns_zone_name
  resource_group_name = var.dns_zone_resource_group
}

data "azurerm_dns_zone" "dental_zone" {
  count               = var.create_dental_site ? 1 : 0
  provider            = azurerm.hub
  name                = var.dental_dns_zone_name
  resource_group_name = var.dns_zone_resource_group
}


#############################################################################################
# resource providers
#############################################################################################


#############################################################################################
# Profile (Front Door)
#############################################################################################

resource "azurerm_cdn_frontdoor_profile" "profile" {
  provider            = azurerm.spoke
  name                = var.frontdoor_name
  resource_group_name = data.azurerm_resource_group.rg.name
  sku_name            = "Premium_AzureFrontDoor"

  tags = var.tags

  depends_on = [data.azurerm_resource_group.rg]

}

#############################################################################################
# Origin Group (Backend)
#############################################################################################

resource "azurerm_cdn_frontdoor_origin_group" "origin_group" {
  provider                 = azurerm.spoke
  name                     = "origingroup1"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.profile.id

  load_balancing {}

  depends_on = [data.azurerm_resource_group.rg, azurerm_cdn_frontdoor_profile.profile]
}

resource "azurerm_cdn_frontdoor_origin_group" "dental_origin_group" {
  provider                 = azurerm.spoke
  count                    = var.create_dental_site ? 1 : 0
  name                     = "origingroup2"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.profile.id

  load_balancing {}

  depends_on = [data.azurerm_resource_group.rg, azurerm_cdn_frontdoor_profile.profile]
}

#############################################################################################
# Origin (Backend Objects)
#############################################################################################

resource "azurerm_cdn_frontdoor_origin" "origin" {
  provider                      = azurerm.spoke
  name                          = var.origin_name
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.origin_group.id

  health_probes_enabled          = true
  certificate_name_check_enabled = true
  host_name                      = var.host_name
  origin_host_header             = var.host_header
  priority                       = 1
  weight                         = 500

  private_link {
    request_message        = "Please accept this link request"
    location               = var.resource_group_location
    private_link_target_id = var.private_link_target_id
  }

  depends_on = [data.azurerm_resource_group.rg, azurerm_cdn_frontdoor_origin_group.origin_group]
}

resource "azurerm_cdn_frontdoor_origin" "dental_origin" {
  provider                      = azurerm.spoke
  name                          = var.origin_name
  count                         = var.create_dental_site ? 1 : 0
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.dental_origin_group[0].id

  health_probes_enabled          = true
  certificate_name_check_enabled = true
  host_name                      = var.host_name
  origin_host_header             = var.dental_host_header
  priority                       = 1
  weight                         = 500

  private_link {
    request_message        = "Please accept this link request"
    location               = var.resource_group_location
    private_link_target_id = var.private_link_target_id
  }

  depends_on = [data.azurerm_resource_group.rg, azurerm_cdn_frontdoor_origin_group.dental_origin_group]
}

#############################################################################################
# Endpoint (Front End)
#############################################################################################

resource "azurerm_cdn_frontdoor_endpoint" "endpoint" {
  provider                 = azurerm.spoke
  name                     = var.endpoint_name
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.profile.id

  depends_on = [data.azurerm_resource_group.rg, azurerm_cdn_frontdoor_profile.profile]
}


#############################################################################################
# DNS
#############################################################################################


resource "azurerm_dns_cname_record" "dns" {
  provider            = azurerm.hub
  name                = "${var.environment_short_name}${var.service}"
  zone_name           = data.azurerm_dns_zone.zone.name
  resource_group_name = data.azurerm_dns_zone.zone.resource_group_name
  ttl                 = 3600
  record              = azurerm_cdn_frontdoor_endpoint.endpoint.host_name

  depends_on = [azurerm_cdn_frontdoor_route.route]

}

resource "azurerm_dns_cname_record" "dental_dns" {
  count               = var.create_dental_site ? 1 : 0
  provider            = azurerm.hub
  name                = "${var.environment_short_name}${var.service}"
  zone_name           = data.azurerm_dns_zone.dental_zone[0].name
  resource_group_name = data.azurerm_dns_zone.dental_zone[0].resource_group_name
  ttl                 = 3600
  record              = azurerm_cdn_frontdoor_endpoint.endpoint.host_name

  depends_on = [azurerm_cdn_frontdoor_route.route]

}

resource "azurerm_dns_a_record" "dns-internal" {
  provider            = azurerm.hub
  name                = "${var.environment_short_name}${var.service}-internal"
  zone_name           = data.azurerm_dns_zone.zone.name
  resource_group_name = data.azurerm_dns_zone.zone.resource_group_name
  ttl                 = 3600
  records             = var.nlb_frontend_ip

  depends_on = [azurerm_cdn_frontdoor_route.route]

}

resource "azurerm_dns_txt_record" "dnstxt" {
  provider            = azurerm.hub
  name                = "_dnsauth.${var.environment_short_name}${var.service}"
  zone_name           = data.azurerm_dns_zone.zone.name
  resource_group_name = data.azurerm_dns_zone.zone.resource_group_name
  ttl                 = 3600

  record {
    value = azurerm_cdn_frontdoor_custom_domain.domain.validation_token
  }

  depends_on = [azurerm_cdn_frontdoor_custom_domain.domain]
}

resource "azurerm_dns_txt_record" "dental_dnstxt" {
  count               = var.create_dental_site ? 1 : 0
  provider            = azurerm.hub
  name                = "_dnsauth.${var.environment_short_name}${var.service}"
  zone_name           = data.azurerm_dns_zone.dental_zone[0].name
  resource_group_name = data.azurerm_dns_zone.dental_zone[0].resource_group_name
  ttl                 = 3600

  record {
    value = azurerm_cdn_frontdoor_custom_domain.dental_domain[0].validation_token
  }

  depends_on = [azurerm_cdn_frontdoor_custom_domain.dental_domain]
}

#############################################################################################
# Custom Domain (Front End Object)
#############################################################################################


resource "azurerm_cdn_frontdoor_custom_domain" "domain" {
  provider                 = azurerm.spoke
  name                     = "customDomain"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.profile.id
  dns_zone_id              = data.azurerm_dns_zone.zone.id
  host_name                = "${var.environment_short_name}${lower(var.service)}.${data.azurerm_dns_zone.zone.name}"

  #associate_with_cdn_frontdoor_route_id = azurerm_cdn_frontdoor_route.route.id

  tls {
    certificate_type    = "ManagedCertificate"
    minimum_tls_version = "TLS12"
  }

  depends_on = [data.azurerm_resource_group.rg, azurerm_cdn_frontdoor_profile.profile]
}

resource "azurerm_cdn_frontdoor_custom_domain_association" "domain_assoc" {
  count                          = var.create_dental_site ? 1 : 0
  cdn_frontdoor_custom_domain_id = azurerm_cdn_frontdoor_custom_domain.domain.id
  cdn_frontdoor_route_ids        = [azurerm_cdn_frontdoor_route.route.id]
}

resource "azurerm_cdn_frontdoor_custom_domain" "dental_domain" {
  count                    = var.create_dental_site ? 1 : 0
  provider                 = azurerm.spoke
  name                     = "customDomaindental"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.profile.id
  dns_zone_id              = data.azurerm_dns_zone.dental_zone[0].id
  host_name                = "${var.environment_short_name}${lower(var.service)}.${data.azurerm_dns_zone.dental_zone[0].name}"

  #associate_with_cdn_frontdoor_route_id = azurerm_cdn_frontdoor_route.dental_route[0].id

  tls {
    certificate_type    = "ManagedCertificate"
    minimum_tls_version = "TLS12"
  }

  depends_on = [data.azurerm_resource_group.rg, azurerm_cdn_frontdoor_profile.profile]
}

resource "azurerm_cdn_frontdoor_custom_domain_association" "dental_domain_assoc" {
  count                          = var.create_dental_site ? 1 : 0
  cdn_frontdoor_custom_domain_id = azurerm_cdn_frontdoor_custom_domain.dental_domain[0].id
  cdn_frontdoor_route_ids        = [azurerm_cdn_frontdoor_route.dental_route[0].id]
}


#############################################################################################
# Route
#############################################################################################


resource "azurerm_cdn_frontdoor_route" "route" {
  name                          = "route1"
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.endpoint.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.origin_group.id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.origin.id]
  enabled                       = true
  link_to_default_domain        = false

  cdn_frontdoor_custom_domain_ids = [azurerm_cdn_frontdoor_custom_domain.domain.id]

  forwarding_protocol    = "HttpsOnly"
  https_redirect_enabled = true
  patterns_to_match      = ["/*"]
  supported_protocols    = ["Http", "Https"]

  cache {
    query_string_caching_behavior = "IgnoreSpecifiedQueryStrings"
    query_strings                 = ["account", "settings"]
    compression_enabled           = true
    content_types_to_compress     = ["text/html", "text/javascript", "text/xml"]
  }

  depends_on = [data.azurerm_resource_group.rg, azurerm_cdn_frontdoor_origin_group.origin_group, azurerm_cdn_frontdoor_origin.origin, azurerm_cdn_frontdoor_endpoint.endpoint]

}



resource "azurerm_cdn_frontdoor_route" "dental_route" {
  name                          = "route2"
  count                         = var.create_dental_site ? 1 : 0
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.endpoint.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.dental_origin_group[0].id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.dental_origin[0].id]
  enabled                       = true
  link_to_default_domain        = false

  cdn_frontdoor_custom_domain_ids = [azurerm_cdn_frontdoor_custom_domain.dental_domain[0].id]

  forwarding_protocol    = "MatchRequest"
  https_redirect_enabled = true
  patterns_to_match      = ["/*"]
  supported_protocols    = ["Http", "Https"]

  cache {
    query_string_caching_behavior = "IgnoreSpecifiedQueryStrings"
    query_strings                 = ["account", "settings"]
    compression_enabled           = true
    content_types_to_compress     = ["text/html", "text/javascript", "text/xml"]
  }

  depends_on = [data.azurerm_resource_group.rg, azurerm_cdn_frontdoor_origin_group.dental_origin_group, azurerm_cdn_frontdoor_origin.dental_origin, azurerm_cdn_frontdoor_endpoint.endpoint, azurerm_cdn_frontdoor_custom_domain.dental_domain]

}



#############################################################################################
# WAF logging 
#############################################################################################


resource "azurerm_monitor_diagnostic_setting" "fd-diag" {
  provider                   = azurerm.spoke
  name                       = lower("${var.frontdoor_name}-diag")
  target_resource_id         = azurerm_cdn_frontdoor_profile.profile.id
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

  depends_on = [data.azurerm_log_analytics_workspace.log, data.azurerm_resource_group.rg, azurerm_cdn_frontdoor_origin_group.origin_group]

}
