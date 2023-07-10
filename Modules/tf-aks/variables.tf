variable "resource_group_name" {
  type        = string
  description = "An existing resource group name"
}


variable "kubernetes_cluster_name" {
  type        = string
  description = "kubernetes_cluster_name"
}

variable "kubernetes_cluster_dns_prefix" {
  type        = string
  description = "kubernetes_cluster_dns_prefix"
}

variable "default_node_pool_name" {
  type        = string
  description = "Name of default node pool"
  default     = "agentpool"
}

variable "default_node_count" {
  type        = number
  description = "default_node_count"
  default     = "1"
}


variable "deault_node_VM_Size" {
  type        = string
  description = "default_node_pool_name"
  default     = "Standard_D2_v2"

}

variable "indentity_type" {
  type        = string
  description = "indentity_type"
  default     = "SystemAssigned"
}


