#!/bin/bash
# Bootstrap script — create worker Container Apps with correct configuration.
# Usage: ./scripts/bootstrap-workers.sh dev
# Run this once per environment after base and shared Terraform applies.
#
# Creates:
#   ca-sdlc-tester-{env}   — test worker (Service Bus → Storage)
#   ca-sdlc-indexing-{env} — indexing worker (repos → AI Search + Cosmos DB)
#
# Key points:
#   - AZURE_CLIENT_ID is set to clientId (NOT principalId) of the shared MI
#   - min-replicas=0 for indexing (scales to zero when idle)
#   - min-replicas=1 for tester (always ready for tests)
#   - Placeholder image used — deploy pipeline updates it

set -e

if [ -z "$1" ]; then
  echo "Usage: $0 <environment>"
  echo "Example: $0 dev"
  exit 1
fi

ENV="$1"

# Derive resource names from environment
SHARED_MI_NAME="id-sdlc-shared-${ENV}"
SHARED_MI_RG="rg-sdlc-shared-${ENV}"
BASE_RG="rg-sdlc-base-${ENV}"
CAE="cae-sdlc-base-${ENV}"
SB_NAMESPACE="sb-sdlc-shared-${ENV}.servicebus.windows.net"
KV_URL="https://kv-sdlc-base-${ENV}.vault.azure.net"
ACR_SERVER="crsdlc${ENV}.azurecr.io"

echo "🔍 Looking up shared managed identity for $ENV environment..."

# Get BOTH ids — clientId for authentication, resource id for assignment
SHARED_MI_CLIENT_ID=$(az identity show \
  --name "$SHARED_MI_NAME" \
  --resource-group "$SHARED_MI_RG" \
  --query clientId -o tsv)

SHARED_MI_RESOURCE_ID=$(az identity show \
  --name "$SHARED_MI_NAME" \
  --resource-group "$SHARED_MI_RG" \
  --query id -o tsv)

GITHUB_APP_ID="4826692"

echo "✓ Shared MI client ID: $SHARED_MI_CLIENT_ID"
echo "✓ Shared MI resource ID: $SHARED_MI_RESOURCE_ID"

# ── Tester Worker ─────────────────────────────────────────────────────────────

TESTER_APP="ca-sdlc-tester-${ENV}"
echo ""
echo "📦 Creating $TESTER_APP..."

az containerapp create \
  --name "$TESTER_APP" \
  --resource-group "$BASE_RG" \
  --environment "$CAE" \
  --image mcr.microsoft.com/azuredocs/containerapps-helloworld:latest \
  --min-replicas 1 \
  --max-replicas 1 \
  --user-assigned "$SHARED_MI_RESOURCE_ID" \
  --env-vars \
    SERVICEBUS_NAMESPACE="$SB_NAMESPACE" \
    ENV="$ENV" \
    AZURE_CLIENT_ID="$SHARED_MI_CLIENT_ID" \
  2>/dev/null || echo "  (already exists — updating env vars)"

# Update env vars in case it already existed with wrong values
az containerapp update \
  --name "$TESTER_APP" \
  --resource-group "$BASE_RG" \
  --set-env-vars \
    SERVICEBUS_NAMESPACE="$SB_NAMESPACE" \
    ENV="$ENV" \
    AZURE_CLIENT_ID="$SHARED_MI_CLIENT_ID" \
  --output none

# Configure ACR registry auth
az containerapp registry set \
  --name "$TESTER_APP" \
  --resource-group "$BASE_RG" \
  --server "$ACR_SERVER" \
  --identity "$SHARED_MI_RESOURCE_ID" \
  --output none

echo "✅ $TESTER_APP ready"

# ── Indexing Worker ───────────────────────────────────────────────────────────

INDEXING_APP="ca-sdlc-indexing-${ENV}"
echo ""
echo "📦 Creating $INDEXING_APP..."

az containerapp create \
  --name "$INDEXING_APP" \
  --resource-group "$BASE_RG" \
  --environment "$CAE" \
  --image mcr.microsoft.com/azuredocs/containerapps-helloworld:latest \
  --min-replicas 0 \
  --max-replicas 3 \
  --user-assigned "$SHARED_MI_RESOURCE_ID" \
  --env-vars \
    SERVICEBUS_NAMESPACE="$SB_NAMESPACE" \
    GITHUB_APP_ID="$GITHUB_APP_ID" \
    KEY_VAULT_URL="$KV_URL" \
    ENV="$ENV" \
    AZURE_CLIENT_ID="$SHARED_MI_CLIENT_ID" \
  2>/dev/null || echo "  (already exists — updating env vars)"

# Update env vars in case it already existed with wrong values
az containerapp update \
  --name "$INDEXING_APP" \
  --resource-group "$BASE_RG" \
  --set-env-vars \
    SERVICEBUS_NAMESPACE="$SB_NAMESPACE" \
    GITHUB_APP_ID="$GITHUB_APP_ID" \
    KEY_VAULT_URL="$KV_URL" \
    ENV="$ENV" \
    AZURE_CLIENT_ID="$SHARED_MI_CLIENT_ID" \
  --output none

# Configure ACR registry auth
az containerapp registry set \
  --name "$INDEXING_APP" \
  --resource-group "$BASE_RG" \
  --server "$ACR_SERVER" \
  --identity "$SHARED_MI_RESOURCE_ID" \
  --output none

echo "✅ $INDEXING_APP ready"

echo ""
echo "✅ All worker Container Apps ready for $ENV"
echo ""
echo "Next steps:"
echo "  1. Deploy images via GitHub Actions deploy pipelines"
echo "  2. Run bootstrap-subscriptions.sh $ENV to create Service Bus subscriptions"
