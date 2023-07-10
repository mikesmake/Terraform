# Set out the output variables
output "FrontdoorName" {
  value       = azurerm_frontdoor.frontdoor.name
  description = "The frontdoor name"
}

output "FrontdoorEndpointName" {
  value       = azurerm_frontdoor.frontdoor.frontend_endpoint[0]
  description = "The Frontdoor endpoint name"
}

/*output "FrontdoorWafPolicyName" {
  value = azurerm_frontdoor_firewall_policy.wafpolicy.name
  description = "The Frontdoor waf policy name"
}*/