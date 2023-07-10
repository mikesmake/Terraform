############ terraform providers #########################

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.1.0"
    }
  }
}

############## data providers ###########################

# get resource group 
data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}


############## resource providers #######################


############## Create Analysis Services #################

resource "azurerm_analysis_services_server" "analysis_server" {
  name                    = var.analysis_server_name
  location                = var.location
  resource_group_name     = data.azurerm_resource_group.rg.name
  sku                     = var.analysis_server_sku
  admin_users             = [var.analysis_server_admin]
  enable_power_bi_service = true

    ipv4_firewall_rule {
    name        = "MPSOfficeIP"
    range_start = "195.88.236.97"
    range_end   = "195.88.236.97"
  }
  tags = var.tags
}