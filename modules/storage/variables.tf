# --- Storage Account module inputs ---
# Naming convention: stsdlc{scope}{env}

variable "scope" {
  description = "Scope — 'shared' or a tenant resource_code (e.g. 'a3f1c2b4'). Used in the storage account name."
  type        = string
}

variable "env" {
  description = "Environment: dev or prod."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group to create the Storage Account in."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "managed_identity_principal_id" {
  description = "Principal ID of the Managed Identity granted Storage Blob Data Contributor."
  type        = string
}

variable "replication_type" {
  description = "Storage replication type. LRS is cheapest — sufficient for dev and non-critical audit blobs."
  type        = string
  default     = "LRS"
}

variable "tags" {
  description = "Tags applied to all resources in this module."
  type        = map(string)
  default     = {}
}
