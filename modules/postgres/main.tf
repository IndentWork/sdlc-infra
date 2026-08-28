# --- PostgreSQL Flexible Server module ---
# Naming convention: psql-sdlc-{scope}-{env}
# Examples: psql-sdlc-base-dev, psql-sdlc-base-prod
#
# Creates:
#   1. Private DNS Zone  — required for hostname resolution inside the VNet
#   2. DNS Zone VNet link — connects the DNS zone to the VNet
#   3. PostgreSQL Flexible Server — inside the delegated subnet
#   4. Azure AD administrator — sets Managed Identity as AD admin (passwordless access)
#
# The server admin password is passed in as a variable and stored in Key Vault by the caller.
# FastAPI connects using Managed Identity token — never uses the admin password.

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

# Private DNS Zone required by Azure when PostgreSQL Flexible Server is VNet-integrated.
# Without this, the hostname resolves to a public IP and connection is blocked.
resource "azurerm_private_dns_zone" "postgres" {
  name                = "psql-sdlc-${var.scope}-${var.env}.private.postgres.database.azure.com"
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# Link the DNS zone to the VNet so resources inside the VNet can resolve the hostname.
resource "azurerm_private_dns_zone_virtual_network_link" "postgres" {
  name                  = "dns-link-psql-sdlc-${var.scope}-${var.env}"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.postgres.name
  virtual_network_id    = var.vnet_id
  tags                  = var.tags
}

resource "azurerm_postgresql_flexible_server" "this" {
  name                   = "psql-sdlc-${var.scope}-${var.env}"
  location               = var.location
  resource_group_name    = var.resource_group_name
  version                = var.postgres_version
  delegated_subnet_id    = var.subnet_id
  private_dns_zone_id    = azurerm_private_dns_zone.postgres.id
  administrator_login    = var.admin_login
  administrator_password = var.admin_password
  zone                   = "1"

  storage_mb   = var.storage_mb
  sku_name     = var.sku_name

  # Must be false when using VNet integration — Azure does not allow both simultaneously.
  public_network_access_enabled = false

  # Azure AD auth enabled — Managed Identity connects without a password.
  # Password auth also enabled so the admin account works for emergency access.
  authentication {
    active_directory_auth_enabled = true
    password_auth_enabled         = true
    tenant_id                     = var.tenant_id
  }

  tags = var.tags

  depends_on = [azurerm_private_dns_zone_virtual_network_link.postgres]
}

# Set the Managed Identity as the Azure AD administrator of the PostgreSQL server.
# This is what allows FastAPI to connect using a token instead of a password.
#
# NOTE: Deletion of this resource via ARM is notoriously slow (30-90+ min).
# The destroy pipeline bypasses this by deleting the entire resource group directly.
resource "azurerm_postgresql_flexible_server_active_directory_administrator" "this" {
  server_name         = azurerm_postgresql_flexible_server.this.name
  resource_group_name = var.resource_group_name
  tenant_id           = var.tenant_id
  object_id           = var.managed_identity_principal_id
  principal_name      = "id-sdlc-${var.scope}-${var.env}"
  principal_type      = "ServicePrincipal"
}

# The application database — FastAPI and Alembic connect to this.
# PostgreSQL only creates the default 'postgres' DB — we must create 'sdlc' explicitly.
resource "azurerm_postgresql_flexible_server_database" "sdlc" {
  name      = "sdlc"
  server_id = azurerm_postgresql_flexible_server.this.id
  charset   = "UTF8"
  collation = "en_US.utf8"
}
