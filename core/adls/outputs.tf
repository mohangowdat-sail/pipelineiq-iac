output "id" {
  value = azurerm_storage_account.this.id
}

output "storage_account_name" {
  value = azurerm_storage_account.this.name
}

output "primary_dfs_endpoint" {
  description = "ADLS Gen2 (Data Lake) endpoint (dfs.core.windows.net)"
  value       = azurerm_storage_account.this.primary_dfs_endpoint
}

output "primary_blob_endpoint" {
  value = azurerm_storage_account.this.primary_blob_endpoint
}

output "filesystem_ids" {
  value = { for k, v in azurerm_storage_data_lake_gen2_filesystem.this : k => v.id }
}
