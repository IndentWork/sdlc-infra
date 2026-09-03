# --- Dedicated scope resources ---
# One set of resources per dedicated tenant, named by resource_code (SHA256(github_org)[:8]).
# All names follow the pattern: {resource}-sdlc-{resource_code}-{env}
#
# Apply with: terraform apply -var-file=environments/{env}/common.tfvars
#                             -var-file=environments/{env}/{resource_code}.tfvars
#                             -backend-config="key={resource_code}.tfstate"
#
# Each dedicated tenant gets their own {resource_code}.tfvars with:
#   resource_code        = "a3f1c2b4"
#   vnet_cidr            = "10.2.0.0/16"
#   endpoint_subnet_cidr = "10.2.1.0/24"

module "resource_group" {
  source   = "../../../modules/resource-group"
  scope    = var.resource_code
  env      = var.env
  location = var.location
  tags     = var.tags
}

module "vnet" {
  source              = "../../../modules/vnet"
  scope               = var.resource_code
  env                 = var.env
  location            = var.location
  resource_group_name = module.resource_group.name
  address_space       = [var.vnet_cidr]
  tags                = var.tags

  subnets = {
    # Reserved for private endpoints — no delegation required.
    "snet-sdlc-${var.resource_code}-${var.env}-endpoints" = {
      address_prefix = var.endpoint_subnet_cidr
      delegation     = null
    }
  }
}

module "managed_identity" {
  source              = "../../../modules/managed-identity"
  scope               = var.resource_code
  env                 = var.env
  location            = var.location
  resource_group_name = module.resource_group.name
  tags                = var.tags
}

module "keyvault" {
  source              = "../../../modules/keyvault"
  scope               = var.resource_code
  env                 = var.env
  location            = var.location
  resource_group_name = module.resource_group.name
  tenant_id           = var.tenant_id
  tags                = var.tags
}

module "service_bus" {
  source              = "../../../modules/service-bus"
  scope               = var.resource_code
  env                 = var.env
  location            = var.location
  resource_group_name = module.resource_group.name
  tags                = var.tags

  managed_identity_principal_id = module.managed_identity.principal_id
}

module "storage" {
  source              = "../../../modules/storage"
  scope               = var.resource_code
  env                 = var.env
  location            = var.location
  resource_group_name = module.resource_group.name
  tags                = var.tags

  managed_identity_principal_id = module.managed_identity.principal_id
}

# --- VNet Peering ---
# Connects this tenant's dedicated VNet to the base VNet (control plane).

data "azurerm_virtual_network" "base" {
  name                = "vnet-sdlc-base-${var.env}"
  resource_group_name = "rg-sdlc-base-${var.env}"
}

# Peering: dedicated → base
resource "azurerm_virtual_network_peering" "dedicated_to_base" {
  name                      = "peer-${var.resource_code}-to-base"
  resource_group_name       = module.resource_group.name
  virtual_network_name      = module.vnet.vnet_name
  remote_virtual_network_id = data.azurerm_virtual_network.base.id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = false
}

# Peering: base → dedicated
resource "azurerm_virtual_network_peering" "base_to_dedicated" {
  name                      = "peer-base-to-${var.resource_code}"
  resource_group_name       = "rg-sdlc-base-${var.env}"
  virtual_network_name      = "vnet-sdlc-base-${var.env}"
  remote_virtual_network_id = module.vnet.vnet_id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = false
}

# Grant the base managed identity Sender access to this tenant's Service Bus.
# FastAPI (base) needs to enqueue messages on behalf of dedicated-tier tenants.
data "azurerm_user_assigned_identity" "base" {
  name                = "id-sdlc-base-${var.env}"
  resource_group_name = "rg-sdlc-base-${var.env}"
}

resource "azurerm_role_assignment" "base_mi_servicebus_sender" {
  scope                = module.service_bus.namespace_id
  role_definition_name = "Azure Service Bus Data Sender"
  principal_id         = data.azurerm_user_assigned_identity.base.principal_id
}
