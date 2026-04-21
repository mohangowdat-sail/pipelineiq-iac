data "azurerm_resource_group" "this" {
  name = var.resource_group_name
}

locals {
  common_tags = {
    project     = "pipelineiq"
    environment = var.environment
    owner       = "data-engineering"
    managed_by  = "terraform"
    client      = "velora"
  }

  name_prefix = var.client_name
  name_suffix = var.environment
}

module "key_vault" {
  source = "../../core/keyvault"

  name                       = "${local.name_prefix}-kv-${local.name_suffix}"
  resource_group_name        = data.azurerm_resource_group.this.name
  location                   = data.azurerm_resource_group.this.location
  tenant_id                  = var.tenant_id
  purge_protection_enabled   = var.kv_purge_protection_enabled
  soft_delete_retention_days = 7

  tags = local.common_tags
}

module "log_analytics" {
  source = "../../core/log_analytics"

  name                = "${local.name_prefix}-logs-${local.name_suffix}"
  resource_group_name = data.azurerm_resource_group.this.name
  location            = data.azurerm_resource_group.this.location
  retention_days      = var.log_retention_days

  tags = local.common_tags
}

module "adls" {
  source = "../../core/adls"

  name                = "${local.name_prefix}adls${local.name_suffix}"
  resource_group_name = data.azurerm_resource_group.this.name
  location            = data.azurerm_resource_group.this.location
  containers          = ["landing", "bronze", "silver", "gold", "quarantine"]

  tags = local.common_tags
}
