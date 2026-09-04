#!/bin/bash
# Bootstrap script — grant shared MI AcrPull access on base ACR
# Usage: ./scripts/bootstrap-acr-access.sh dev
# This is a one-time setup script for each environment

set -e

if [ -z "$1" ]; then
  echo "Usage: $0 <environment>"
  echo "Example: $0 dev"
  exit 1
fi

ENV="$1"
SUBSCRIPTION_ID="50e0c5b9-6745-44de-be51-ed9ece141ff5"

# Derive resource names from environment
ACR_NAME="crsdlc${ENV}"
ACR_RG="rg-sdlc-base-${ENV}"
SHARED_MI_NAME="id-sdlc-shared-${ENV}"
SHARED_MI_RG="rg-sdlc-shared-${ENV}"

echo "🔍 Looking up resources in $ENV environment..."

# Get the shared managed identity principal ID
SHARED_MI_PRINCIPAL=$(az identity show \
  --name "$SHARED_MI_NAME" \
  --resource-group "$SHARED_MI_RG" \
  --query principalId -o tsv 2>/dev/null)

if [ -z "$SHARED_MI_PRINCIPAL" ]; then
  echo "❌ Error: Could not find shared managed identity $SHARED_MI_NAME in $SHARED_MI_RG"
  exit 1
fi

echo "✓ Found shared MI principal: $SHARED_MI_PRINCIPAL"

# Get the ACR resource ID
ACR_RESOURCE=$(az acr show \
  --name "$ACR_NAME" \
  --resource-group "$ACR_RG" \
  --query id -o tsv 2>/dev/null)

if [ -z "$ACR_RESOURCE" ]; then
  echo "❌ Error: Could not find ACR $ACR_NAME in $ACR_RG"
  exit 1
fi

echo "✓ Found ACR resource: $ACR_RESOURCE"

# Check if role assignment already exists
EXISTING=$(az role assignment list \
  --assignee-object-id "$SHARED_MI_PRINCIPAL" \
  --role "AcrPull" \
  --scope "$ACR_RESOURCE" \
  --query "length(@)" -o tsv 2>/dev/null || echo "0")

if [ "$EXISTING" -gt 0 ]; then
  echo "✓ Role assignment already exists — no action needed"
  exit 0
fi

# Create the role assignment
echo "🔐 Granting AcrPull to shared MI on $ACR_NAME..."

az role assignment create \
  --role AcrPull \
  --assignee-object-id "$SHARED_MI_PRINCIPAL" \
  --assignee-principal-type ServicePrincipal \
  --scope "$ACR_RESOURCE" \
  --query "{role:roleDefinitionName, principal:principalId, scope:scope}" -o table

echo "✅ Successfully granted AcrPull access"
echo ""
echo "Resource: $ACR_NAME"
echo "Principal: $SHARED_MI_NAME ($SHARED_MI_PRINCIPAL)"
echo "Environment: $ENV"
