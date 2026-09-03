# --- Shared scope resources ---
# Shared data plane — used by all tier=shared tenants.
# All names follow the pattern: {resource}-sdlc-shared-{env}
# Apply with: terraform apply -var-file=environments/{env}/common.tfvars
#                             -var-file=environments/{env}/shared.tfvars
#                             -backend-config="key=shared.tfstate"

module "resource_group" {
  source   = "../../../modules/resource-group"
  scope    = "shared"
  env      = var.env
  location = var.location
  tags     = var.tags
}

module "vnet" {
  source              = "../../../modules/vnet"
  scope               = "shared"
  env                 = var.env
  location            = var.location
  resource_group_name = module.resource_group.name
  address_space       = [var.vnet_cidr]
  tags                = var.tags

  subnets = {
    # Reserved for private endpoints — no delegation required.
    # Public access is enabled for dev; private endpoints use this subnet in production.
    "snet-sdlc-shared-${var.env}-endpoints" = {
      address_prefix = var.endpoint_subnet_cidr
      delegation     = null
    }
  }
}

module "managed_identity" {
  source              = "../../../modules/managed-identity"
  scope               = "shared"
  env                 = var.env
  location            = var.location
  resource_group_name = module.resource_group.name
  tags                = var.tags
}

module "keyvault" {
  source              = "../../../modules/keyvault"
  scope               = "shared"
  env                 = var.env
  location            = var.location
  resource_group_name = module.resource_group.name
  tenant_id           = var.tenant_id
  tags                = var.tags
}

module "service_bus" {
  source              = "../../../modules/service-bus"
  scope               = "shared"
  env                 = var.env
  location            = var.location
  resource_group_name = module.resource_group.name
  tags                = var.tags

  managed_identity_principal_id = module.managed_identity.principal_id
}

module "storage" {
  source              = "../../../modules/storage"
  scope               = "shared"
  env                 = var.env
  location            = var.location
  resource_group_name = module.resource_group.name
  tags                = var.tags

  managed_identity_principal_id = module.managed_identity.principal_id
}

# --- VNet Peering ---
# Lookup the base VNet so shared workers can communicate with the control-plane API.
# Both directions must be created — Azure peering is not automatic in both directions.

data "azurerm_virtual_network" "base" {
  name                = "vnet-sdlc-base-${var.env}"
  resource_group_name = "rg-sdlc-base-${var.env}"
}

# Peering: shared → base
resource "azurerm_virtual_network_peering" "shared_to_base" {
  name                      = "peer-shared-to-base"
  resource_group_name       = module.resource_group.name
  virtual_network_name      = module.vnet.vnet_name
  remote_virtual_network_id = data.azurerm_virtual_network.base.id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = false
}

# Peering: base → shared (created here so both sides are managed in one apply)
resource "azurerm_virtual_network_peering" "base_to_shared" {
  name                      = "peer-base-to-shared"
  resource_group_name       = "rg-sdlc-base-${var.env}"
  virtual_network_name      = "vnet-sdlc-base-${var.env}"
  remote_virtual_network_id = module.vnet.vnet_id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = false
}


# Grant the base managed identity Sender access to the shared Service Bus.
# FastAPI (base) needs to enqueue messages on behalf of shared-tier tenants.
data "azurerm_user_assigned_identity" "base" {
  name                = "id-sdlc-base-${var.env}"
  resource_group_name = "rg-sdlc-base-${var.env}"
}

resource "azurerm_role_assignment" "base_mi_servicebus_sender" {
  scope                = module.service_bus.namespace_id
  role_definition_name = "Azure Service Bus Data Sender"
  principal_id         = data.azurerm_user_assigned_identity.base.principal_id
}

# Grant the shared managed identity AcrPull on the base Container Registry.
# Workers in the shared scope pull their Docker images from crsdlc{env} in base.
data "azurerm_container_registry" "base" {
  name                = "crsdlc${var.env}"
  resource_group_name = "rg-sdlc-base-${var.env}"
}

resource "azurerm_role_assignment" "shared_mi_acr_pull" {
  scope                = data.azurerm_container_registry.base.id
  role_definition_name = "AcrPull"
  principal_id         = module.managed_identity.principal_id
}
