terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      #Ensure this is set appropriately, based on the provider version used when constructing the module
      # IE ">=2.44.0" for "any version of 2.44.0 or above"
      version = "=3.1.0"
    }
  }
}

locals {
  #Generate name in format "AAA-B-CCCDD-EEE" where AAA = 3 character service code, B = 1 character environment letter, CCC = 3 character role code, DD = Padded 2 character number, EEE = 3 character environmnet short name
  vm_name_short = "${var.vm_name["service"]}-${var.vm_name["environment_letter"]}-${var.vm_name["role"]}${format("%02d", var.vm_name["vm_number"])}"
  vm_name_long  = "${var.vm_name["service"]}-${var.vm_name["environment_letter"]}-${var.vm_name["role"]}${format("%02d", var.vm_name["vm_number"])}-${var.vm_name["environment_short_name"]}"
}


/*
    START data providers
*/

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

data "azurerm_virtual_network" "vnet" {
  name                = var.vnet["name"]
  resource_group_name = var.vnet["resource_group_name"]
}

data "azurerm_key_vault" "key_vault" {
  name                = var.key_vault_name
  resource_group_name = var.resource_group_name
}

data "azurerm_subnet" "subnet" {
  name                 = var.nic_subnet_name
  resource_group_name  = var.vnet["resource_group_name"]
  virtual_network_name = var.vnet["name"]
}

/*
    END data providers
*/

/*
    START resource providers
*/

resource "random_id" "admin_username" {
  byte_length = 5
}

resource "random_id" "sql_username" {
  byte_length = 5
}

resource "random_password" "admin_password" {
  length  = 16
  special = true
}

resource "random_password" "sql_password" {
  length  = 16
  special = true
}

resource "azurerm_key_vault_secret" "admin_user" {
  name         = "${local.vm_name_short}-admin-username"
  value        = random_id.admin_username.hex
  key_vault_id = data.azurerm_key_vault.key_vault.id

  tags = var.tags

  depends_on = [data.azurerm_key_vault.key_vault]
}

resource "azurerm_key_vault_secret" "sql_user" {
  name         = "${local.vm_name_short}-sql-username"
  value        = random_id.sql_username.hex
  key_vault_id = data.azurerm_key_vault.key_vault.id

  tags = var.tags

  depends_on = [data.azurerm_key_vault.key_vault]
}

resource "azurerm_key_vault_secret" "admin_user_password" {
  name         = "${local.vm_name_short}-admin-password"
  value        = random_password.admin_password.result
  key_vault_id = data.azurerm_key_vault.key_vault.id

  #Ignore changes to the key vault password value - password rotation should be handled by another process
  lifecycle {
    ignore_changes = [
      value
    ]
  }

  tags = var.tags

  depends_on = [data.azurerm_key_vault.key_vault]
}

resource "azurerm_key_vault_secret" "sql_user_password" {
  name         = "${local.vm_name_short}-sql-password"
  value        = random_password.sql_password.result
  key_vault_id = data.azurerm_key_vault.key_vault.id

  #Ignore changes to the key vault password value - password rotation should be handled by another process
  lifecycle {
    ignore_changes = [
      value
    ]
  }

  tags = var.tags

  depends_on = [data.azurerm_key_vault.key_vault]
}


resource "azurerm_network_interface" "nic" {
  name                = "nic-${local.vm_name_short}"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = var.tags

  depends_on = [data.azurerm_subnet.subnet]
}

resource "azurerm_windows_virtual_machine" "vm" {
  name                = var.vm_name["environment_short_name"] != "" ? "vm-${local.vm_name_long}" : "vm-${local.vm_name_short}"
  computer_name       = var.vm_name["environment_short_name"] != "" ? local.vm_name_long : local.vm_name_short
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  size                = var.virtual_machine_size
  admin_username      = random_id.admin_username.hex
  admin_password      = random_password.admin_password.result
  network_interface_ids = [
    azurerm_network_interface.nic.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.os_storage_account_type
  }


  source_image_reference {
    publisher = var.source_image_reference["publisher"]
    offer     = var.source_image_reference["offer"]
    sku       = var.source_image_reference["sku"]
    version   = var.source_image_reference["version"]
  }

  lifecycle {
    ignore_changes = [
      admin_password
    ]
  }

  tags = var.tags

  depends_on = [data.azurerm_resource_group.rg]
}

resource "azurerm_managed_disk" "disks" {
  count = length(var.vm_disks)

  name                 = "vm-${local.vm_name_short}-${count.index}"
  resource_group_name  = data.azurerm_resource_group.rg.name
  location             = data.azurerm_resource_group.rg.location
  storage_account_type = var.vm_disks[count.index]["storage_account_type"]
  create_option        = "Empty"
  disk_size_gb         = var.vm_disks[count.index]["disk_size_gb"]

  tags = var.tags

  depends_on = [data.azurerm_resource_group.rg]
}

resource "azurerm_virtual_machine_data_disk_attachment" "disk-attach" {
  count = length(var.vm_disks)

  managed_disk_id    = element(azurerm_managed_disk.disks.*.id, count.index)
  virtual_machine_id = azurerm_windows_virtual_machine.vm.id
  lun                = var.vm_disks[count.index]["lun"]
  caching            = "ReadWrite"

  depends_on = [azurerm_managed_disk.disks, azurerm_windows_virtual_machine.vm]
}


resource "azurerm_mssql_virtual_machine" "sql" {
  virtual_machine_id               = azurerm_windows_virtual_machine.vm.id
  sql_license_type                 = "PAYG"
  r_services_enabled               = true
  sql_connectivity_port            = 1433
  sql_connectivity_type            = "PRIVATE"
  sql_connectivity_update_password = random_password.sql_password.result
  sql_connectivity_update_username = random_id.sql_username.hex

  storage_configuration {
    disk_type             = "NEW"
    storage_workload_type = "GENERAL"

    data_settings {
      default_file_path = "F:\\MSSQL\\Data"
      luns              = [0]
    }

    log_settings {
      default_file_path = "G:\\MSSQL\\Logs"
      luns              = [1]
    }

    temp_db_settings {
      default_file_path = "D:\\TempDb"
      luns              = []
    }
  }

  auto_patching {
    day_of_week                            = "Sunday"
    maintenance_window_duration_in_minutes = 60
    maintenance_window_starting_hour       = 2
  }

  depends_on = [azurerm_managed_disk.disks, azurerm_windows_virtual_machine.vm, azurerm_virtual_machine_data_disk_attachment.disk-attach]

}




###############################################
## Join Domain
###############################################

resource "azurerm_virtual_machine_extension" "join-domain" {

  count                = var.join_domain ? 1 : 0
  name                 = "join-domain"
  virtual_machine_id   = azurerm_windows_virtual_machine.vm.id
  publisher            = "Microsoft.Compute"
  type                 = "JsonADDomainExtension"
  type_handler_version = "1.3"

  settings = <<SETTINGS
{
    "Name": "${var.active_directory_domain}",
    "OUPath": "${var.oupath}",
    "User": "${var.active_directory_netbios_domain}\\${var.active_directory_username}",
    "Restart": "true",
    "Options": "3"
}
SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
    {
        "Password": "${var.active_directory_password}"
    }   
PROTECTED_SETTINGS

  tags = var.tags

  depends_on = [azurerm_windows_virtual_machine.vm]
}






/*
    END resource providers
*/
