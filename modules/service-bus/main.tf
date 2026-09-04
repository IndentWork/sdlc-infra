# --- Service Bus module ---
# Naming convention: sb-sdlc-{scope}-{env}
# Examples: sb-sdlc-shared-dev, sb-sdlc-a3f1c2b4-dev
#
# Creates only the Topic. Each worker creates its own subscription on startup
# with appropriate SQL filter. This avoids Terraform changes when adding new workers.

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

resource "azurerm_servicebus_namespace" "this" {
  name                = "sb-sdlc-${var.scope}-${var.env}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.sku
  tags                = var.tags
}

# Single topic — FastAPI publishes all messages here.
# Each worker creates its own subscription on startup with appropriate SQL filter.
resource "azurerm_servicebus_topic" "sdlc_events" {
  name                = "sdlc-events"
  namespace_id        = azurerm_servicebus_namespace.this.id
  default_message_ttl = "P7D"
}

# Grant the managed identity Sender role — FastAPI publishes to the topic.
resource "azurerm_role_assignment" "servicebus_sender" {
  scope                = azurerm_servicebus_namespace.this.id
  role_definition_name = "Azure Service Bus Data Sender"
  principal_id         = var.managed_identity_principal_id
}

# Grant the managed identity Receiver role — workers read from their subscriptions.
resource "azurerm_role_assignment" "servicebus_receiver" {
  scope                = azurerm_servicebus_namespace.this.id
  role_definition_name = "Azure Service Bus Data Receiver"
  principal_id         = var.managed_identity_principal_id
}
