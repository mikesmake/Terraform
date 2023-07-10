variable "resource_group_name" {
  type        = string
  description = "Existing resource group name"
}

variable "cdn_profile_name" {
  type        = string
  description = "CDN Profile Name"
}

variable "sku" {
  type        = string
  description = "sku name for CDN Profile"
}

variable "cdn_endpoint_name" {
  type        = string
  description = "CDN Endpoint Name"
}

variable "origin_name" {
  type        = string
  description = "Origin Name"
}

variable "origin_host_name" {
  type        = string
  description = "Origin Host Name"
}