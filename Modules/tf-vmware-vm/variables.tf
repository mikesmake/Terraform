variable "datacenter_name" {
  type        = string
  description = "Name of the existing datacenter"
  default     = "LEEDS"
}

variable "datastore_name" {
  type        = string
  description = "Name of the existing datastore e.g. Prod-Gen-01"
}

variable "cluster_name" {
  type        = string
  description = "Name of the cluster"
  default     = "LDS"
}

variable "network_name" {
  type        = string
  description = "Name of the network"
  default     = "vpservers2"
}

variable "template_name" {
  type        = string
  description = "Name of the template to use"
  default     = "WIN2019_DTC_TF"
}

variable "vm_name" {
  type        = string
  description = "Name of the vm"
}

variable "folder_name" {
  type        = string
  description = "Name of the folder to put the VM in"
  default     = "Discovered virtual machine"
}

variable "memory" {
  type        = number
  description = "Amount of memory"
  default     = "4096"
}

variable "cpus" {
  type        = number
  description = "Number of cpus"
  default     = "2"
}

variable "cores" {
  type        = number
  description = "Number of cores"
  default     = "2"
}

variable "disks" {
  type = map(
    object({
      size       = number
      disknumber = string
    })
  )
}

variable "domain_admin_user" {
  type        = string
  description = "User used to domain join"
  default     = "join"
}

variable "domain_admin_password" {
  type        = string
  description = "password for user used to domain join"
}

variable "local_admin_password" {
  type        = string
  description = "local admin password"
}

variable "ip_address" {
  type        = string
  description = "IPv4 address for VM"
}

variable "ip_address_netmask" {
  type        = string
  description = "IPv4 address for VM"
  default     = "24"
}

variable "ipv4_gateway" {
  type        = string
  description = "IPv4 address for VM"
  default     = "10.8.134.254"
}



