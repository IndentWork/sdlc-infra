# --- Managed Identity module inputs ---
# Naming convention: id-sdlc-{scope}-{env}
# Examples: id-sdlc-base-dev, id-sdlc-base-prod
#
# scope values:
#   "base"       → id-sdlc-base-dev       (FastAPI management API identity)
#   "shared"     → id-sdlc-shared-dev     (indexing worker identity)
#   "<org_code>" → id-sdlc-abc123-dev     (dedicated tenant identity)

variable "scope" {
  description = "Scope of this resource. Possible values: 'base' (management plane), 'shared' (shared tenant resources), or a tenant org_code (e.g. 'abc123') for dedicated tenants."
  type        = string
}

variable "env" {
  description = "Environment: dev or prod."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group to create the Managed Identity in."
  type        = string
}

variable "location" {
  description = "Azure region (e.g. centralindia)."
  type        = string
}

variable "tags" {
  description = "Tags applied to the Managed Identity."
  type        = map(string)
  default     = {}
}
