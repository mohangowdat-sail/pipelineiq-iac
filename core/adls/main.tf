data "azurerm_client_config" "current" {}

resource "azurerm_storage_account" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type
  account_kind             = "StorageV2"
  is_hns_enabled           = true

  min_tls_version                 = var.min_tls_version
  allow_nested_items_to_be_public = var.allow_nested_items_to_be_public

  blob_properties {
    versioning_enabled  = false
    change_feed_enabled = false
  }

  tags = var.tags
}

resource "azurerm_role_assignment" "current_user_blob_owner" {
  count = var.grant_current_user_blob_owner ? 1 : 0

  scope                = azurerm_storage_account.this.id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_storage_data_lake_gen2_filesystem" "this" {
  for_each = toset(var.containers)

  name               = each.value
  storage_account_id = azurerm_storage_account.this.id

  depends_on = [azurerm_role_assignment.current_user_blob_owner]
}
