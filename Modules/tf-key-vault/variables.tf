variable "resource_group_name" {
  type        = string
  description = "Name of an externally managed resource group"
}

variable "resource_group_location" {
  type        = string
  description = "An existing resource group name"
}

variable "sku_name" {
  type        = string
  default     = "standard"
  description = "The sku of the key vault"
}

variable "create_terraform_access_policy" {
  type        = bool
  default     = true
  description = "Give the current context access to the keyvault? (Uses current authentication to find the user account / principal to add)"
}

variable "key_vault_name" {
  type        = string
  description = "The name of the key vault to manage"
}

variable "tags" {
  type        = map(any)
  description = "Tags"
}


variable "public_access" {
  type        = string
  description = "Allow public access"
  default     = true
}

variable "endpoint_name" {
  type        = string
  description = "endpoint name"
}

variable "subnet_name" {
  type        = string
  description = "subnet_name"
}

variable "virtual_network_name" {
  type        = string
  description = "virtual_network_name"
}

variable "virtual_network_resource_group" {
  type        = string
  description = "virtual_network_resource_group"
}
