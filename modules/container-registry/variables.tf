# --- Container Registry module inputs ---
# Naming convention: crsdlc{env}
# Examples: crsdlcdev, crsdlcprod
#
# ACR names must be globally unique, alphanumeric only, 5-50 chars — no hyphens allowed.
# This is why the naming pattern differs from other resources.
#
# ACR is shared across all scopes — base, shared, and dedicated tenant Container Apps
# all pull images from the same registry. So there is no {scope} in the name.

variable "env" {
  description = "Environment: dev or prod."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group to create the Container Registry in."
  type        = string
}

variable "location" {
  description = "Azure region (e.g. centralindia)."
  type        = string
}

variable "sku" {
  description = "ACR SKU. Basic is cheapest — good for dev. Standard needed for geo-replication. Premium for private endpoints."
  type        = string
  default     = "Basic"
}

variable "managed_identity_principal_id" {
  description = "Principal ID of the Managed Identity to grant AcrPull role — allows Container App to pull images without credentials."
  type        = string
}

variable "tags" {
  description = "Tags applied to the Container Registry."
  type        = map(string)
  default     = {}
}
