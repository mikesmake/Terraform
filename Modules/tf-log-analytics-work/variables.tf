variable "law_name" {
  type        = string
  description = "The name of the workspace"
}
variable "law_sku" {
  type        = string
  description = "The SKU for the workspace"
  default     = "PerGB2018"
}
variable "resource_group_name" {
  type        = string
  description = "Name of an externally managed resource group"
}

variable "resource_group_location" {
  type        = string
  description = "An existing resource group name"
}
