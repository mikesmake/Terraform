# vmware-vm

## Purpose

This module is used to manage an vmware-based Virtual machine

## Usage

Use this module to manage a vmware-based virtual machine as part of a larger composition.

### Examples

### Windows VM with two additional 100gb disks

```module "vm" {
  source                = "./vm"
  datastore_name        = "Prod-Gen-01"
  vm_name               = "Terraform-Test-VM"
  ip_address            = "10.8.134.37"
  local_admin_password  = "SomethingRealllyStrong11!"
  domain_admin_password = var.domain_pass
  domain_admin_user     = "exandrews"


  disks = {
    Terraform-Test-VM_1 = {
      size       = "100"
      disknumber = "1"
    },
    Terraform-Test-VM_2 = {
      size       = "100"
      disknumber = "2"
    }
  }
}

```

## External Dependencies

1. An exsiting vcenter with datacenter, datastore, cluster etc.
