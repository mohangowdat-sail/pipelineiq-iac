variable "name" {
  description = "Storage account name (globally unique, 3-24 chars, lowercase alphanumeric only)"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.name))
    error_message = "Storage account name must be 3-24 chars, lowercase alphanumeric only (no hyphens)."
  }
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "account_tier" {
  type    = string
  default = "Standard"
}

variable "account_replication_type" {
  type    = string
  default = "LRS"
}

variable "min_tls_version" {
  type    = string
  default = "TLS1_2"
}

variable "allow_nested_items_to_be_public" {
  type    = bool
  default = false
}

variable "containers" {
  description = "Filesystem (ADLS Gen2 container) names to create under the account"
  type        = list(string)
  default     = []
}

variable "grant_current_user_blob_owner" {
  description = "If true, grant running principal 'Storage Blob Data Owner' so Terraform can create filesystems without account keys."
  type        = bool
  default     = true
}

variable "tags" {
  type    = map(string)
  default = {}
}
