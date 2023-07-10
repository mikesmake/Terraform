variable "resource_group_name" {
  type        = string
  description = "An existing resource group name"
}

variable "resource_group_location" {
  type        = string
  description = "An existing resource group name"
}

variable "vnet_name" {
  type        = string
  description = "vnet that NLB will use"
}

variable "vnet_resource_group" {
  type        = string
  description = "RG that vnet is stored in"
}

variable "subnet_name" {
  type = string
}

variable "nlb_name" {
  type = string
}

variable "front_end_name" {
  type = string
}

variable "backend_pool_name" {
  type = string
}

variable "health_probe_name" {
  type = string
}

variable "health_probe_port" {
  type = number
}

variable "rule_name" {
  type = string
}

variable "rule_protocol" {
  type    = string
  default = "Tcp"
}

variable "frontend_port" {
  type    = number
  default = "80"
}

variable "backend_port" {
  type    = number
  default = "80"
}

variable "back_end_vms" {
  type = map(object({
    nic_id = string
  }))
  default = {
  }
}

