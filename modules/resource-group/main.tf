# --- Resource Group module ---
# Naming convention: rg-sdlc-{scope}-{env}
# Examples: rg-sdlc-base-dev, rg-sdlc-shared-dev, rg-sdlc-abc123-dev
#
# Must be created first — all other modules in the same scope depend on this.

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

resource "azurerm_resource_group" "this" {
  name     = "rg-sdlc-${var.scope}-${var.env}"
  location = var.location
  tags     = var.tags
}
