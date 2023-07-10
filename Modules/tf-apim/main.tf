terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.92.0"
    }
  }
}

#importing application insights name
data "azurerm_application_insights" "mps-application-insights" {
  name                = var.application_insights_name
  resource_group_name = var.resource_group_name
}

#importing resource group name
data "azurerm_resource_group" "resource_group" {
  name = var.resource_group_name
}

#importing azure networking details
data "azurerm_subnet" "vnet-subnet" {
  name                 = var.vnet_subnet_name
  virtual_network_name = var.vnet_name
  resource_group_name  = var.vnet_resource_group_name
}

#provisioning azure api management resource
resource "azurerm_api_management" "apim-mps" {
  name                = var.apim_name
  location            = data.azurerm_resource_group.resource_group.location
  resource_group_name = data.azurerm_resource_group.resource_group.name
  publisher_name      = var.apim_publisher_name
  publisher_email     = var.apim_publisher_email
  sku_name            = var.apim_sku_name

  virtual_network_type = var.api_virtual_network_type

  identity {
    type = "SystemAssigned"
  }

  sign_in {
    enabled = true
  }

  virtual_network_configuration {
    subnet_id = data.azurerm_subnet.vnet-subnet.id
  }
}

#configuring named values for apim resource
resource "azurerm_api_management_named_value" "apim-named-values" {
  count               = var.named_value == "" ? length(var.named_value) : 0
  resource_group_name = data.azurerm_resource_group.resource_group.name
  api_management_name = azurerm_api_management.apim-mps.name
  name                = var.named_value[count.index].name
  display_name        = var.named_value[count.index].display_name
  value               = var.named_value[count.index].value
  depends_on          = [azurerm_api_management.apim-mps]
}

#configuring apim logger for allowing apim to send data to application insights
resource "azurerm_api_management_logger" "apim-logger" {
  name                = var.apim_logger_name
  api_management_name = azurerm_api_management.apim-mps.name
  resource_group_name = data.azurerm_resource_group.resource_group.name
  resource_id         = data.azurerm_application_insights.mps-application-insights.id

  application_insights {
    instrumentation_key = data.azurerm_application_insights.mps-application-insights.instrumentation_key
  }

  depends_on = [azurerm_api_management.apim-mps]
}

#configuring api in the apim resource
resource "azurerm_api_management_api" "apim-mps" {
  name                = var.apim_api_name
  resource_group_name = data.azurerm_resource_group.resource_group.name
  api_management_name = azurerm_api_management.apim-mps.name
  revision            = var.apim_api_revision
  display_name        = var.apim_api_display_name
  path                = var.apim_api_path
  protocols           = var.apim_protocols

  import {
    content_format = var.apim_content_format
    content_value  = file(var.apim_content_value)
  }

  depends_on = [azurerm_api_management.apim-mps]
}

#configuring api diagnositcs for the api been configured in the apim resource
resource "azurerm_api_management_api_diagnostic" "apim-api-diagnostic" {
  resource_group_name      = data.azurerm_resource_group.resource_group.name
  api_management_name      = azurerm_api_management.apim-mps.name
  api_name                 = azurerm_api_management_api.apim-mps.name
  api_management_logger_id = azurerm_api_management_logger.apim-logger.id
  identifier               = var.identifier

  sampling_percentage       = var.sampling_percentage
  always_log_errors         = true
  log_client_ip             = true
  verbosity                 = var.verbosity
  http_correlation_protocol = var.http_correlation_protocol

  depends_on = [azurerm_api_management.apim-mps, azurerm_api_management_logger.apim-logger, azurerm_api_management_api.apim-mps]
}

#conifiguring product in the apim resource
resource "azurerm_api_management_product" "mps-prd1" {
  product_id            = var.apim_prodid
  api_management_name   = azurerm_api_management.apim-mps.name
  resource_group_name   = data.azurerm_resource_group.resource_group.name
  display_name          = var.apim_prodid
  subscription_required = true
  approval_required     = true
  published             = true
  subscriptions_limit   = 1

  depends_on = [azurerm_api_management.apim-mps]
}

#configuring backend for the apim resource
resource "azurerm_api_management_backend" "api-backend" {
  name                = var.apim_backend_name
  resource_group_name = data.azurerm_resource_group.resource_group.name
  api_management_name = azurerm_api_management.apim-mps.name
  protocol            = var.apim_backend_protocol
  url                 = var.apim_backend_url

  depends_on = [azurerm_api_management.apim-mps]
}

#configuring product api for the product been created in the apim resource
resource "azurerm_api_management_product_api" "product_api" {
  api_name            = azurerm_api_management_api.apim-mps.name
  product_id          = azurerm_api_management_product.mps-prd1.product_id
  api_management_name = azurerm_api_management.apim-mps.name
  resource_group_name = azurerm_api_management.apim-mps.resource_group_name

  depends_on = [azurerm_api_management.apim-mps, azurerm_api_management_product.mps-prd1, azurerm_api_management_api.apim-mps]
}

#attaching policy for the api been configured in the apim resource
resource "azurerm_api_management_api_policy" "api_policy" {
  api_name            = azurerm_api_management_api.apim-mps.name
  api_management_name = azurerm_api_management_api.apim-mps.api_management_name
  resource_group_name = azurerm_api_management_api.apim-mps.resource_group_name

  xml_content = file(var.policy_content_value)

  depends_on = [azurerm_api_management_api.apim-mps]
}