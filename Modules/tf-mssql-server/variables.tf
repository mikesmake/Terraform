#############################################################################################
# Environment
#############################################################################################

variable "resource_group_name" {
  type        = string
  description = "Existing resource group name"
}

variable "resource_group_location" {
  type        = string
  description = "Existing resource group location"
}


#############################################################################################
# Data Blocks
#############################################################################################

variable "key_vault_name" {
  type        = string
  description = "Name of an existing Key Vault under which to create the Admin Login/Password for the Azure SQL Server"

}

variable "audit_storage_account" {
  type        = string
  description = "Audit Storage Account"
}

variable "audit_storage_account_resource_group" {
  type        = string
  description = "Audit Storage Account Resource Group"
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



#############################################################################################
# SQL Server
#############################################################################################


variable "sql_server_name" {
  type        = string
  description = "Name of the sql server to manage"
}

variable "public_access" {
  type        = string
  description = "Allow public access"
  default     = true
}

variable "azure_activedirectory_admin" {
  type = object({
    login_username = string
    object_id      = string

  })
  description = "Sets the AAD Admin Setting to allow Windows Authentication"
  default = {
    login_username = "Azure DBA Level 1"
    object_id      = "d5a971dc-d9cd-474e-a5d4-ef6c36dcb727"
  }
}


#############################################################################################
# SQL Audit
#############################################################################################


variable "enable_audit" {
  type        = bool
  description = "Set to true to enable audit logging into a storage account"
  default     = false
}

#############################################################################################
# SQL Firewall Rules
#############################################################################################


variable "allow_azure_access_to_sql" {
  type        = bool
  description = "Set to true to enable Azure services access to this service"
  default     = false
}

variable "allow_access_from_leeds_office" {
  type        = bool
  description = "Set to true to create a firewall rule enabling access to the leeds office"
  default     = false
}

#############################################################################################
# Private Endpoint
#############################################################################################


variable "endpoint_name" {
  type        = string
  description = "endpoint name"
}



#############################################################################################
# Database
#############################################################################################

variable "sql_dbs" {
  type = map(object({
    name     = string
    sku_name = string
  }))
  default = {
    "first" = {
      name     = "DB1"
      sku_name = "Basic"
    }
    "second" = {
      name     = "DB2"
      sku_name = "Basic"
    }
  }
}














