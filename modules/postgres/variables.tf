# --- PostgreSQL Flexible Server module inputs ---
# Naming convention: psql-sdlc-{scope}-{env}
# Examples: psql-sdlc-base-dev, psql-sdlc-base-prod
#
# scope values:
#   "base"       → psql-sdlc-base-dev       (tenant registry — shared by all tenants)
#   "<org_code>" → psql-sdlc-abc123-dev     (dedicated tenant — own PostgreSQL instance)

variable "scope" {
  description = "Scope of this resource. Possible values: 'base' (management plane), 'shared' (shared tenant resources), or a tenant org_code (e.g. 'abc123') for dedicated tenants."
  type        = string
}

variable "env" {
  description = "Environment: dev or prod."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group to create the PostgreSQL server in."
  type        = string
}

variable "location" {
  description = "Azure region (e.g. centralindia)."
  type        = string
}

variable "subnet_id" {
  description = "ID of the delegated subnet for PostgreSQL (Microsoft.DBforPostgreSQL/flexibleServers)."
  type        = string
}

variable "vnet_id" {
  description = "ID of the VNet — used to link the private DNS zone so hostnames resolve inside the VNet."
  type        = string
}

variable "admin_login" {
  description = "Username for the PostgreSQL server admin (emergency access only — app uses Managed Identity)."
  type        = string
  default     = "pgadmin"
}

variable "admin_password" {
  description = "Password for the PostgreSQL server admin. Stored in Key Vault — never used by the app."
  type        = string
  sensitive   = true
}

variable "tenant_id" {
  description = "Azure AD tenant ID — required for Azure AD authentication on PostgreSQL."
  type        = string
}

variable "managed_identity_principal_id" {
  description = "Principal ID of the Managed Identity to set as Azure AD administrator — enables passwordless access."
  type        = string
}

variable "managed_identity_client_id" {
  description = "Client ID of the Managed Identity — used to identify the AD admin in PostgreSQL."
  type        = string
}

variable "sku_name" {
  description = "PostgreSQL SKU. B_Standard_B1ms is the smallest — good for dev."
  type        = string
  default     = "B_Standard_B1ms"
}

variable "storage_mb" {
  description = "Storage in MB. 32768 = 32GB minimum for Flexible Server."
  type        = number
  default     = 32768
}

variable "postgres_version" {
  description = "PostgreSQL major version."
  type        = string
  default     = "16"
}

variable "tags" {
  description = "Tags applied to all resources in this module."
  type        = map(string)
  default     = {}
}
