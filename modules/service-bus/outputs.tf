# --- Service Bus module outputs ---

output "namespace_id" {
  description = "Resource ID of the Service Bus namespace."
  value       = azurerm_servicebus_namespace.this.id
}

output "namespace_name" {
  description = "Name of the Service Bus namespace."
  value       = azurerm_servicebus_namespace.this.name
}

output "repo_index_queue_id" {
  description = "Resource ID of the repo-index queue."
  value       = azurerm_servicebus_queue.repo_index.id
}

output "repo_index_queue_name" {
  description = "Name of the repo-index queue."
  value       = azurerm_servicebus_queue.repo_index.name
}
