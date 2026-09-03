# --- Environment variables ---
# Declared here, values supplied via {scope}.tfvars passed with -var-file at runtime.
# Every module call uses these to construct resource names.

variable "env" {
  description = "Environment name (dev or prod). Appended to all resource names."
  type        = string
}

variable "location" {
  description = "Azure region for all resources in this environment."
  type        = string
}

variable "tenant_id" {
  description = "Azure AD tenant ID — passed to Key Vault and PostgreSQL AAD auth."
  type        = string
}

variable "tags" {
  description = "Tags applied to all resources in this environment."
  type        = map(string)
  default     = {}
}

variable "resource_code" {
  description = "Tenant resource code — SHA256(github_org)[:8]. Used by dedicated.tf to name per-tenant Azure resources. Not used by base.tf or shared.tf."
  type        = string
  default     = ""
}

variable "vnet_cidr" {
  description = "CIDR block for the shared or dedicated VNet. Not used by base.tf (base uses a hardcoded range)."
  type        = string
  default     = ""
}

variable "endpoint_subnet_cidr" {
  description = "CIDR block for the private-endpoints subnet inside the shared or dedicated VNet."
  type        = string
  default     = ""
}
