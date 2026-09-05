#!/bin/bash
# Bootstrap script — create Service Bus subscriptions with SQL filters
# Usage: ./scripts/bootstrap-subscriptions.sh dev
# This is a one-time setup script for each environment

set -e

if [ -z "$1" ]; then
  echo "Usage: $0 <environment>"
  echo "Example: $0 dev"
  exit 1
fi

ENV="$1"

# Derive resource names
SB_NAMESPACE="sb-sdlc-shared-${ENV}"
SB_RG="rg-sdlc-shared-${ENV}"
TOPIC_NAME="sdlc-events"

echo "🔍 Setting up Service Bus subscriptions in $SB_NAMESPACE..."

# Create tester subscription
echo "📬 Creating tester subscription..."
az servicebus topic subscription create \
  --resource-group "$SB_RG" \
  --namespace-name "$SB_NAMESPACE" \
  --topic-name "$TOPIC_NAME" \
  --name "tester" \
  --max-delivery-count 3 \
  --lock-duration PT5M 2>/dev/null || echo "  (already exists)"

# Add SQL filter rule to tester subscription
echo "🔍 Adding SQL filter to tester subscription..."
az servicebus topic subscription rule create \
  --resource-group "$SB_RG" \
  --namespace-name "$SB_NAMESPACE" \
  --topic-name "$TOPIC_NAME" \
  --subscription-name "tester" \
  --name "tester-action-filter" \
  --filter-sql-expression "action = 'test_storage' OR action = 'upload_sdlc'" 2>/dev/null || echo "  (already exists)"

# Create indexing subscription
echo "📬 Creating indexing subscription..."
az servicebus topic subscription create \
  --resource-group "$SB_RG" \
  --namespace-name "$SB_NAMESPACE" \
  --topic-name "$TOPIC_NAME" \
  --name "indexing" \
  --max-delivery-count 3 \
  --lock-duration PT5M 2>/dev/null || echo "  (already exists)"

# Add SQL filter rule to indexing subscription
echo "🔍 Adding SQL filter to indexing subscription..."
az servicebus topic subscription rule create \
  --resource-group "$SB_RG" \
  --namespace-name "$SB_NAMESPACE" \
  --topic-name "$TOPIC_NAME" \
  --subscription-name "indexing" \
  --name "indexing-action-filter" \
  --filter-sql-expression "action = 'upload_sdlc'" 2>/dev/null || echo "  (already exists)"

echo "✅ Service Bus subscriptions ready"
echo ""
echo "Topic: $TOPIC_NAME"
echo "Subscriptions:"
echo "  tester   — action = 'test_storage' OR action = 'upload_sdlc'"
echo "  indexing — action = 'upload_sdlc'"
echo "Environment: $ENV"
