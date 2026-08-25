# --- Container Registry module outputs ---
# login_server is used by:
#   - control-plane pipeline to push images: docker push {login_server}/control-plane:tag
#   - Container App to pull images: image = "{login_server}/control-plane:tag"

output "login_server" {
  description = "Login server URL (e.g. crsdlcdev.azurecr.io) — used for docker push and image references."
  value       = azurerm_container_registry.this.login_server
}

output "registry_id" {
  description = "Resource ID of the Container Registry."
  value       = azurerm_container_registry.this.id
}

output "registry_name" {
  description = "Name of the Container Registry."
  value       = azurerm_container_registry.this.name
}
