variable "resource_group_name" {
  type = string
}

variable "vnet_name" {
  type = string
}

# Provide an address space (multiple can be provided but one is the standand)
variable "address_space" {
  type    = list(string)
  default = ["10.0.0.0/16"]
}

variable "dns_servers" {
  type = list(string)
  #These are AZUKSDC01 and AZUKWDC02
  default = ["10.80.0.133", "10.80.1.133"]
}


# provide a list of subnets required. delegation_name is required but should be blank unless the subnet is to be delagated to a service (wep app, managed instace etc)
variable "subnets" {
  type = map(object({
    address_prefix  = list(string)
    delegation_name = string
  }))
  default = {
    subnet1 = {
      address_prefix  = ["10.0.1.0/24"]
      delegation_name = ""
    }
  }
}

variable "nsg_id" {
  type        = string
  description = "The ID of the NSG to link to the subnet"
}