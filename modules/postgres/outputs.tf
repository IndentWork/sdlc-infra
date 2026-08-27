# --- PostgreSQL module outputs ---
# hostname is passed to the FastAPI Container App as an environment variable.
# The app constructs the connection string using hostname + Managed Identity token.

output "hostname" {
  description = "Fully qualified hostname of the PostgreSQL server — used in connection strings."
  value       = azurerm_postgresql_flexible_server.this.fqdn
}

output "server_name" {
  description = "Name of the PostgreSQL server."
  value       = azurerm_postgresql_flexible_server.this.name
}

output "server_id" {
  description = "Resource ID of the PostgreSQL server."
  value       = azurerm_postgresql_flexible_server.this.id
}

output "database_name" {
  description = "Name of the application database that FastAPI connects to."
  value       = azurerm_postgresql_flexible_server_database.sdlc.name
}
