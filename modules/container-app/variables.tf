# --- Container App module inputs ---
# Naming convention:
#   Container App Environment : cae-sdlc-{scope}-{env}
#   Container App             : ca-sdlc-{scope}-{env}
# Examples: cae-sdlc-base-dev, ca-sdlc-base-dev
#
# scope values:
#   "base"       → management plane FastAPI
#   "shared"     → shared tier indexing worker
#   "<org_code>" → dedicated tenant

variable "scope" {
  description = "Scope of this resource. Possible values: 'base' (management plane), 'shared' (shared tenant resources), or a tenant org_code (e.g. 'abc123') for dedicated tenants."
  type        = string
}

variable "env" {
  description = "Environment: dev or prod."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group to create the Container App in."
  type        = string
}

variable "location" {
  description = "Azure region (e.g. centralindia)."
  type        = string
}

variable "subnet_id" {
  description = "ID of the delegated subnet for Container Apps Environment (Microsoft.App/environments)."
  type        = string
}

variable "managed_identity_id" {
  description = "Resource ID of the Managed Identity — attached to Container App for AcrPull, Key Vault, and PostgreSQL passwordless access."
  type        = string
}

variable "managed_identity_client_id" {
  description = "Client ID of the Managed Identity — passed as AZURE_CLIENT_ID env var so the Azure SDK knows which identity to use."
  type        = string
}

variable "postgres_host" {
  description = "PostgreSQL hostname — passed to FastAPI as environment variable for DB connection."
  type        = string
}

variable "key_vault_uri" {
  description = "Key Vault URI — passed to FastAPI so it knows where to read secrets from."
  type        = string
}

variable "image" {
  description = "Container image to deploy. Defaults to placeholder — real image deployed by control-plane pipeline via az containerapp update."
  type        = string
  default     = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
}

variable "cpu" {
  description = "CPU allocated to the container (cores)."
  type        = number
  default     = 0.5
}

variable "memory" {
  description = "Memory allocated to the container."
  type        = string
  default     = "1Gi"
}

variable "tags" {
  description = "Tags applied to all resources in this module."
  type        = map(string)
  default     = {}
}
