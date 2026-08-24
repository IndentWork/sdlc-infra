# --- Key Vault module outputs ---
# PostgreSQL module uses vault_id to store the DB password as a secret.
# FastAPI Container App uses vault_uri to read secrets at runtime.

output "vault_id" {
  description = "Resource ID of the Key Vault."
  value       = azurerm_key_vault.this.id
}

output "vault_uri" {
  description = "URI of the Key Vault (e.g. https://kv-sdlc-base-dev.vault.azure.net/)."
  value       = azurerm_key_vault.this.vault_uri
}

output "name" {
  description = "Name of the Key Vault."
  value       = azurerm_key_vault.this.name
}
