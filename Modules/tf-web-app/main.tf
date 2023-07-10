###################################################################################################
# Environment
###################################################################################################

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.30.0"
    }
  }
}

#To get the current session details
data "azurerm_client_config" "current" {}

###################################################################################################
# Data 
###################################################################################################

data "azurerm_key_vault" "key_store_staging" {
  count = var.create_staging_key_vault_secrects ? 1 : 0

  name                = var.key_vault_staging_name
  resource_group_name = var.rg.name
}

###################################################################################################
# App Service Plan
###################################################################################################

resource "azurerm_service_plan" "appsvcplan" {
  count                  = var.create_app_service_plan ? 1 : 0
  name                   = var.app_service_plan_name
  location               = var.rg.location
  resource_group_name    = var.rg.name
  os_type                = "Windows"
  worker_count           = var.App_service_plan["worker_count"]
  tags                   = var.tags
  sku_name               = var.App_service_plan["sku_name"]
  zone_balancing_enabled = var.App_service_plan["zone_balancing_enabled"]
}

data "azurerm_service_plan" "app_service_plan" {
  count = var.create_app_service_plan ? 0 : 1

  name                = var.app_service_plan_name
  resource_group_name = var.rg.name

  depends_on = [azurerm_service_plan.appsvcplan]
}


###################################################################################################
# App Insights
###################################################################################################

resource "azurerm_application_insights" "appinsights" {
  count = var.create_app_insights ? 1 : 0

  name                = var.app_insights_name
  location            = var.rg.location
  resource_group_name = var.rg.name
  application_type    = "web"
  tags                = var.tags
}

###################################################################################################
# App Service 
###################################################################################################

resource "azurerm_windows_web_app" "appsvc" {
  name                    = var.app_service_name
  location                = var.rg.location
  resource_group_name     = var.rg.name
  service_plan_id         = var.create_app_service_plan ? azurerm_service_plan.appsvcplan[0].id : data.azurerm_service_plan.app_service_plan[0].id
  https_only              = true
  client_affinity_enabled = var.client_affinity_enabled
  tags                    = var.tags

  site_config {
    #dotnet_framework_version = var.app_dotnet_version
    use_32_bit_worker      = var.thirtytwobit
    always_on              = true
    ftps_state             = "FtpsOnly"
    websockets_enabled     = var.enable_web_sockets
    http2_enabled          = true
    vnet_route_all_enabled = var.vnet_route_all_enabled

    default_documents = ["Default.htm", "Default.html", "Default.asp", "index.htm", "index.html", "default.aspx"]

    application_stack {
      current_stack  = "dotnetcore"
      dotnet_version = var.app_dotnet_version
    }

    #adding access restriciton for ip and scm url on azure app service
    dynamic "ip_restriction" {
      for_each = var.appsvc_ip_restriction
      content {
        service_tag = ip_restriction.key
        name        = ip_restriction.key
        priority    = ip_restriction.value["priority"]
        action      = ip_restriction.value["action"]
      }
    }
  }

  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    ignore_changes = [
      app_settings,
      virtual_network_subnet_id
    ]
  }

  depends_on = [azurerm_service_plan.appsvcplan, data.azurerm_service_plan.app_service_plan]
}

###################################################################################################
# Key Vault
###################################################################################################

# Get the key vault with the SSL cert
data "azurerm_key_vault" "kv_sslcert" {
  name                = var.key_vault_sslcert_name
  resource_group_name = var.key_vault_sslcert_resource_group
}

# Get the cert from the key vault
data "azurerm_key_vault_certificate" "key_vault_cert" {
  count        = var.create_ssl_cert ? 1 : 0
  name         = var.key_vault_sslcert_certificate_name
  key_vault_id = data.azurerm_key_vault.kv_sslcert.id
}

###################################################################################################
# Custom URL & SSL Bindings 
###################################################################################################

# Add custom Url without SSL bindings
resource "azurerm_app_service_custom_hostname_binding" "appsvc_non_ssl_bindings" {
  count = var.create_custom_domain && !var.create_ssl_cert ? length(var.custom_urls) : 0


  hostname            = var.custom_urls[count.index].name
  app_service_name    = azurerm_windows_web_app.appsvc.name
  resource_group_name = var.rg.name

  depends_on = [azurerm_windows_web_app.appsvc, data.azurerm_key_vault_certificate.key_vault_cert[0], azurerm_app_service_certificate.appsvc_certificate]
}

