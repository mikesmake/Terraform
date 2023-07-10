terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.30.0"
    }
  }
}

#############################################################################################
# Data
#############################################################################################

data "azurerm_subnet" "subnet" {
  name                 = var.subnet_name
  virtual_network_name = var.vnet_name
  resource_group_name  = var.vnet_resource_group
}


#############################################################################################
# Network Load Balancer
#############################################################################################

resource "azurerm_lb" "nlb" {
  name                = var.nlb_name
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"

  frontend_ip_configuration {
    name      = var.front_end_name
    subnet_id = data.azurerm_subnet.subnet.id


  }
}

#############################################################################################
# Backend Pool
#############################################################################################

resource "azurerm_lb_backend_address_pool" "backpool" {
  loadbalancer_id = azurerm_lb.nlb.id
  name            = var.backend_pool_name

  depends_on = [azurerm_lb.nlb]
}

#############################################################################################
# Backend Pool Objects
#############################################################################################

resource "azurerm_network_interface_backend_address_pool_association" "VMLink" {

  for_each = var.back_end_vms

  network_interface_id    = each.value["nic_id"]
  ip_configuration_name   = "internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.backpool.id

  depends_on = [azurerm_lb_backend_address_pool.backpool]

}

#############################################################################################
# Health Probe
#############################################################################################

resource "azurerm_lb_probe" "healthprobe" {
  loadbalancer_id = azurerm_lb.nlb.id
  name            = var.health_probe_name
  port            = var.health_probe_port

  depends_on = [azurerm_lb.nlb]

}

#############################################################################################
# Routing Rule
#############################################################################################

resource "azurerm_lb_rule" "nlbrule" {
  loadbalancer_id                = azurerm_lb.nlb.id
  name                           = var.rule_name
  protocol                       = var.rule_protocol
  frontend_port                  = var.frontend_port
  backend_port                   = var.backend_port
  frontend_ip_configuration_name = var.front_end_name
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.backpool.id]
  probe_id                       = azurerm_lb_probe.healthprobe.id

  depends_on = [azurerm_lb_probe.healthprobe, azurerm_lb.nlb, azurerm_lb_backend_address_pool.backpool]

}
