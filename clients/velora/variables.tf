variable "subscription_id" {
  description = "Azure subscription ID (Microsoft Azure Sponsorship)"
  type        = string
}

variable "tenant_id" {
  description = "Azure AD tenant ID (Sail Analytics)"
  type        = string
}

variable "resource_group_name" {
  description = "Existing resource group created by scripts/bootstrap_state.sh"
  type        = string
  default     = "pipelineiq-rg-dev"
}

variable "location" {
  description = "Primary region for all data/pipeline resources. Per DECISIONS.md #10."
  type        = string
  default     = "centralindia"
}

variable "environment" {
  type    = string
  default = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of dev, staging, prod."
  }
}

variable "client_name" {
  description = "Platform short name used as a prefix in resource naming"
  type        = string
  default     = "pipelineiq"
}

variable "log_retention_days" {
  description = "Log Analytics data retention"
  type        = number
  default     = 30
}

variable "kv_purge_protection_enabled" {
  description = "Key Vault purge protection. Cannot be disabled once enabled — keep false in dev."
  type        = bool
  default     = false
}
