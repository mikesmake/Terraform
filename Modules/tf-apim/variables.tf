#resource group name
variable "resource_group_name" {
  type        = string
  description = "Existing app resource for APIM group name"
}

#Application Insights Name
variable "application_insights_name" {
  type        = string
  description = "application insights name"
  default     = ""
}

#Azure Networking Details
variable "virtual_network_address_space" {
  description = "List of products to create"
  type        = list(string)
  default     = []
}

variable "virtual_network_dns_servers" {
  description = "List of products to create"
  type        = list(string)
  default     = []
}

variable "vnet_subnet_name" {
  description = "Sub net name of the Virtual Network to add to APIM"
  type        = string
  default     = ""
}

variable "vnet_resource_group_name" {
  description = "Virtual Network resource group name to link to APIM"
  type        = string
  default     = ""
}

variable "vnet_name" {
  description = "Virtual Network name to link to APIM"
  type        = string
  default     = ""
}

variable "api_virtual_network_type" {
  description = "Virtual Network type within APIM"
  type        = string
  default     = ""
}

#Azure Api Management Service
#Azure Api Management Service Configuration
variable "apim_name" {
  type        = string
  description = "Existing apim name"
  default     = "apim-mps"
}

variable "apim_publisher_name" {
  type        = string
  description = "publisher name"
  default     = "test"
}

variable "apim_publisher_email" {
  type        = string
  description = "publisher email"
  default     = "test@medicalprotection.org"
}

variable "apim_sku_name" {
  type        = string
  description = "sku name"
  default     = "Developer_1"
}

#Api Configuration
variable "apim_api_name" {
  type        = string
  description = "api name"
  default     = "Test API"
}

variable "apim_api_revision" {
  type        = string
  description = "apim revision"
  default     = "1"
}

variable "apim_api_display_name" {
  type        = string
  description = "apim display name"
  default     = "Test API"
}

variable "apim_api_path" {
  type        = string
  description = "apim api path"
  default     = " "
}

variable "apim_protocols" {
  type        = list(string)
  description = "apim protocols"
  default     = ["https"]
}

variable "apim_content_format" {
  type        = string
  description = "apim content format"
  default     = "openapi+json"
}

variable "apim_content_value" {
  type        = string
  description = "apim content value"
  default     = "swagger.json"

}

#APIM Backend Configuration
variable "apim_backend_name" {
  type        = string
  description = "apim backend name"
}

variable "apim_backend_protocol" {
  type        = string
  description = "apim backend protocol"
}

variable "apim_backend_url" {
  type        = string
  description = "apim backend url"
  default     = "https://backend"
}

#APIM Product Configuration
variable "apim_prodid" {
  type        = string
  description = "apim prodid"
  default     = "test-product"
}

variable "apim_prod_display_name" {
  type        = string
  description = "apim prod display name"
  default     = "Test Product"
}

variable "products" {
  description = "List of products to create"
  type        = list(string)
  default     = []
}

#APIM Logger Configuration
variable "apim_logger_display_name" {
  type        = string
  description = "apim logger display name"
  default     = "mps-logger"
}

variable "apim_logger_name" {
  description = "APIM logger name"
  type        = string
  default     = ""
}

#Api Policy Configuration
variable "policy_content_value" {
  description = "file path for the policy file"
  type        = string
  default     = "policies.xml"
}

#Api Diagnostic Configuration
variable "identifier" {
  description = "identifier for the api diagnostics. values can be applicationinsights or azuremonitor"
  type        = string
}

variable "sampling_percentage" {
  description = "sampling percentage for the api diagnostics. values can be between 5.0 to 100.0"
  type        = string
}

variable "verbosity" {
  description = "defining verbosity for api diagnostics. should be either verbose, information or error"
  type        = string
}

variable "http_correlation_protocol" {
  description = "defining http correlation protocol for api diagnostics. should be either None, Legacy or W3C"
  type        = string
}

#Apim Named Values Configuration
variable "named_value" {
  description = "value for the named value"
  type = list(object({
    name         = string
    display_name = string
    value        = string
  }))
  default = [
    {
      name         = "example-apimg"
      display_name = "ExampleProperty"
      value        = "Example Value"
    },
    {
      name         = "example-apimg-two"
      display_name = "ExampleProperty-two"
      value        = "Example Value-two"
    },
    {
      name         = "example-apimg-three"
      display_name = "ExampleProperty-three"
      value        = "Example Value-three"
    }
  ]
}