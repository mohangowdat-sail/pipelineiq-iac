output "id" {
  value = azurerm_linux_function_app.this.id
}

output "name" {
  value = azurerm_linux_function_app.this.name
}

output "default_hostname" {
  description = "Public HTTPS hostname for the Function App."
  value       = azurerm_linux_function_app.this.default_hostname
}

output "principal_id" {
  description = "Object ID of the Function App's system-assigned managed identity. Use this when granting access to dependent resources."
  value       = azurerm_linux_function_app.this.identity[0].principal_id
}

output "tenant_id" {
  value = azurerm_linux_function_app.this.identity[0].tenant_id
}

output "application_insights_id" {
  value = azurerm_application_insights.this.id
}

output "application_insights_connection_string" {
  value     = azurerm_application_insights.this.connection_string
  sensitive = true
}

output "runtime_storage_account_name" {
  value = azurerm_storage_account.func_runtime.name
}
