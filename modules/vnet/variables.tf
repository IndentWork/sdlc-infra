# --- VNet module inputs ---
# Naming convention: vnet-sdlc-{scope}-{env}
# Examples: vnet-sdlc-base-dev, vnet-sdlc-shared-dev, vnet-sdlc-abc123-dev
#
# scope + env are the only naming inputs — the module enforces the convention.
# Callers pass subnets as a map so this module works for base, shared, and private scopes.

variable "scope" {
  description = "Scope: base, shared, or a tenant org_code. Used in resource name."
  type        = string
}

variable "env" {
  description = "Environment: dev or prod."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group to create the VNet in."
  type        = string
}

variable "location" {
  description = "Azure region (e.g. centralindia)."
  type        = string
}

variable "address_space" {
  description = "Address space for the VNet (e.g. [\"10.0.0.0/16\"])."
  type        = list(string)
}

# Subnets is a map so callers can pass any number of subnets with any names.
# Each subnet can optionally have a delegation — Azure requires this for services
# like PostgreSQL Flexible Server and Container Apps that must own a subnet exclusively.
variable "subnets" {
  description = "Map of subnets to create inside the VNet."
  type = map(object({
    address_prefix = string

    # delegation is optional — only set for subnets that Azure services own exclusively.
    delegation = optional(object({
      name         = string       # arbitrary label, e.g. "postgres-delegation"
      service_name = string       # e.g. "Microsoft.DBforPostgreSQL/flexibleServers"
      actions      = list(string) # actions the service is allowed — listed in Azure docs per service
    }))
  }))
}

variable "tags" {
  description = "Tags applied to all resources in this module."
  type        = map(string)
  default     = {}
}
