###################################################################################################
# Providers
###################################################################################################

terraform {
  required_providers {
    azurerm = {
      source                = "hashicorp/azurerm"
      version               = "=2.92.0"
      configuration_aliases = [azurerm.hub, azurerm.spoke] # An alias is created for both the "hub" and the "spoke" VNETs 
    }
  }
}

###################################################################################################
# Data Providers
###################################################################################################


data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

# Gets the "hub" VNET ready for peering. These values are hard coded are there is only 1 "hub".
data "azurerm_virtual_network" "hub" {
  provider            = azurerm.hub
  name                = "vnet-prod-uks-hub-01"
  resource_group_name = "rg-networking"
}


###################################################################################################
# VNET
###################################################################################################


# Create vnet
resource "azurerm_virtual_network" "vnet" {
  provider            = azurerm.spoke
  name                = var.vnet_name
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  address_space       = var.address_space
  dns_servers         = var.dns_servers
}

# Create subnet within VNET created above (multiple subnets can be created by passing in multiple values)
resource "azurerm_subnet" "subnet" {
  provider = azurerm.spoke
  for_each = var.subnets

  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name

  name             = each.key
  address_prefixes = each.value["address_prefix"]

  # Delegation has to be declared but can be left blank if not required. This is to allow subnet delegation for resources like web apps
  dynamic "delegation" {
    for_each = length(each.value.delegation_name) > 0 ? [1] : []

    content {
      name = "delegation"

      service_delegation {
        name = each.value.delegation_name
      }
    }
  }

  depends_on = [azurerm_virtual_network.vnet]
}


###################################################################################################
# Peering
###################################################################################################


# Create a peering link from spoke to hub 
resource "azurerm_virtual_network_peering" "vnet-hub" {
  provider                  = azurerm.spoke
  name                      = format("peer-%s--vnet-prod-uks-hub-01", var.vnet_name)
  resource_group_name       = data.azurerm_resource_group.rg.name
  virtual_network_name      = azurerm_virtual_network.vnet.name
  remote_virtual_network_id = data.azurerm_virtual_network.hub.id
  use_remote_gateways       = true
  allow_forwarded_traffic   = true
}

# Create a peering link from hub to spoke
resource "azurerm_virtual_network_peering" "hub-vnet" {
  provider                  = azurerm.hub
  name                      = format("peer-vnet-prod-uks-hub-01--%s", var.vnet_name)
  resource_group_name       = "rg-networking"
  virtual_network_name      = data.azurerm_virtual_network.hub.name
  remote_virtual_network_id = azurerm_virtual_network.vnet.id
  allow_forwarded_traffic   = true
  allow_gateway_transit     = true
}

###################################################################################################
# NSG Association 
###################################################################################################

resource "azurerm_subnet_network_security_group_association" "vnet" {
  for_each                  = var.subnets
  subnet_id                 = azurerm_subnet.subnet[each.key].id
  network_security_group_id = var.nsg_id
}