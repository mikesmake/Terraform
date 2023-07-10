# Needed for every module

variable "resource_group_name" {
  type        = string
  description = "An exisiting resource group name"
}

variable "location" {
  type        = string
  description = "Azure Region"
  default = "East US"
}

variable "data_factory_name" {
  type        = string
  description = "A name for the data factory"
}

variable "tags" {
  type        = map(any)
  description = "Tags to identify web app"
}