# Add custom Url with SSL bindings
resource "azurerm_app_service_custom_hostname_binding" "appsvc_ssl_bindings" {
  count = var.create_custom_domain && var.create_ssl_cert ? length(var.custom_urls) : 0

  hostname            = var.custom_urls[count.index].name
  thumbprint          = data.azurerm_key_vault_certificate.key_vault_cert[0].thumbprint
  ssl_state           = "SniEnabled"
  app_service_name    = azurerm_windows_web_app.appsvc.name
  resource_group_name = var.rg.name

  depends_on = [azurerm_windows_web_app.appsvc, data.azurerm_key_vault_certificate.key_vault_cert, azurerm_app_service_certificate.appsvc_certificate]
}

# Link the SSL cert to the bindings
resource "azurerm_app_service_certificate" "appsvc_certificate" {
  count = var.create_ssl_cert ? 1 : 0

  name                = var.app_service_certificate_name
  resource_group_name = var.rg.name
  location            = var.rg.location
  app_service_plan_id = var.create_app_service_plan ? azurerm_service_plan.appsvcplan[0].id : data.azurerm_service_plan.app_service_plan[0].id
  key_vault_secret_id = data.azurerm_key_vault_certificate.key_vault_cert[0].id

  depends_on = [azurerm_windows_web_app.appsvc, data.azurerm_key_vault_certificate.key_vault_cert]
}

###################################################################################################
# Staging Slot
###################################################################################################

# add staging slot
resource "azurerm_windows_web_app_slot" "appsvcslot" {
  name                    = "Staging"
  app_service_id          = azurerm_windows_web_app.appsvc.id
  https_only              = true
  client_affinity_enabled = var.client_affinity_enabled
  tags                    = var.tags

  site_config {
    use_32_bit_worker      = var.thirtytwobit
    always_on              = true
    ftps_state             = "FtpsOnly"
    websockets_enabled     = var.enable_web_sockets
    http2_enabled          = true
    vnet_route_all_enabled = var.vnet_route_all_enabled

    application_stack {
      current_stack  = "dotnetcore"
      dotnet_version = var.app_dotnet_version
    }

    default_documents = ["Default.htm", "Default.html", "Default.asp", "index.htm", "index.html", "default.aspx"]
    #Access Restriction for app service
    #adding access restriciton for ip and scm url on azure app service deployment slot
    dynamic "ip_restriction" {
      for_each = var.appsvcslot_ip_restriction
      content {
        service_tag = ip_restriction.key
        name        = ip_restriction.key
        priority    = ip_restriction.value["priority"]
        action      = ip_restriction.value["action"]
      }
    }
  }

  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    ignore_changes = [
      app_settings,
      virtual_network_subnet_id
    ]
  }

  depends_on = [azurerm_windows_web_app.appsvc]
}

###################################################################################################
# Key Vault Secrets & Access
###################################################################################################

# Add key vault secrets for web app
resource "azurerm_key_vault_secret" "application-insights-key" {
  count = var.create_app_insights ? 1 : 0

  name         = "ApplicationInsights--InstrumentationKey"
  value        = azurerm_application_insights.appinsights[0].instrumentation_key
  key_vault_id = var.key_vault_id
  tags         = var.tags

  depends_on = [azurerm_application_insights.appinsights]
}

# Give web app prod access
resource "azurerm_key_vault_access_policy" "key_vault_access_prod" {
  key_vault_id = var.key_vault_id
  tenant_id    = var.tenant_id
  object_id    = azurerm_windows_web_app.appsvc.identity[0].principal_id

  secret_permissions = [
    "Get", "List"
  ]

  depends_on = [azurerm_windows_web_app.appsvc]
}

# Give web app slot access
resource "azurerm_key_vault_access_policy" "key_vault_access_slot" {
  key_vault_id = var.key_vault_id
  tenant_id    = var.tenant_id
  object_id    = azurerm_windows_web_app_slot.appsvcslot.identity[0].principal_id

  secret_permissions = [
    "Get", "List"
  ]

  depends_on = [azurerm_windows_web_app_slot.appsvcslot]
}

# Add key vault secrets for staging web app
# Give staging slot access
resource "azurerm_key_vault_access_policy" "key_vault_access_staging" {
  count = var.create_staging_key_vault_secrects ? 1 : 0

  key_vault_id = data.azurerm_key_vault.key_store_staging[0].id
  tenant_id    = var.tenant_id
  object_id    = azurerm_windows_web_app_slot.appsvcslot.identity[0].principal_id

  secret_permissions = [
    "Get", "List"
  ]

  depends_on = [azurerm_windows_web_app_slot.appsvcslot]
}

resource "azurerm_key_vault_secret" "application-insights-key-staging" {
  count = var.create_app_insights && var.create_staging_key_vault_secrects ? 1 : 0

  name         = "ApplicationInsights--InstrumentationKey"
  value        = azurerm_application_insights.appinsights[0].instrumentation_key
  key_vault_id = data.azurerm_key_vault.key_store_staging[0].id
  tags         = var.tags

  depends_on = [azurerm_application_insights.appinsights]
}