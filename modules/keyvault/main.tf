# --- Key Vault module ---
# Naming convention: kv-sdlc-{scope}-{env}
# Examples: kv-sdlc-base-dev, kv-sdlc-base-prod
#
# Uses RBAC authorization (not vault access policies) — modern approach.
# Secured by RBAC only — no private endpoint (Option B decision).
# Admins access via Azure Portal with their Azure AD account.
# FastAPI Managed Identity will be granted Key Vault Secrets User role separately.

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

resource "azurerm_key_vault" "this" {
  name                = "kv-sdlc-${var.scope}-${var.env}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id           = var.tenant_id
  sku_name            = "standard"

  # RBAC authorization — roles assigned via azurerm_role_assignment, not vault access policies.
  # This is the recommended approach as it integrates with Azure AD and is easier to audit.
  enable_rbac_authorization = true

  # Soft delete is mandatory in Azure — 7 days is the minimum allowed value, cannot be disabled.
  # Purge protection is disabled so deleted vaults can be purged immediately for R&D.
  # For prod this should be set to true — once enabled it cannot be disabled.
  soft_delete_retention_days = 7
  purge_protection_enabled   = false

  tags = var.tags
}
