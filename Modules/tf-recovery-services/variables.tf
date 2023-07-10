#Needed for every module
variable "resource_group_name" {
  type        = string
  description = "An existing resource group name"
}

variable "recovery_services_vault_name" {
  type        = string
  description = "An name for the vault"
}

variable "recovery_services_vault_location" {
  type        = string
  description = "Location of the vault"
}

variable "backup_policy_name" {
  type        = string
  description = "An name for the policy"
}

variable "recovery_services_vault" {
  type        = string
  description = "Vault name"
}

variable "backup_frequency" {
  type        = string
  description = "How often the backup is ran must be either Daily or Weekly"
  default     = "Daily"
}

variable "backup_time" {
  type        = string
  description = "Time the backup will run"
  default     = "20:00"
}

variable "instant_restore_retention_days" {
  type        = number
  description = "How many days snapshots to retain"
  default     = "2"
}

variable "retention_daily" {
  type        = number
  description = "Daily backups to retain"
  default     = "7"
}

variable "retention_weekly" {
  type        = number
  description = "weekly backups to retain"
  default     = "5"
}

variable "retention_days_weekly" {
  type        = list(any)
  description = "The backup days that will be retained for weekly backups"
  default     = ["Friday"]
}

variable "retention_monthly" {
  type        = number
  description = "monthly backups to retain"
  default     = "36"
}

variable "retention_days_monthly" {
  type        = list(any)
  description = "The backup day that will be retained for monthly backups"
  default     = ["Saturday"]
}


variable "monthly_retention_week" {
  type        = list(any)
  description = "Which week to take the backup from for monthly retention"
  default     = ["First"]
}

variable "retention_yearly" {
  type        = number
  description = "yearly backups to retain"
  default     = "6"
}

variable "retention_days_yearly" {
  type        = list(any)
  description = "The backup day that will be retained for yearly backup"
  default     = ["Saturday"]
}

variable "yearly_retention_week" {
  type        = list(any)
  description = "Which week to take the backup from for yearly retention"
  default     = ["First"]
}


variable "yearly_retention_month" {
  type        = list(any)
  description = "Which month to take the backup from for yearly retention"
  default     = ["January"]
}





