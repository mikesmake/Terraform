###################################################################################################
# Environment
###################################################################################################
variable "tenant_id" {
  type        = string
  description = "The tenant ID for the target subscription"
  default     = ""
}

variable "subscription_id" {
  type = map(string)
  default = {
    service-a2   = ""
    service-N01  = ""
    service-S1   = ""
    service-Prod = ""
  }
}

variable "hub_subscription_id" {
  type        = string
  description = "The tenant ID for the target subscription"
  default     = ""
}


###################################################################################################
# Key Vault
###################################################################################################

variable "key_vault_name" {
  type = map(string)
  default = {
    service-a2   = "kv-service-a2"
    service-N01  = "kv-service-n01"
    service-S1   = "kv-service-s1"
    service-Prod = "kv-service-prod"
  }
}


###################################################################################################
# Virtual Machine
###################################################################################################


variable "vm_vnet_name" {
  type = map(string)
  default = {
    service-a2   = "vnet-MemberService-dev"
    service-N01  = "vnet-MemberService-test"
    service-S1   = "vnet-MemberService-test"
    service-Prod = "vnet-MemberService-prod"
  }
}

variable "vm_count" {
  type = map(number)
  default = {
    service-a2   = 1
    service-N01  = 1
    service-S1   = 1
    service-Prod = 2
  }
}

variable "vm_vnet_resource_group" {
  type    = string
  default = "rg-SharedResources-land"
}

variable "nic_subnet_name" {
  type        = string
  description = "nic_subnet_name"
  default     = "hosts"
}

variable "environment_letter" {
  type = map(string)
  default = {
    service-a2   = "D"
    service-N01  = "T"
    service-S1   = "T"
    service-Prod = "L"
  }
}

variable "environment_short_name" {
  type = map(string)
  default = {
    service-a2   = "a2"
    service-N01  = "n01"
    service-S1   = "s1"
    service-Prod = ""
  }
}

variable "virtual_machine_size" {
  type = map(string)
  default = {
    service-a2   = "Standard_DS3_v2"
    service-N01  = "Standard_DS3_v2"
    service-S1   = "Standard_DS3_v2"
    service-Prod = "Standard_DS3_v2"
  }
}

variable "kv_resource_group_name" {
  type    = string
  default = "rg-SharedResources-land"
}

###################################################################################################
# Network Load Balancer
###################################################################################################

variable "health_probe_port" {
  type    = number
  default = 443
}

variable "rule_name" {
  type        = string
  description = "rule_name"
  default     = "Rule443"
}

variable "backend_port" {
  type        = number
  description = "backend_port"
  default     = 443
}

variable "frontend_port" {
  type        = number
  description = "frontend_port"
  default     = 443
}
variable "health_probe_name" {
  type        = string
  description = "health_probe_name"
  default     = "healthport443"
}


###################################################################################################
# Private Link Service
###################################################################################################

variable "vnet_name" {
  type = map(string)
  default = {
    service-a2   = "vnet-MemberService-dev"
    service-N01  = "vnet-MemberService-test"
    service-S1   = "vnet-MemberService-test"
    service-Prod = "vnet-MemberService-prod"
  }
}
variable "vnet_resource_group" {
  type    = string
  default = "rg-SharedResources-land"
}


###################################################################################################
# Front Door with CDN
###################################################################################################

variable "log_analytics_workpace_name" {
  type = map(string)
  default = {
    service-a2   = "law-MemberService-dev"
    service-N01  = "law-MemberService-test"
    service-S1   = "law-MemberService-test"
    service-Prod = "law-MemberService-prod"
  }
}

variable "log_analytics_workpace_rg" {
  type    = string
  default = "rg-SharedResources-land"
}

variable "host_name" {
  type = map(string)
  default = {
    service-a2   = "a2service-internal.dev.org"
    service-N01  = "n01service-internal.test.org"
    service-S1   = "s1service-internal.test.org"
    service-Prod = "service-internal.org"
  }
}

variable "host_header" {
  type = map(string)
  default = {
    service-a2   = "a2service.dev.org"
    service-N01  = "n01service.test.org"
    service-S1   = "s1service.test.org"
    service-Prod = "service.org"
  }
}

variable "dental_host_header" {
  type = map(string)
  default = {
    service-a2   = "a2service.dental.dev.org"
    service-N01  = "n01service.dental.test.org"
    service-S1   = "s1service.dental.test.org"
    service-Prod = "service.dental.org"
  }
}

variable "dns_zone_name" {
  type = map(string)
  default = {
    service-a2   = "dev.org"
    service-N01  = "test.org"
    service-S1   = "test.org"
    service-Prod = ".org"
  }
}

variable "dental_dns_zone_name" {
  type = map(string)
  default = {
    service-a2   = "dental.dev.org"
    service-N01  = "dental.test.org"
    service-S1   = "dental.test.org"
    service-Prod = ".org"
  }
}

