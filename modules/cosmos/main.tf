# --- Cosmos DB module ---
# Naming convention: cosmos-sdlc-{scope}-{env}
# Examples: cosmos-sdlc-shared-dev, cosmos-sdlc-a3f1c2b4-dev
#
# Creates a Cosmos DB account with a NoSQL database and two containers:
#   - nodes: stores File, Function, Class, Method nodes (graph entities)
#   - edges: stores CALLS, IMPORTS, HAS_METHOD relationships
#
# Partition key is /chunk_id which follows the naming convention:
#   {resource_code}/{github_org}/{project}/{repo}/{file}/{symbol}
# This ensures all data for a tenant is co-located for fast queries.

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

resource "azurerm_cosmosdb_account" "this" {
  name                = "cosmos-sdlc-${var.scope}-${var.env}"
  location            = var.location
  resource_group_name = var.resource_group_name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"
  tags                = var.tags

  # Free tier — 1000 RU/s free per subscription
  # Switch to provisioned throughput for production
  free_tier_enabled = true

  # Disable key-based auth — Managed Identity only
  local_authentication_disabled = true

  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location          = var.location
    failover_priority = 0
  }
}

resource "azurerm_cosmosdb_sql_database" "sdlc" {
  name                = "sdlc"
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.this.name
}

# nodes container — stores graph entities (File, Function, Class, Method)
resource "azurerm_cosmosdb_sql_container" "nodes" {
  name                = "nodes"
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.this.name
  database_name       = azurerm_cosmosdb_sql_database.sdlc.name
  partition_key_paths = ["/resource_code"]
}

# edges container — stores relationships (CALLS, IMPORTS, HAS_METHOD)
resource "azurerm_cosmosdb_sql_container" "edges" {
  name                = "edges"
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.this.name
  database_name       = azurerm_cosmosdb_sql_database.sdlc.name
  partition_key_paths = ["/resource_code"]
}

# Grant managed identity read/write access — no keys needed
resource "azurerm_cosmosdb_sql_role_assignment" "data_contributor" {
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.this.name
  role_definition_id  = "${azurerm_cosmosdb_account.this.id}/sqlRoleDefinitions/00000000-0000-0000-0000-000000000002"
  principal_id        = var.managed_identity_principal_id
  scope               = azurerm_cosmosdb_account.this.id
}
