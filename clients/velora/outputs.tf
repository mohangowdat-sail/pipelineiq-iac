output "resource_group_name" {
  value = data.azurerm_resource_group.this.name
}

output "location" {
  value = data.azurerm_resource_group.this.location
}

output "key_vault_id" {
  value = module.key_vault.id
}

output "key_vault_name" {
  value = module.key_vault.name
}

output "key_vault_uri" {
  value = module.key_vault.uri
}

output "log_analytics_workspace_id" {
  value = module.log_analytics.id
}

output "log_analytics_workspace_name" {
  value = module.log_analytics.name
}

output "adls_account_name" {
  value = module.adls.storage_account_name
}

output "adls_primary_dfs_endpoint" {
  value = module.adls.primary_dfs_endpoint
}

output "adls_filesystems" {
  value = module.adls.filesystem_ids
}
