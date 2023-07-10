output "app_service_plan_id" {
  value       = azurerm_app_service_plan.app_plan.id
  description = "The ID of the App Plan created"
}