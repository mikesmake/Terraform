variable "vsphere_user" {
  type = string
}

variable "vsphere_password" {
  type = string
}

variable "domain_admin_user" {
  type = string
}

variable "domain_admin_password" {
  type = string
}

variable "local_adminpass" {
  type = string
}

variable "vms" {
  type = map(object({
    vm_name    = string
    ip_address = string
    disks = map(
      object({
        size       = number
        disknumber = string
      })
    )
  }))
  default = {
    "Agent 1" = {
      ip_address = ""
      vm_name    = ""
      disks = {
        "Disk1" = {
          disknumber = "1"
          size       = 100
        }
      }
    },
    "Agent 2" = {
      ip_address = ""
      vm_name    = ""
      disks = {
        "Disk1" = {
          disknumber = "1"
          size       = 100
        }
      }
    },
    "Agent 3" = {
      ip_address = ""
      vm_name    = ""
      disks = {
        "Disk1" = {
          disknumber = "1"
          size       = 100
        }
      }
    },
    "Agent 4" = {
      ip_address = ""
      vm_name    = ""
      disks = {
        "Disk1" = {
          disknumber = "1"
          size       = 100
        }
      }
    },
    "Agent 5" = {
      ip_address = ""
      vm_name    = ""
      disks = {
        "Disk1" = {
          disknumber = "1"
          size       = 100
        }
      }
    }
  }
}


