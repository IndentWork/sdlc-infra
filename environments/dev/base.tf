# --- Base scope resources ---
# Calls modules for the base scope: management plane resources.
# Resources created here: resource group, VNet, PostgreSQL, Key Vault, FastAPI Container App.
# All names follow the pattern: {resource-prefix}-sdlc-base-{env}

module "resource_group" {
  source   = "../../modules/resource-group"
  scope    = "base"
  env      = var.env
  location = var.location
  tags     = var.tags
}

module "keyvault" {
  source              = "../../modules/keyvault"
  scope               = "base"
  env                 = var.env
  location            = var.location
  resource_group_name = module.resource_group.name
  tenant_id           = var.tenant_id
  tags                = var.tags
}

module "managed_identity" {
  source              = "../../modules/managed-identity"
  scope               = "base"
  env                 = var.env
  location            = var.location
  resource_group_name = module.resource_group.name
  tags                = var.tags
}

# Grant FastAPI Managed Identity read access to Key Vault secrets.
# Key Vault Secrets User = read only — FastAPI can get secrets but cannot create or delete them.
resource "azurerm_role_assignment" "fastapi_keyvault" {
  scope                = module.keyvault.vault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = module.managed_identity.principal_id
}

# Grant Terraform SP Secrets Officer access so it can write secrets (e.g. DB password) to Key Vault.
# Uses the current SP identity running the pipeline — data source reads it automatically.
data "azurerm_client_config" "current" {}

resource "azurerm_role_assignment" "terraform_keyvault" {
  scope                = module.keyvault.vault_id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

# Generate a random password for the PostgreSQL server admin.
# This is the emergency-only admin — FastAPI never uses this password.
# The password is stored in Key Vault immediately after generation.
resource "random_password" "postgres_admin" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# Import block — adopts the existing secret if it already exists in Azure but not in state.
# This happens when infra is destroyed and re-applied: state is cleared but KV soft-delete
# keeps the secret alive. On the next apply, Terraform imports it then updates the value.
import {
  to = azurerm_key_vault_secret.postgres_admin_password
  id = "https://kv-sdlc-base-dev.vault.azure.net/secrets/postgres-admin-password/e73e3bfe4090410da114d4e27f4bcce5"
}

# Store the admin password in Key Vault so admins can retrieve it for emergency access.
resource "azurerm_key_vault_secret" "postgres_admin_password" {
  name         = "postgres-admin-password"
  value        = random_password.postgres_admin.result
  key_vault_id = module.keyvault.vault_id

  depends_on = [azurerm_role_assignment.terraform_keyvault]
}

module "postgres" {
  source              = "../../modules/postgres"
  scope               = "base"
  env                 = var.env
  location            = var.location
  resource_group_name = module.resource_group.name
  subnet_id           = module.vnet.subnet_ids["snet-sdlc-base-${var.env}-postgres"]
  vnet_id             = module.vnet.vnet_id
  admin_password      = random_password.postgres_admin.result

  tenant_id                     = var.tenant_id
  managed_identity_principal_id = module.managed_identity.principal_id
  managed_identity_client_id    = module.managed_identity.client_id

  tags = var.tags
}

module "container_app" {
  source              = "../../modules/container-app"
  scope               = "base"
  env                 = var.env
  location            = var.location
  resource_group_name = module.resource_group.name
  subnet_id           = module.vnet.subnet_ids["snet-sdlc-base-${var.env}-container-app"]

  managed_identity_id        = module.managed_identity.id
  managed_identity_client_id = module.managed_identity.client_id

  acr_login_server = module.container_registry.login_server
  postgres_host    = module.postgres.hostname
  key_vault_uri    = module.keyvault.vault_uri

  tags = var.tags
}

module "container_registry" {
  source                        = "../../modules/container-registry"
  env                           = var.env
  location                      = var.location
  resource_group_name           = module.resource_group.name
  managed_identity_principal_id = module.managed_identity.principal_id
  tags                          = var.tags
}

module "vnet" {
  source              = "../../modules/vnet"
  scope               = "base"
  env                 = var.env
  location            = var.location
  resource_group_name = module.resource_group.name
  address_space       = ["10.0.0.0/16"]
  tags                = var.tags

  subnets = {
    # PostgreSQL Flexible Server requires a dedicated delegated subnet.
    # /24 gives 256 addresses — more than enough for a managed DB service.
    "snet-sdlc-base-${var.env}-postgres" = {
      address_prefix = "10.0.1.0/24"
      delegation = {
        name         = "postgres-delegation"
        service_name = "Microsoft.DBforPostgreSQL/flexibleServers"
        actions      = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
      }
    }

    # Container Apps Environment requires a dedicated delegated subnet.
    # /23 is the minimum recommended by Microsoft for Container Apps.
    "snet-sdlc-base-${var.env}-container-app" = {
      address_prefix = "10.0.2.0/23"
      delegation = {
        name         = "container-app-delegation"
        service_name = "Microsoft.App/environments"
        actions      = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
      }
    }
  }
}
