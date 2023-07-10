variable "rg" {
  type = object({
    name     = string
    location = string
  })
  description = "Existing resource group"
  default = {
    name     = "rg1"
    location = "uksouth"
  }

  validation {
    condition = (
      anytrue([
        lower(var.rg["location"]) == "uksouth"
      ])
    )
    error_message = "Web app location must be in the UK South."
  }
}

# Define the App Service plan for your website
variable "App_service_plan" {
  type = object({
    sku_name               = string
    worker_count           = number # The amount of workers in the app plan
    zone_balancing_enabled = bool
  })
  default = {
    sku_name               = "S1"
    worker_count           = 1
    zone_balancing_enabled = false
  }

  validation {
    condition = (
      anytrue([
        lower(var.App_service_plan["sku_name"]) == "s1",
        lower(var.App_service_plan["sku_name"]) == "s2",
        lower(var.App_service_plan["sku_name"]) == "s3",
        lower(var.App_service_plan["sku_name"]) == "p1v2",
        lower(var.App_service_plan["sku_name"]) == "p2v2",
        lower(var.App_service_plan["sku_name"]) == "p3v2",
        lower(var.App_service_plan["sku_name"]) == "p1v3",
        lower(var.App_service_plan["sku_name"]) == "p2v3",
        lower(var.App_service_plan["sku_name"]) == "p3v3"
      ])
    )
    error_message = "SKU name must be one of the following S1 | S2 | S3 | P1v2 | P2v2 | P3v2 | P1v3 | P2v3 | P3v3."
  }

  validation {
    condition = (
      (
        (lower(var.App_service_plan["worker_count"]) == "1") &&
        anytrue([
          lower(var.App_service_plan["sku_name"]) == "s1",
          lower(var.App_service_plan["sku_name"]) == "s2",
          lower(var.App_service_plan["sku_name"]) == "s3",
          lower(var.App_service_plan["sku_name"]) == "p1v2",
          lower(var.App_service_plan["sku_name"]) == "p2v2",
          lower(var.App_service_plan["sku_name"]) == "p3v2",
          lower(var.App_service_plan["sku_name"]) == "p1v3",
          lower(var.App_service_plan["sku_name"]) == "p2v3",
          lower(var.App_service_plan["sku_name"]) == "p3v3",
          lower(var.App_service_plan["zone_balancing_enabled"]) == false
        ])
      )
      ||
      (
        (lower(var.App_service_plan["worker_count"]) == "3") &&
        anytrue([
          lower(var.App_service_plan["sku_name"]) == "p1v2",
          lower(var.App_service_plan["sku_name"]) == "p2v2",
          lower(var.App_service_plan["sku_name"]) == "p3v2",
          lower(var.App_service_plan["sku_name"]) == "p1v3",
          lower(var.App_service_plan["sku_name"]) == "p2v3",
          lower(var.App_service_plan["sku_name"]) == "p3v3",
          lower(var.App_service_plan["zone_balancing_enabled"]) == true
        ])
      )
    )

    error_message = "When using the Service plan tier must be as follows: use one of the following standard tier size S1 / S2 / S3 -- premiumv2 tier size p1v2 / p2v2 / p3v2 -- premiumv3 tier size p1v3 / p2v3 / p3v3."
  }

  validation {
    condition = (
      var.App_service_plan["worker_count"] == 1 ||
      var.App_service_plan["worker_count"] == 3
    )
    error_message = "Capacity must be equal to 1 when zone redundant is turned off and 3 when turned on."
  }
}

variable "app_service_plan_name" {
  type        = string
  description = "The web app serivce plan name"
}

variable "tenant_id" {
  type        = string
  description = "Set the size of your service plan"
}

variable "tags" {
  type        = map(any)
  description = "Tags to identify web app"
}

variable "key_vault_id" {
  type        = string
  description = "existing Key Vault under which to add settings from the web app"
}

variable "key_vault_staging_name" {
  type        = string
  description = "Name of an existing Key Vault under which to add settings from the staging web app"
  default     = "kv-name"
}

variable "app_insights_name" {
  type        = string
  description = "Name of the app service"
}

variable "app_service_name" {
  type        = string
  description = "App service name"
}

