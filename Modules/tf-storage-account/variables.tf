#############################################################################################
# Data Blocks
#############################################################################################
variable "resource_group_name" {
  type        = string
  description = "An existing resource group name"
}

variable "private_endpoint" {
  type        = bool
  description = "create private endpoints?"
  default     = false
}

variable "subnet_name" {
  type        = string
  description = "subnet_name"
  default     = ""
}

variable "virtual_network_name" {
  type        = string
  description = "virtual_network_name"
  default     = ""
}

variable "virtual_network_resource_group" {
  type        = string
  description = "virtual_network_resource_group"
  default     = ""
}

#############################################################################################
# Storage Account 
#############################################################################################

variable "storage_account_name" {
  type        = string
  description = "A name for the storage account"
}

variable "resource_group_location" {
  type        = string
  description = "An existing resource group name"
}

variable "storage_account_tier" {
  type        = string
  description = "Tier of the storage account"
  default     = "Standard"
}

variable "storage_replication_type" {
  type        = string
  description = "storage replication type"
  default     = "GRS"
}

variable "storage_account_kind" {
  type        = string
  description = "Storage account kind e.g. Blob, FileStorage, StorageV2"
  default     = "StorageV2"
}

variable "allow_public_access" {
  type        = bool
  description = "Allow public access"
  default     = true
}

#############################################################################################
# Storage Container
#############################################################################################

variable "create_blob_storage" {
  type        = bool
  description = "Creates a container and blob storage if set to True"
  default     = false
}

variable "container_access_type" {
  type        = string
  description = "Container Access Type"
  default     = "private"
}

variable "storage_container_name" {
  type        = string
  description = "Storage Container Name"
  default     = "containername"
}

#############################################################################################
# Storage Blob
#############################################################################################

variable "blob_name" {
  type        = string
  description = "Blob Name"
  default     = "blobstore"
}

variable "storage_blob_type" {
  type        = string
  description = ""
  default     = "block"
}

#############################################################################################
# File Share
#############################################################################################

variable "create_file_share" {
  type        = bool
  description = "Creates a file share if set to True"
  default     = false
}

variable "file_share_name" {
  type        = string
  description = "Faile Share Name"
  default     = "filesstore"
}

variable "file_sharequota" {
  type        = number
  description = "The maximum size of the share, in gigabytes"
  default     = 5
}

#############################################################################################
# Private Endpoint
#############################################################################################

variable "endpoint_name" {
  type        = string
  description = "name for the endpoint"
  default     = ""
}
