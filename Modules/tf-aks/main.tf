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


################### resource providers #############################################

resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.kubernetes_cluster_name
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  dns_prefix          = var.kubernetes_cluster_dns_prefix

  default_node_pool {
    name       = var.default_node_pool_name
    node_count = var.default_node_count
    vm_size    = var.deault_node_VM_Size
  }

  identity {
    type = var.indentity_type
  }

  depends_on = [data.azurerm_resource_group.rg]

}