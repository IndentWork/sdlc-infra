# --- Managed Identity module outputs ---
# id         → used in RBAC role assignments (who gets the role)
# client_id  → used by FastAPI app config to tell Azure SDK which identity to use
# principal_id → used in azurerm_role_assignment as the principal receiving the role

output "id" {
  description = "Full resource ID of the Managed Identity."
  value       = azurerm_user_assigned_identity.this.id
}

output "principal_id" {
  description = "Object ID of the Managed Identity — used in RBAC role assignments."
  value       = azurerm_user_assigned_identity.this.principal_id
}

output "client_id" {
  description = "Client ID of the Managed Identity — used by FastAPI to specify which identity to authenticate with."
  value       = azurerm_user_assigned_identity.this.client_id
}
