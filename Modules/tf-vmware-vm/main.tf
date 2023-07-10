terraform {
  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere"
      version = "2.2.0"
    }
  }
}

###################################################################################################
# data blocks
###################################################################################################

data "vsphere_datacenter" "datacenter" {
  name = var.datacenter_name
}

data "vsphere_datastore" "datastore" {
  name          = var.datastore_name
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_compute_cluster" "cluster" {
  name          = var.cluster_name
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_network" "network" {
  name          = var.network_name
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_virtual_machine" "template" {
  name          = var.template_name
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

###################################################################################################
# vSphere Resources
###################################################################################################


resource "vsphere_virtual_machine" "vm" {
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id
  guest_id         = data.vsphere_virtual_machine.template.guest_id

  name                 = var.vm_name
  folder               = var.folder_name
  memory               = var.memory
  num_cpus             = var.cpus
  num_cores_per_socket = var.cores
  annotation           = "Deployed Via Terraform"
  scsi_type            = data.vsphere_virtual_machine.template.scsi_type

  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = "vmxnet3"
  }

  # C Drive
  disk {
    label            = var.vm_name
    size             = data.vsphere_virtual_machine.template.disks.0.size
    eagerly_scrub    = data.vsphere_virtual_machine.template.disks.0.eagerly_scrub
    thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
  }

  # Secondary disk loops
  dynamic "disk" {
    for_each = var.disks
    content {
      label       = "${var.vm_name}_${disk.value["disknumber"]}"
      size        = disk.value["size"]
      unit_number = disk.value["disknumber"]
    }
  }


  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
    customize {
      windows_options {
        computer_name = var.vm_name
        # workgroup     = "test"
        join_domain           = "intra.mps-group.org"
        domain_admin_user     = var.domain_admin_user
        domain_admin_password = var.domain_admin_password
        admin_password        = var.local_admin_password
        # product_key           = var.productkey
        # organization_name     = var.orgname
        # run_once_command_list = var.run_once
        # auto_logon            = var.auto_logon
        # auto_logon_count      = var.auto_logon_count
        # time_zone             = var.time_zone
        # product_key           = var.productkey
        # full_name             = var.full_name
      }
      network_interface {
        ipv4_address    = var.ip_address
        ipv4_netmask    = var.ip_address_netmask
        dns_server_list = ["10.8.130.251"]
        dns_domain      = "intra.mps-group.org"
      }
      ipv4_gateway = var.ipv4_gateway
      timeout      = 30

    }
  }
}
