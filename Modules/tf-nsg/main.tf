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

# create nsg
resource "azurerm_network_security_group" "nsg" {
  name                = var.nsg_name
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  # dynamic block to create additonal "non default" rules 
  dynamic "security_rule" {

    for_each = var.security_rules
    content {
      name                       = security_rule.key
      priority                   = security_rule.value["priority"]
      direction                  = security_rule.value["direction"]
      access                     = security_rule.value["access"]
      protocol                   = security_rule.value["protocol"]
      source_port_range          = security_rule.value["source_port_range"]
      destination_port_range     = security_rule.value["destination_port_range"]
      source_address_prefix      = security_rule.value["source_address_prefix"]
      destination_address_prefix = security_rule.value["destination_address_prefix"]
    }

  }

  # default rules that should be applied to every NSG
  security_rule {
    name                       = "Allow_Bastion"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["3389", "22"]
    source_address_prefix      = var.bastion_subnet
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow_SMB"
    priority                   = 4092
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "445"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }


  security_rule {
    name                         = "Allow_DCs"
    priority                     = 4093
    direction                    = "Outbound"
    access                       = "Allow"
    protocol                     = "Tcp"
    source_port_range            = "*"
    destination_port_range       = "*"
    source_address_prefix        = "*"
    destination_address_prefixes = ["10.80.0.133", "10.80.1.133"]
  }


  security_rule {
    name                       = "Allow_SolarWinds"
    priority                   = 4094
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "10.1.1.134"
  }

  security_rule {
    name                       = "Allow_VNet"
    priority                   = 4095
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = var.hosts_subnet
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Deny_All"
    priority                   = 4096
    direction                  = "Outbound"
    access                     = "Deny"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}