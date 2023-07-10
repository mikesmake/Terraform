output "ip_address" {
  value       = azurerm_lb.nlb.private_ip_address
  description = "The first IP asssigned to the front end"
}

output "frontend_ip_configuration_id" {
  value       = [azurerm_lb.nlb.frontend_ip_configuration.0.id]
  description = "front end id"
}
