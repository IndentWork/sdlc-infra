# --- Service Bus module ---
# Naming convention: sb-sdlc-{scope}-{env}
# Examples: sb-sdlc-shared-dev, sb-sdlc-a3f1c2b4-dev
#
# Uses Topic + Subscription pattern.
# One topic (sdlc-events) receives all messages from FastAPI.
# Each worker has its own subscription with a SQL filter on the action property.
# Adding a new worker = add a new subscription — no downtime, no new topic needed.

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
# Service Bus routes to the correct subscription based on the action property.
resource "azurerm_servicebus_topic" "sdlc_events" {
  name                = "sdlc-events"
  namespace_id        = azurerm_servicebus_namespace.this.id
  default_message_ttl = "P7D"
}

# Tester subscription — receives test and upload actions only.
resource "azurerm_servicebus_subscription" "tester" {
  name               = "tester"
  topic_id           = azurerm_servicebus_topic.sdlc_events.id
  max_delivery_count = 3
  lock_duration      = "PT5M"
}

# SQL filter on the action application property set by FastAPI when publishing.
resource "azurerm_servicebus_subscription_rule" "tester_filter" {
  name            = "tester-action-filter"
  subscription_id = azurerm_servicebus_subscription.tester.id
  filter_type     = "SqlFilter"
  sql_filter      = "action = 'test_storage' OR action = 'upload_sdlc'"
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
