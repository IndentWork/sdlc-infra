# --- Azure AI Search module ---
# Naming convention: srch-sdlc-{scope}-{env}
# Examples: srch-sdlc-shared-dev, srch-sdlc-a3f1c2b4-dev
#
# Creates an Azure AI Search service.
# The indexing worker upserts code chunks here.
# Agents query this service for semantic code search.
#
# Free tier (F): 50MB storage, 3 indexes — sufficient for dev/testing
# Switch to Basic or Standard for production workloads.

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

resource "azurerm_search_service" "this" {
  name                = "srch-sdlc-${var.scope}-${var.env}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "free"
  tags                = var.tags

  # Disable key-based auth — Managed Identity only
  local_authentication_enabled  = false
  authentication_failure_mode   = "http403"
}

# Grant managed identity Search Index Data Contributor role
# Allows the worker to create, update, and delete index documents
resource "azurerm_role_assignment" "search_index_contributor" {
  scope                = azurerm_search_service.this.id
  role_definition_name = "Search Index Data Contributor"
  principal_id         = var.managed_identity_principal_id
}

# Grant managed identity Search Service Contributor role
# Allows the worker to create and manage indexes
resource "azurerm_role_assignment" "search_service_contributor" {
  scope                = azurerm_search_service.this.id
  role_definition_name = "Search Service Contributor"
  principal_id         = var.managed_identity_principal_id
}
