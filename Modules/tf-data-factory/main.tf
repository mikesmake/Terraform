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

############## Create Data Factory #################
resource "azurerm_data_factory" "data_factory" {
  name                = var.data_factory_name
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg.name

tags = var.tags
}