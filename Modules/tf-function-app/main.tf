terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.92.0"
    }
  }
}

################### data providers #################################################

# get resource group to deploy to
data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

data "azurerm_storage_account" "storage" {
  name                = var.storage_account_name
  resource_group_name = var.resource_group_name
}

################### resource providers #############################################


resource "azurerm_app_service_plan" "app_plan" {
  name                = var.app_plan_name
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  sku {
    tier = var.app_plan_tier
    size = var.app_plan_size
  }

  depends_on = [data.azurerm_resource_group.rg]
}

resource "azurerm_function_app" "function" {
  name                       = var.function_app_name
  location                   = data.azurerm_resource_group.rg.location
  resource_group_name        = data.azurerm_resource_group.rg.name
  app_service_plan_id        = azurerm_app_service_plan.app_plan.id
  storage_account_name       = data.azurerm_storage_account.storage.name
  storage_account_access_key = data.azurerm_storage_account.storage.primary_access_key
  https_only                 = true

  depends_on = [azurerm_app_service_plan.app_plan, data.azurerm_resource_group.rg, data.azurerm_storage_account.storage]

}