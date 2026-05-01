# ------------------------------------------------------------
# Storage account — required by the Functions runtime for triggers,
# logging, and binding state. Separate from the workload ADLS account.
# ------------------------------------------------------------

resource "azurerm_storage_account" "func_runtime" {
  # Storage account names: 3-24 lowercase + digits, globally unique.
  # Derive from the function name with non-alphanum stripped.
  name                = substr(replace(replace(lower(var.name), "-", ""), "_", ""), 0, 24)
  resource_group_name = var.resource_group_name
  location            = var.location

  account_tier             = "Standard"
  account_replication_type = var.storage_account_replication_type
  account_kind             = "StorageV2"

  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false

  tags = var.tags
}

# ------------------------------------------------------------
# App Service plan — Linux Consumption (Y1).
# ------------------------------------------------------------

resource "azurerm_service_plan" "this" {
  name                = "${var.name}-plan"
  resource_group_name = var.resource_group_name
  location            = var.location

  os_type  = "Linux"
  sku_name = "Y1" # Linux Consumption

  tags = var.tags
}

# ------------------------------------------------------------
# Application Insights — wired to the existing Log Analytics workspace.
# ------------------------------------------------------------

resource "azurerm_application_insights" "this" {
  name                = "${var.name}-ai"
  resource_group_name = var.resource_group_name
  location            = var.location
  application_type    = "web"
  workspace_id        = var.log_analytics_workspace_id

  tags = var.tags
}

# ------------------------------------------------------------
# Linux Function App — Python 3.11, system-assigned MSI.
# ------------------------------------------------------------

resource "azurerm_linux_function_app" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  service_plan_id            = azurerm_service_plan.this.id
  storage_account_name       = azurerm_storage_account.func_runtime.name
  storage_account_access_key = azurerm_storage_account.func_runtime.primary_access_key

  https_only = true

  identity {
    type = "SystemAssigned"
  }

  site_config {
    application_stack {
      python_version = "3.11"
    }

    application_insights_connection_string = azurerm_application_insights.this.connection_string
    application_insights_key               = azurerm_application_insights.this.instrumentation_key

    ftps_state = "Disabled"
  }

  app_settings = merge(
    {
      "FUNCTIONS_WORKER_RUNTIME"            = "python"
      "AzureWebJobsFeatureFlags"            = "EnableWorkerIndexing"
      "SCM_DO_BUILD_DURING_DEPLOYMENT"      = "true"
      "ENABLE_ORYX_BUILD"                   = "true"
      "PYTHON_ENABLE_WORKER_EXTENSIONS"     = "1"
      "KEY_VAULT_URI"                       = var.key_vault_uri
    },
    var.app_settings,
  )

  tags = var.tags
}

# ------------------------------------------------------------
# Grant the Function App's MSI read access to Key Vault secrets.
# ------------------------------------------------------------

resource "azurerm_role_assignment" "func_kv_secrets_user" {
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_linux_function_app.this.identity[0].principal_id
}
