# --- Container Registry module ---
# Naming convention: crsdlc{env}  (no hyphens — Azure ACR naming rule)
# Examples: crsdlcdev, crsdlcprod
#
# Shared registry — all Container Apps across all scopes pull from here.
# Admin access disabled — images are pulled using Managed Identity (AcrPull role).
# This avoids static admin credentials entirely.

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

resource "azurerm_container_registry" "this" {
  name                = "crsdlc${var.env}"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku

  # Admin account disabled — Container Apps authenticate using Managed Identity (AcrPull role).
  # Never enable admin credentials — they are static and cannot be rotated automatically.
  admin_enabled = false

  tags = var.tags
}

# Grant Managed Identity AcrPull role so the Container App can pull images.
# AcrPull = pull images only — cannot push or manage the registry.
resource "azurerm_role_assignment" "acr_pull" {
  scope                = azurerm_container_registry.this.id
  role_definition_name = "AcrPull"
  principal_id         = var.managed_identity_principal_id
}
