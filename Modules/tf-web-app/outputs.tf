# Set out the output variables
output "WebAppName" {
  value       = azurerm_windows_web_app.appsvc.name
  description = "The web app name"
}

output "WebAppId" {
  value       = azurerm_windows_web_app.appsvc.id
  description = "The web app id"
}

output "WebAppSlotName" {
  value       = azurerm_windows_web_app_slot.appsvcslot.name
  description = "The web app slot name"
}

output "WebAppSlotId" {
  value       = azurerm_windows_web_app_slot.appsvcslot.id
  description = "The web app slot id"
}

output "WebAppAppInsightsName" {
  value       = var.create_app_insights ? azurerm_application_insights.appinsights[0].name : ""
  description = "The app insights name"
}

output "WebAppAppInsightsKey" {
  value       = var.create_app_insights ? azurerm_application_insights.appinsights[0].instrumentation_key : ""
  description = "The app insights instrumentation key"
}

output "WebappAppInsightsConnectionString" {
  value       = var.create_app_insights ? azurerm_application_insights.appinsights[0].connection_string : ""
  description = "The app insights connection string"
}

output "WebAppUrl" {
  value       = format("https://%s/signin-oidc", azurerm_windows_web_app.appsvc.default_hostname)
  description = "The web apps sign in url"
}

output "WebAppSlotUrl" {
  value       = format("https://%s/signin-oidc", azurerm_windows_web_app_slot.appsvcslot.default_hostname)
  description = "The web apps slot sign in url"
}

output "WebAppPrincipalId" {
  value       = azurerm_windows_web_app.appsvc.identity[0].principal_id
  description = "The web app principal id"
}

output "WebAppSlotPrincipalId" {
  value       = azurerm_windows_web_app_slot.appsvcslot.identity[0].principal_id
  description = "The web apps slot principal id"
}