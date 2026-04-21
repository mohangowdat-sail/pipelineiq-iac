variable "name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "sku" {
  description = "Pricing tier. PerGB2018 is the modern default; legacy tiers deprecated."
  type        = string
  default     = "PerGB2018"
}

variable "retention_days" {
  description = "Data retention in days (30-730)"
  type        = number
  default     = 30

  validation {
    condition     = var.retention_days >= 30 && var.retention_days <= 730
    error_message = "Log Analytics retention must be between 30 and 730 days."
  }
}

variable "daily_quota_gb" {
  description = "Daily ingestion cap in GB. -1 = unlimited."
  type        = number
  default     = -1
}

variable "tags" {
  type    = map(string)
  default = {}
}
