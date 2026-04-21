variable "name" {
  description = "Key Vault name (globally unique, 3-24 chars, alphanumeric + hyphens, must start with letter)"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9-]{1,22}[a-zA-Z0-9]$", var.name)) && length(var.name) <= 24
    error_message = "Key Vault name must be 3-24 chars, start with a letter, end alphanumeric, and only contain letters, digits, hyphens."
  }
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "tenant_id" {
  description = "Azure AD tenant the vault is bound to"
  type        = string
}

variable "sku_name" {
  type    = string
  default = "standard"
}

variable "enable_rbac_authorization" {
  description = "Use Azure RBAC for data-plane access (modern best practice; false = legacy access policies)"
  type        = bool
  default     = true
}

variable "purge_protection_enabled" {
  description = "Once enabled cannot be disabled. Keep false in dev, true in prod."
  type        = bool
  default     = false
}

variable "soft_delete_retention_days" {
  type    = number
  default = 7
  validation {
    condition     = var.soft_delete_retention_days >= 7 && var.soft_delete_retention_days <= 90
    error_message = "Soft-delete retention must be between 7 and 90 days."
  }
}

variable "public_network_access_enabled" {
  description = "Keep true for dev. Restrict in prod via private endpoints."
  type        = bool
  default     = true
}

variable "grant_current_user_secrets_officer" {
  description = "If true, grant the identity running terraform 'Key Vault Secrets Officer'. Needed for downstream modules to write secrets."
  type        = bool
  default     = true
}

variable "tags" {
  type    = map(string)
  default = {}
}
