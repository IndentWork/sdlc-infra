# --- Container App module outputs ---
# name and fqdn are written to sdlc-shared config after terraform apply.
# control-plane pipeline uses name to deploy new images:
#   az containerapp update --name {name} --resource-group {rg} --image newimage:tag

output "name" {
  description = "Name of the Container App — used by control-plane pipeline for deployments."
  value       = azurerm_container_app.this.name
}

output "fqdn" {
  description = "Public FQDN of the Container App — the API endpoint tenants call."
  value       = azurerm_container_app.this.ingress[0].fqdn
}

output "environment_id" {
  description = "Resource ID of the Container App Environment."
  value       = azurerm_container_app_environment.this.id
}
