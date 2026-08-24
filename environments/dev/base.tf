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
