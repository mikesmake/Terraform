terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.30.0"
    }
  }
}

#To get the current session details
data "azurerm_client_config" "current" {}

#Creates a data reference for the target resource group
data "azurerm_resource_group" "resource_group" {
  name = var.resource_group_name
}

#Creates a CDN profile for CDN resource
resource "azurerm_cdn_profile" "cdn_profile" {
  name                = var.cdn_profile_name
  location            = "northeurope"
  resource_group_name = data.azurerm_resource_group.resource_group.name
  sku                 = var.sku

  depends_on = [data.azurerm_resource_group.resource_group]
}

#Creates a CDN endpoint for CDN resource
resource "azurerm_cdn_endpoint" "cdn_endpoint" {
  name                = var.cdn_endpoint_name
  profile_name        = azurerm_cdn_profile.cdn_profile.name
  location            = "northeurope"
  resource_group_name = data.azurerm_resource_group.resource_group.name
  origin_host_header  = var.origin_host_name

  origin {
    name      = var.origin_name
    host_name = var.origin_host_name
  }

  depends_on = [data.azurerm_resource_group.resource_group, azurerm_cdn_profile.cdn_profile]
}