variable "name" {
  description = "Function App name (3-60 chars, must be globally unique). Pattern: pipelineiq-functions-{env}."
  type        = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "log_analytics_workspace_id" {
  description = "Resource ID of the Log Analytics workspace to wire App Insights into."
  type        = string
}

variable "key_vault_id" {
  description = "Key Vault resource ID. Used for KV reference syntax in app settings."
  type        = string
}

variable "key_vault_uri" {
  description = "Key Vault URI (https://*.vault.azure.net/). Used in app-setting KV-reference URIs."
  type        = string
}

variable "storage_account_replication_type" {
  description = "Replication for the Function App's required runtime storage account."
  type        = string
  default     = "LRS"
}

variable "app_settings" {
  description = "Additional app settings (env vars exposed to the function). Merged with the runtime defaults."
  type        = map(string)
  default     = {}
}

variable "tags" {
  type    = map(string)
  default = {}
}
