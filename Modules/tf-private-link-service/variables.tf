variable "pls_name" {
  type        = string
  description = "pls_name"
}

variable "resource_group_name" {
  type        = string
  description = "resource_group_name"
}


variable "approved_subscription_id" {
  type        = set(string)
  description = "subscription_id"
}

variable "tags" {
  type        = map(any)
  description = "Tags"
}

variable "subnet_id" {
  type        = string
  description = "subnet_id"
}


variable "resource_group_location" {
  type        = string
  description = "An existing resource group name"
}


variable "nlb_id" {
  type        = list
  description = "ID of NLB for the pls"
}