variable "app_dotnet_version" {
  type        = string
  description = "Set the version of dotnet core"
  default     = "v3.0"

  validation {
    condition = anytrue([
      lower(var.app_dotnet_version) == "v3.0",
      lower(var.app_dotnet_version) == "v5.0",
      lower(var.app_dotnet_version) == "v4.0",
      lower(var.app_dotnet_version) == "v6.0"
    ])
    error_message = "Invalid .Net version you must use one of the following v2.0 / v3.0 / v5.0 / v6.0."
  }
}

variable "key_vault_sslcert_certificate_name" {
  type        = string
  description = "Name of the certificate holding the SSL Cert within the key vault"
}

variable "key_vault_sslcert_name" {
  type        = string
  description = "Key vault resource name that is holding the SSL Cert"
}

variable "key_vault_sslcert_resource_group" {
  type        = string
  description = "Key vault resource group that is holding the SSL Cert key vault"
}

variable "client_affinity_enabled" {
  type        = bool
  description = "Improve performance of your stateless app by turning Affinity Cookie off, stateful apps should keep this setting on for compatibility"
}

variable "create_app_insights" {
  type        = bool
  description = "Set to true to create a dental site"
  default     = true
}

variable "app_service_certificate_name" {
  type        = string
  description = "Set app service cert"
  default     = "PopIfCertNeeded"
}

variable "create_app_service_plan" {
  type        = bool
  description = "Set to true to create a service plan"
  default     = true
}

variable "create_ssl_cert" {
  type        = bool
  description = "Set to true to create ssl cert in hosting environment profile"
  default     = true
}

variable "create_custom_domain" {
  type        = bool
  description = "Set up the custom doamin for the web app"
  default     = true
}

variable "create_staging_key_vault_secrects" {
  type        = bool
  description = "Do we have a staging key vault secrect to create"
  default     = true
}

#adding access restrictions for the ip url
#ip level access restriciton for app service
variable "appsvc_ip_restriction" {
  type = map(object({
    priority = number
    action   = string
  }))
  description = "ip restriction for the app service"
  default = {
    "AzureDevops" = {
      priority = 100
      action   = "Allow"
    }
    "AzureCloud" = {
      priority = 101
      action   = "Allow"
    }
    "AzureFrontDoor.Backend" = {
      priority = 102
      action   = "Allow"
    }
  }
}

#ip level access restriciton for app service deployment slot
variable "appsvcslot_ip_restriction" {
  type = map(object({
    priority = number
    action   = string
  }))
  description = "ip restriction for the app service"
  default = {
    "AzureDevops" = {
      priority = 100
      action   = "Allow"
    }
    "AzureCloud" = {
      priority = 101
      action   = "Allow"
    }
    "AzureFrontDoor.Backend" = {
      priority = 102
      action   = "Allow"
    }
  }
}

#adding access restrictions for the scm url
#scm level access restriciton for app service
variable "scm_ip_restriction" {
  type = map(object({
    priority = number
    action   = string
  }))
  description = "ip restriction for the app service"
  default = {
    "AzureDevops" = {
      priority = 100
      action   = "Allow"
    }
    "AzureFrontDoor.Backend" = {
      priority = 101
      action   = "Allow"
    }
  }
}

#scm level access restriciton for app service deployment slot
variable "slot_scm_ip_restriction" {
  type = map(object({
    priority = number
    action   = string
  }))
  description = "ip restriction for the app service"
  default = {
    "AzureDevops" = {
      priority = 100
      action   = "Allow"
    }
    "AzureFrontDoor.Backend" = {
      priority = 101
      action   = "Allow"
    }
  }
}

variable "custom_urls" {
  description = "custom url vaules"
  type = list(object({
    name = string
  }))
  default = [
    {
      name = "example.mps-dev.org"
    }
  ]
}

variable "thirtytwobit" {
  type        = bool
  description = "Makes the site 32bit"
  default     = true
}

variable "enable_web_sockets" {
  type        = bool
  description = "Turns on web sockets"
  default     = false
}

variable "vnet_route_all_enabled" {
  type        = bool
  description = "Turns on VNet out bound route"
  default     = false
}