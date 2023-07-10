###################################################################################################
# Environment 
###################################################################################################

terraform {
  backend "azurerm" {
  }
}

provider "vsphere" {
  user                 = var.vsphere_user
  password             = var.vsphere_password
  vsphere_server       = ""
  allow_unverified_ssl = true
}

###################################################################################################
# Resources
###################################################################################################

module "vm" {
  for_each              = var.vms
  source                = "./vm"
  datastore_name        = "Prod-Gen-01"
  vm_name               = each.value.vm_name
  ip_address            = each.value.ip_address
  cpus                  = 2
  cores                 = 2
  memory                = 4096
  local_admin_password  = var.local_adminpass
  domain_admin_password = var.domain_admin_password
  domain_admin_user     = var.domain_admin_user
  disks                 = each.value.disks
  folder_name           = "Azure DevOps Agents"
}
