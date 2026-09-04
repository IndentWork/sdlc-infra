# --- Service Bus module outputs ---

output "namespace_id" {
  description = "Resource ID of the Service Bus namespace."
  value       = azurerm_servicebus_namespace.this.id
}

output "namespace_name" {
  description = "Name of the Service Bus namespace."
  value       = azurerm_servicebus_namespace.this.name
}

output "topic_id" {
  description = "Resource ID of the sdlc-events topic."
  value       = azurerm_servicebus_topic.sdlc_events.id
}

output "topic_name" {
  description = "Name of the sdlc-events topic."
  value       = azurerm_servicebus_topic.sdlc_events.name
}
