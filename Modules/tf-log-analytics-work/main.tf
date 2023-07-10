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

# get resource group to deploy to
data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

#############################################################################################
# resource providers
#############################################################################################

resource "azurerm_log_analytics_workspace" "law" {
  name                = var.law_name
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  sku                 = var.law_sku

  depends_on = [data.azurerm_resource_group.rg]
}