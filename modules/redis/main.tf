# --- Redis Cache module ---
# Naming convention: redis-sdlc-{scope}-{env}
# Examples: redis-sdlc-shared-dev, redis-sdlc-a3f1c2b4-dev
#
# Purpose:
#   - Hot workflow state between Handler A → B → C (SDLCState in memory)
#   - Cache for tenant sdlc.yml config (loaded from Storage blob on miss)
#
# Auth: Redis Basic/Standard uses access keys only — no Managed Identity support.
# The primary key is stored in Key Vault so the app reads it via Managed Identity
# without ever having the key in code or environment variables.
#
# SKU guide:
#   Basic C0  — 250MB, no SLA, no replication. Dev only.
#   Standard C1 — 1GB, SLA, replicated. Prod minimum.

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

resource "azurerm_redis_cache" "this" {
  name                = "redis-sdlc-${var.scope}-${var.env}"
  location            = var.location
  resource_group_name = var.resource_group_name
  capacity            = var.capacity
  family              = var.family
  sku_name            = var.sku_name
  tags                = var.tags

  # TLS only — no plaintext connections.
  minimum_tls_version = "1.2"

  redis_configuration {}
}

# Store the primary access key in Key Vault.
# The app reads this via Managed Identity — no key in code or env vars.
resource "azurerm_key_vault_secret" "redis_primary_key" {
  name         = "redis-primary-key"
  value        = azurerm_redis_cache.this.primary_access_key
  key_vault_id = var.key_vault_id
}
