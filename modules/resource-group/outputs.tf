# --- Resource Group module outputs ---
# Downstream modules (vnet, postgres, keyvault, container-app) all need
# the resource group name and location — they receive it from here.

output "name" {
  description = "Name of the resource group."
  value       = azurerm_resource_group.this.name
}

output "location" {
  description = "Azure region the resource group was created in."
  value       = azurerm_resource_group.this.location
}

output "id" {
  description = "Resource ID of the resource group."
  value       = azurerm_resource_group.this.id
}
