# --- Resource Group module inputs ---
# scope + env together form the resource group name: rg-sdlc-{scope}-{env}
#
# scope values:
#   "base"       → rg-sdlc-base-dev       (management plane — FastAPI, PostgreSQL, Key Vault)
#   "shared"     → rg-sdlc-shared-dev     (shared tier tenant resources)
#   "<org_code>" → rg-sdlc-abc123-dev     (dedicated tenant — one RG per tenant)

variable "scope" {
  description = "Scope of this resource group: base, shared, or a tenant org_code."
  type        = string
}

variable "env" {
  description = "Environment: dev or prod."
  type        = string
}

variable "location" {
  description = "Azure region (e.g. centralindia)."
  type        = string
}

variable "tags" {
  description = "Tags applied to the resource group."
  type        = map(string)
  default     = {}
}
