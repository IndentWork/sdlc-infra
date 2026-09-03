# --- Service Bus module inputs ---
# Naming convention: sb-sdlc-{scope}-{env}

variable "scope" {
  description = "Scope of this resource — 'shared' or a tenant resource_code (e.g. 'a3f1c2b4')."
  type        = string
}

variable "env" {
  description = "Environment: dev or prod."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group to create the Service Bus namespace in."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "managed_identity_principal_id" {
  description = "Principal ID of the Managed Identity granted Sender + Receiver roles on the namespace."
  type        = string
}

variable "sku" {
  description = "Service Bus SKU. Standard supports queues and topics. Premium adds VNet integration for private endpoints."
  type        = string
  default     = "Standard"
}

variable "tags" {
  description = "Tags applied to all resources in this module."
  type        = map(string)
  default     = {}
}
