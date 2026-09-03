# --- Service Bus module ---
# Naming convention: sb-sdlc-{scope}-{env}
# Examples: sb-sdlc-shared-dev, sb-sdlc-a3f1c2b4-dev
#
# Creates:
#   1. Service Bus Namespace
#   2. repo-index queue — triggered when tenant registers repos via sdlc-config.
#      Indexing Worker picks up messages and builds the knowledge base
#      (AI Search vectors + Cosmos graph relationships).
#
# Additional queues (change-request, pr-feedback, repository-changed) are added
# when the SDLC orchestrator is built.

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

# repo-index queue — Indexing Worker reads from here to build the knowledge base.
# Triggered by FastAPI when a tenant's sdlc-config syncs new repos.
resource "azurerm_servicebus_queue" "repo_index" {
  name         = "repo-index"
  namespace_id = azurerm_servicebus_namespace.this.id

  # Lock duration: how long a message is reserved to one consumer before returning to queue.
  lock_duration = "PT5M"

  # Dead-letter after 3 failed deliveries — keeps bad messages from blocking the queue.
  max_delivery_count = 3

  # Retain messages for 7 days — failed indexing jobs can be retried or inspected.
  default_message_ttl = "P7D"
}

# Grant the managed identity Sender role — FastAPI enqueues repo-index messages here.
resource "azurerm_role_assignment" "servicebus_sender" {
  scope                = azurerm_servicebus_namespace.this.id
  role_definition_name = "Azure Service Bus Data Sender"
  principal_id         = var.managed_identity_principal_id
}

# Grant the managed identity Receiver role — Indexing Worker dequeues and processes messages.
resource "azurerm_role_assignment" "servicebus_receiver" {
  scope                = azurerm_servicebus_namespace.this.id
  role_definition_name = "Azure Service Bus Data Receiver"
  principal_id         = var.managed_identity_principal_id
}
