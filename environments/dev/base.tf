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
