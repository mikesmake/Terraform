terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.92.0"
    }
  }
}

################# data providers ####################################

# get resource group to deploy to 
data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

################ resource providers #################################

# create a recovery services vault
resource "azurerm_recovery_services_vault" "vault" {
  name                = var.recovery_services_vault_name
  location            = var.recovery_services_vault_location
  resource_group_name = data.azurerm_resource_group.rg.name
  sku                 = "Standard"
}

# create a backup policy 
resource "azurerm_backup_policy_vm" "backup_policy" {
  name                           = var.backup_policy_name
  resource_group_name            = data.azurerm_resource_group.rg.name
  recovery_vault_name            = azurerm_recovery_services_vault.vault.name
  instant_restore_retention_days = var.instant_restore_retention_days

  timezone = "UTC"

  backup {
    frequency = var.backup_frequency
    time      = var.backup_time
  }

  retention_daily {
    count = var.retention_daily
  }

  retention_weekly {
    count    = var.retention_weekly
    weekdays = var.retention_days_weekly
  }

  retention_monthly {
    count    = var.retention_monthly
    weekdays = var.retention_days_monthly
    weeks    = var.monthly_retention_week
  }

  retention_yearly {
    count    = var.retention_yearly
    weekdays = var.retention_days_yearly
    weeks    = var.yearly_retention_week
    months   = var.yearly_retention_month
  }
}