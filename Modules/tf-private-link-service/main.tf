terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.30.0"
    }
  }
}


#############################################################################################
# resource providers
#############################################################################################

resource "azurerm_private_link_service" "pls" {
  name                = var.pls_name
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location

  auto_approval_subscription_ids              = var.approved_subscription_id
  visibility_subscription_ids                 = var.approved_subscription_id
  load_balancer_frontend_ip_configuration_ids = var.nlb_id

  nat_ip_configuration {
    name                       = "primary"
    private_ip_address_version = "IPv4"
    subnet_id                  = var.subnet_id
    primary                    = true
  }

  tags = var.tags
}
