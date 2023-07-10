variable "resource_group_name" {
  type        = string
  description = "An existing resource group name"
}

variable "nsg_name" {
  type        = string
  description = "An name for the NSG"
}


variable "bastion_subnet" {
  type        = string
  description = "The subnet used for the Bastion service"
}

variable "hosts_subnet" {
  type        = string
  description = "The subnet used for the hosts"
}

variable "security_rules" {
  type = map(
    object({
      priority                   = number
      direction                  = string
      access                     = string
      protocol                   = string
      source_port_range          = string
      destination_port_range     = string
      source_address_prefix      = string
      destination_address_prefix = string
    })
  )
  description = "A list of rules to apply on top of the default rules in the module"
}
