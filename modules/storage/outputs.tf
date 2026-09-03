# --- Storage Account module outputs ---

output "account_id" {
  description = "Resource ID of the Storage Account."
  value       = azurerm_storage_account.this.id
}

output "account_name" {
  description = "Name of the Storage Account."
  value       = azurerm_storage_account.this.name
}

output "primary_blob_endpoint" {
  description = "Primary blob service endpoint URL."
  value       = azurerm_storage_account.this.primary_blob_endpoint
}
