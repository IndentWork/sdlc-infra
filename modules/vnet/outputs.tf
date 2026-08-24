# --- VNet module outputs ---
# Other modules (postgres, keyvault, container-app) need the VNet ID and subnet IDs
# to place themselves inside this network.

output "vnet_id" {
  description = "Resource ID of the virtual network."
  value       = azurerm_virtual_network.this.id
}

output "vnet_name" {
  description = "Name of the virtual network."
  value       = azurerm_virtual_network.this.name
}

# Returns a map of subnet_name → subnet_id.
# Callers look up by name: module.vnet.subnet_ids["snet-postgres"]
output "subnet_ids" {
  description = "Map of subnet name to subnet resource ID."
  value       = { for name, subnet in azurerm_subnet.this : name => subnet.id }
}
