  backend "azurerm" {
    resource_group_name   = "core"
    storage_account_name  = "terrastatemike"
    container_name        = "tstate"
    key                   = "tN5yHfDanFeBHa8xtX5nkWRN7KcrwuKotryYvdZs7jXZqSDpj9YwZjf59zamzVp5bFZYcNHUz/TAsWHMblhcQg=="
}

terraform {
  required_providers {
    azurerm = {
      # Specify what version of the provider we are going to utilise
      source = "hashicorp/azurerm"
      version = ">= 2.4.1"
    }
  }
}
provider "azurerm" {
  features {
      key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}
data "azurerm_client_config" "current" {}
# Create our Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "var.name-app01"
  location = "UK South"
}
# Create our Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "var.name-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}
# Create our Subnet to hold our VM - Virtual Machines
resource "azurerm_subnet" "sn" {
  name                 = "VM"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes       = ["10.0.1.0/24"]
}
# Create our Azure Storage Account
resource "azurerm_storage_account" "whereisthis" {
  name                     = "var.name"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
# Create our vNIC for our VM and assign it to our Virtual Machines Subnet
resource "azurerm_network_interface" "vmnic" {
  name                = "var.namevm01nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.sn.id
    private_ip_address_allocation = "Dynamic"
  }
}
# Create our Virtual Machine - Jonnychipz-VM01
resource "azurerm_virtual_machine" "VMWhere" {
  name                  = "var.name-vm01"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.vmnic.id]
  vm_size               = "Standard_B2s"
  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter-Server-Core-smalldisk"
    version   = "latest"
  }
  storage_os_disk {
    name              = "var.namevm01os"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name      = "var.namevm01"
    admin_username     = "Mike"
    admin_password     = "StrongPass1"
  }
  os_profile_windows_config {
  }
}