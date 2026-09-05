output "endpoint" {
  description = "Cosmos DB account endpoint URL"
  value       = azurerm_cosmosdb_account.this.endpoint
}

output "account_name" {
  description = "Cosmos DB account name"
  value       = azurerm_cosmosdb_account.this.name
}
