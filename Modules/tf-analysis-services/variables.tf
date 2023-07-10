# Neededfor every module

variable "resource_group_name" {
  type        = string
  description = "An exisiting resource group name"
}

variable "analysis_server_name" {
  type        = string
  description = "A name for the analysis services"
}

variable "location" {
  type        = string
  description = "Azure Region"
  default = "East US"
}

variable "analysis_server_sku" {
  type        = string
  description = "the analysis services sku"
}

variable "analysis_server_admin" {
  type        = string
  description = "the analysis server admin username"
}

variable "tags" {
  type        = map(any)
  description = "Tags to identify web app"
}