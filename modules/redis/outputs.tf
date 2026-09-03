# --- Redis Cache module outputs ---

output "hostname" {
  description = "Redis hostname — used by the app to connect."
  value       = azurerm_redis_cache.this.hostname
}

output "port" {
  description = "SSL port for Redis connections (6380)."
  value       = azurerm_redis_cache.this.ssl_port
}

output "id" {
  description = "Resource ID of the Redis Cache."
  value       = azurerm_redis_cache.this.id
}
