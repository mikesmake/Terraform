# web-app
##Purpose
This module is to manage an Azure web app

## Usage
Use this module to manage an Azure web app as part of a larger composition
### Examples

#### Example of Web App using Azure front-door and Azure AD
```
module "webapp-module" {
  source                             = "./web-app"
  app_service_name                   = var.app_service_name
  rg                                 = azurerm_resource_group.rg
  App_service_plan                   = var.App_service_plan
  app_service_plan_name              = module.naming.app_service_plan.name_unique
  tags                               = var.tags
  key_vault_id                       = module.keyvault-module.key_vault_id
  tenant_id                          = var.tenant_id
  app_insights_name                  = module.naming.application_insights.name_unique
  custom_urls                        = var.website_urls
  key_vault_sslcert_certificate_name = var.key_vault_sslcert_certificate_name
  key_vault_sslcert_name             = var.key_vault_sslcert_name
  key_vault_sslcert_resource_group   = var.key_vault_sslcert_resource_group
  client_affinity_enabled            = true
  create_staging_key_vault_secrects  = false
  create_ssl_cert                    = false
  create_custom_domain               = true
}

#### Example of Web App using front-door
```
module "webapp-module" {
  source                             = "./web-app"
  app_service_name                   = var.app_service_name_medical
  resource_group_name                = azurerm_resource_group.rg.name
  App_service_plan                   = var.App_service_plan
  app_service_plan_name              = module.naming.app_service_plan.name_unique
  tags                               = var.tags
  key_vault_id                       = module.keyvault-module.key_vault_id
  tenant_id                          = var.tenant_id
  key_vault_staging_name             = module.keyvault-staging-module.key_vault_name
  app_insights_name                  = module.naming.application_insights.name_unique
  custom_urls                        = var.custom_urls_medical
  key_vault_sslcert_certificate_name = var.key_vault_sslcert_certificate_name
  key_vault_sslcert_name             = var.key_vault_sslcert_name
  key_vault_sslcert_resource_group   = var.key_vault_sslcert_resource_group
  client_affinity_enabled            = false
  app_service_certificate_name       = var.app_service_certificate_medical_name
  create_ssl_cert                    = false
  create_custom_domain               = false
  app_service_plan_capacity          = var.app_service_plan_capacity
  app_plan_zone_redundant            = var.app_plan_zone_redundant
  app_dotnet_version                 = var.app_dotnet_version

}

#### Example of Simple Web App no front-door
```
module "webapp-module" {
    source                                  = "./web-app"
    app_service_name                        = "as-appname-environmentname"
    resource_group_name                     = "rg"
    App_service_plan                        = var.App_service_plan
    app_service_plan_name                   = module.naming.app_service_plan.name_unique
    tags                                    = var.tags
    key_vault_id                            = "xxxxx-xxxxt"
    tenant_id                               = "21312312312312312312"
    key_vault_staging_name                  = "kv-appname-stage-environment"
    app_insights_name                       = module.naming.application_insights.name_unique
    websiteurl                              = "websiteUrl"
    openidconnectauthority                  = var.openidconnectauthority
    openidconnectclientid                   = var.openidconnectclientid
    key_vault_sslcert_certificate_name      = var.key_vault_sslcert_certificate_name
    key_vault_sslcert_name                  = var.key_vault_sslcert_name
    key_vault_sslcert_resource_group        = var.key_vault_sslcert_resource_group
    client_affinity_enabled                 = false
    app_service_certificate_name            = var.app_service_certificate_name
}

## External Dependencies
1. An Azure Resource Group
2. An Azure Key Vault for the prod slot settings
3. An Azure Key Vault for the staging slot settings
4. A reference to the key vault holding the SSL cert