variable "storage_account_name" {
  type        = string
  description = "A name for the storage account"
}

variable "app_plan_name" {
  type        = string
  description = "A name for the app service plan"
}

variable "app_plan_tier" {
  type        = string
  description = "App Plan Tier"
  default     = "Standard"
}

variable "app_plan_size" {
  type        = string
  description = "Size of the app plan"
  default     = "S1"
}

variable "function_app_name" {
  type        = string
  description = "A name for the function app"
}

variable "resource_group_name" {
  type        = string
  description = "An existing resource group name"
}