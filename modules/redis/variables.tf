# --- Redis Cache module inputs ---

variable "scope" {
  description = "Scope — 'shared' or a tenant resource_code (e.g. 'a3f1c2b4')."
  type        = string
}

variable "env" {
  description = "Environment: dev or prod."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group to create the Redis Cache in."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "key_vault_id" {
  description = "Key Vault ID where the Redis primary key is stored as a secret."
  type        = string
}

variable "sku_name" {
  description = "Redis SKU. Basic = dev only (no SLA). Standard = prod (replicated, SLA)."
  type        = string
  default     = "Basic"
}

variable "family" {
  description = "SKU family. C = Basic/Standard. P = Premium."
  type        = string
  default     = "C"
}

variable "capacity" {
  description = "Cache size. 0 = 250MB (C0). 1 = 1GB (C1). Use 0 for dev."
  type        = number
  default     = 0
}

variable "tags" {
  description = "Tags applied to all resources in this module."
  type        = map(string)
  default     = {}
}
