# --- Container App module ---
# Naming convention:
#   Container App Environment : cae-sdlc-{scope}-{env}
#   Container App             : ca-sdlc-{scope}-{env}
#
# Creates two resources:
#   1. Container App Environment — the runtime platform, VNet-integrated
#   2. Container App — the actual app, with public ingress and Managed Identity attached
#
# The Managed Identity (id-sdlc-base-dev) is attached so the app can:
#   - Pull images from ACR (AcrPull role)
#   - Read secrets from Key Vault (Key Vault Secrets User role)
#   - Connect to PostgreSQL passwordlessly (AD administrator)
#
# Starts with a placeholder image — control-plane pipeline replaces it on first deploy
# using: az containerapp update --name ca-sdlc-base-dev --image newimage:tag

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

# Container App Environment — the VNet-integrated runtime platform.
# All Container Apps in the same environment share the same VNet integration.
resource "azurerm_container_app_environment" "this" {
  name                       = "cae-sdlc-${var.scope}-${var.env}"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  infrastructure_subnet_id   = var.subnet_id
  tags                       = var.tags

  # Azure auto-creates a companion ME_* resource group for the Container App Environment.
  # Terraform does not set this field but Azure writes it into state — ignore to prevent
  # forced replacement on every plan.
  lifecycle {
    ignore_changes = [infrastructure_resource_group_name]
  }
}

resource "azurerm_container_app" "this" {
  name                         = "ca-sdlc-${var.scope}-${var.env}"
  container_app_environment_id = azurerm_container_app_environment.this.id
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"
  tags                         = var.tags

  # The deploy pipeline updates the image after Terraform creates the Container App.
  # Ignore template changes so Terraform never reverts the image back to the placeholder.
  lifecycle {
    ignore_changes = [template]
  }

  # Attach the Managed Identity so the app authenticates to Azure services without credentials.
  identity {
    type         = "UserAssigned"
    identity_ids = [var.managed_identity_id]
  }

  # Tell the Container App to pull images from ACR using the Managed Identity.
  # Without this block, the Container App defaults to anonymous pulls and fails on private ACR.
  registry {
    server   = var.acr_login_server
    identity = var.managed_identity_id
  }

  # Public ingress on port 8000 — FastAPI default port.
  # This is the only public-facing resource in the entire platform.
  ingress {
    external_enabled = true
    target_port      = 8000

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  template {
    container {
      name   = "fastapi"
      image  = var.image
      cpu    = var.cpu
      memory = var.memory

      # AZURE_CLIENT_ID tells the Azure SDK which Managed Identity to use for token requests.
      # Without this, the SDK would fail if multiple identities are attached.
      env {
        name  = "AZURE_CLIENT_ID"
        value = var.managed_identity_client_id
      }

      # PostgreSQL hostname — FastAPI uses this to build the connection string.
      # Password is replaced by a token from the Managed Identity at connection time.
      env {
        name  = "POSTGRES_HOST"
        value = var.postgres_host
      }

      # Key Vault URI — FastAPI reads tenant codes and other secrets from here at startup.
      env {
        name  = "KEY_VAULT_URI"
        value = var.key_vault_uri
      }

      # Environment name — useful for logging and feature flags.
      env {
        name  = "ENV"
        value = var.env
      }
    }
  }
}
