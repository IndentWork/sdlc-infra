output "endpoint" {
  description = "Azure AI Search service endpoint URL"
  value       = "https://${azurerm_search_service.this.name}.search.windows.net"
}

output "name" {
  description = "Azure AI Search service name"
  value       = azurerm_search_service.this.name
}
