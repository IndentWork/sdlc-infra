# --- Storage Account module ---
# Naming convention: stsdlc{scope}{env}  (no hyphens — storage names are alphanumeric only)
# Examples: stsdlcshareddev, stsdlca3f1c2b4dev
#
# Creates:
#   1. Storage Account
#   2. audit-logs container  — full agent traces, plans, tool outputs, token/cost detail
#   3. checkpoints container — dormant workflow state serialised from Redis after inactivity
#
# The Managed Identity is granted Storage Blob Data Contributor so workers can
# read and write blobs without connection strings or account keys.

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

resource "azurerm_storage_account" "this" {
  # Storage account names: 3-24 chars, lowercase alphanumeric only, globally unique.
  # stsdlc{scope}{env} stays well under 24 chars for any 8-char resource_code.
  name                     = "stsdlc${var.scope}${var.env}"
  location                 = var.location
  resource_group_name      = var.resource_group_name
  account_tier             = "Standard"
  account_replication_type = var.replication_type
  tags                     = var.tags

  # Disable anonymous access — all reads require authentication.
  allow_nested_items_to_be_public = false
}

# Single container for all platform data.
# Path hierarchy inside: {resource_code}/{github_org}/{type}/...
# Adding new data types = new path prefix, zero Terraform changes.
#
# Examples:
#   {resource_code}/{github_org}/sdlc.yml
#   {resource_code}/{github_org}/index/{project}/{repo}/{file}.json
#   {resource_code}/{github_org}/audit/{...}
resource "azurerm_storage_container" "sdlc" {
  name                  = "sdlc"
  storage_account_name  = azurerm_storage_account.this.name
  container_access_type = "private"
}

# Grant the Managed Identity Blob Data Contributor — workers read and write blobs
# without connection strings. Key-based access is left enabled for emergency use.
resource "azurerm_role_assignment" "blob_contributor" {
  scope                = azurerm_storage_account.this.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = var.managed_identity_principal_id
}
