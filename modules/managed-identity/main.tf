# --- Managed Identity module ---
# Naming convention: id-sdlc-{scope}-{env}
# Examples: id-sdlc-base-dev, id-sdlc-base-prod
#
# Creates a User-Assigned Managed Identity.
# This identity is attached to the Container App so it can authenticate
# to Azure services (Key Vault, PostgreSQL) without any credentials or passwords.
#
# After creation, RBAC role assignments are made in base.tf:
#   - Key Vault Secrets User  → allows FastAPI to read secrets from Key Vault
#   - PostgreSQL AD user      → allows FastAPI to connect to DB without a password

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

resource "azurerm_user_assigned_identity" "this" {
  name                = "id-sdlc-${var.scope}-${var.env}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}
