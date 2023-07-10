# Set out the output variables
output "cdn_profile_name" {
  value       = azurerm_cdn_profile.cdn_profile.name
  description = "CDN Profile Name"
}

output "cdn_endpoint_name" {
  value       = azurerm_cdn_endpoint.cdn_endpoint.name
  description = "CDN Profile Name"
}

output "origin_host_name" {
  value       = azurerm_cdn_endpoint.cdn_endpoint.origin
  description = "Origin Host Name"
}