###################################################################################################
# Environment
###################################################################################################

terraform {
  backend "azurerm" {
  }
}

provider "azurerm" {
  tenant_id       = var.tenant_id
  subscription_id = var.subscription_id[terraform.workspace]
  features {}
}

provider "azurerm" {
  alias           = "spoke"
  tenant_id       = var.tenant_id
  subscription_id = var.subscription_id[terraform.workspace]
  features {}
}

provider "azurerm" {
  alias           = "hub"
  tenant_id       = var.tenant_id
  subscription_id = var.hub_subscription_id
  features {}
}

locals {
  # Common tags to be assigned to all resources
  common_tags = {
    Deployment    = "Automatic"
    Configruation = "Automatic"
    Service       = "FYP"
    Project       = "Something"
    Owner         = "Application Team"
  }

  service = "FYP"
}


data "azurerm_subnet" "subnet" {
  name                 = "hosts"
  virtual_network_name = var.vm_vnet_name[terraform.workspace]
  resource_group_name  = var.vm_vnet_resource_group
}



###################################################################################################
# Resource Group
###################################################################################################

resource "azurerm_resource_group" "rg" {
  name     = "rg-${local.service}${lower(trimprefix(terraform.workspace, local.service))}"
  location = "UKSOUTH"

  tags = local.common_tags
}

###################################################################################################
# Key Vault
###################################################################################################

module "key_vault" {
  source                  = "./keyvault"
  resource_group_name     = azurerm_resource_group.rg.name
  resource_group_location = azurerm_resource_group.rg.location
  key_vault_name          = var.key_vault_name[terraform.workspace]

  tags = local.common_tags

  depends_on = [azurerm_resource_group.rg]
}

###################################################################################################
# Virtual Machine
###################################################################################################

module "vm" {
  source                  = "./vm"
  count                   = var.vm_count[terraform.workspace]
  resource_group_name     = azurerm_resource_group.rg.name
  resource_group_location = azurerm_resource_group.rg.location
  vnet_name               = var.vm_vnet_name[terraform.workspace]
  vnet_resource_group     = var.vm_vnet_resource_group
  nic_subnet_name         = var.nic_subnet_name
  kv_resource_group_name  = azurerm_resource_group.rg.name
  key_vault_name          = module.key_vault.key_vault_name
  service                 = local.service
  environment_letter      = var.environment_letter[terraform.workspace]
  role                    = "app"
  vm_number               = count.index + 1
  environment_short_name  = var.environment_short_name[terraform.workspace]

  virtual_machine_size = var.virtual_machine_size[terraform.workspace]
  source_image_reference = {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
  vm_disks = [
    {
      lun                  = 10
      storage_account_type = "StandardSSD_LRS"
      disk_size_gb         = 100
    }
  ]
  tags        = local.common_tags
  join_domain = false

  depends_on = [azurerm_resource_group.rg, module.key_vault]
}

###################################################################################################
# Network Load Balancer
###################################################################################################

module "nlb" {
  source                  = "./nlb"
  resource_group_name     = azurerm_resource_group.rg.name
  resource_group_location = azurerm_resource_group.rg.location
  vnet_name               = var.vnet_name[terraform.workspace]
  vnet_resource_group     = var.vnet_resource_group
  subnet_name             = var.nic_subnet_name
  nlb_name                = "nlb-${local.service}${lower(trimprefix(terraform.workspace, local.service))}"
  front_end_name          = "front_end-${local.service}${lower(trimprefix(terraform.workspace, local.service))}"
  backend_pool_name       = "back_end-${local.service}${lower(trimprefix(terraform.workspace, local.service))}"
  health_probe_port       = var.health_probe_port
  health_probe_name       = var.health_probe_name
  rule_name               = var.rule_name
  backend_port            = var.backend_port
  frontend_port           = var.frontend_port


  back_end_vms = {
    ipconfig = {
      nic_id = module.vm[0].virtual_machine_nic_id
    }
  }

  depends_on = [azurerm_resource_group.rg, module.vm]
}



###################################################################################################
# Private Link Service
###################################################################################################


module "private_link_service" {
  source                   = "./PrivateLink"
  resource_group_name      = azurerm_resource_group.rg.name
  resource_group_location  = azurerm_resource_group.rg.location
  pls_name                 = "pls-${local.service}${lower(trimprefix(terraform.workspace, local.service))}"
  approved_subscription_id = ["6f7e5f54-9ac7-4679-990d-d46315bdc1b6"]

  subnet_id = data.azurerm_subnet.subnet.id

  nlb_id = module.nlb.frontend_ip_configuration_id


  tags = local.common_tags

  depends_on = [azurerm_resource_group.rg, module.vm, module.nlb]
}

###################################################################################################
# Front Door & CDN
###################################################################################################


module "frontdoor" {
  source = "./FrontDoorCDN"
  providers = {
    azurerm.hub   = azurerm.hub
    azurerm.spoke = azurerm.spoke
  }
  dns_zone_name           = var.dns_zone_name[terraform.workspace]
  dns_zone_resource_group = "rg-dns-prod"

  resource_group_name         = azurerm_resource_group.rg.name
  resource_group_location     = azurerm_resource_group.rg.location
  frontdoor_name              = "fd-${local.service}${lower(trimprefix(terraform.workspace, local.service))}"
  origin_name                 = "origin-${local.service}${lower(trimprefix(terraform.workspace, local.service))}"
  nlb_ip                      = module.nlb.ip_address
  host_name                   = var.host_name[terraform.workspace]
  host_header                 = var.host_header[terraform.workspace]
  dental_host_header          = var.dental_host_header[terraform.workspace]
  private_link_target_id      = module.private_link_service.id
  endpoint_name               = "endpoint-${local.service}${lower(trimprefix(terraform.workspace, local.service))}"
  log_analytics_workpace_rg   = var.log_analytics_workpace_rg
  log_analytics_workpace_name = var.log_analytics_workpace_name[terraform.workspace]
  environment_short_name      = var.environment_short_name[terraform.workspace]
  service                     = local.service
  tags                        = local.common_tags
  nlb_frontend_ip             = tolist([module.nlb.ip_address])
  create_dental_site          = true
  dental_dns_zone_name        = var.dental_dns_zone_name[terraform.workspace]


  depends_on = [module.private_link_service, azurerm_resource_group.rg]

}
