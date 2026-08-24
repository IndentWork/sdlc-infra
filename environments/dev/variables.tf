# --- Dev environment variables ---
# These are declared here and given values in terraform.tfvars.
# Every module call in this environment uses these to construct resource names.

variable "env" {
  description = "Environment name (dev or prod). Appended to all resource names."
  type        = string
}

variable "location" {
  description = "Azure region for all resources in this environment."
  type        = string
}

variable "tenant_id" {
  description = "Azure AD tenant ID — passed to Key Vault."
  type        = string
}

variable "tags" {
  description = "Tags applied to all resources in this environment."
  type        = map(string)
  default     = {}
}
