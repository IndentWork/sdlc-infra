# --- VNet module ---
# Naming convention: vnet-sdlc-{scope}-{env}
# Examples: vnet-sdlc-base-dev, vnet-sdlc-shared-dev, vnet-sdlc-abc123-dev
#
# Reused for base, shared, and private (dedicated tenant) scopes.
# Caller decides the subnet layout via the subnets variable.

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

resource "azurerm_virtual_network" "this" {
  name                = "vnet-sdlc-${var.scope}-${var.env}"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.address_space
  tags                = var.tags
}

resource "azurerm_subnet" "this" {
  # for_each creates one subnet resource per entry in the subnets map.
  for_each = var.subnets

  name                 = each.key
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [each.value.address_prefix]

  # Only adds delegation block if the subnet config includes one.
  # Without delegation, Azure treats it as a plain subnet (for private endpoints etc.).
  dynamic "delegation" {
    for_each = each.value.delegation != null ? [each.value.delegation] : []
    content {
      name = delegation.value.name
      service_delegation {
        name    = delegation.value.service_name
        actions = delegation.value.actions
      }
    }
  }
}
