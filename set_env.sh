#!/bin/bash
# Usage: source ./set_env.sh dev
# Exports ARM_* environment variables from sdlc_bootstrap/.env so Terraform
# can authenticate to Azure using the Terraform SP credentials.
# Must be sourced (not executed) so the exports stay in the current shell session.

ENV=${1:-dev}
ENV_UPPER=$(echo "$ENV" | tr '[:lower:]' '[:upper:]')
# BASH_SOURCE[0] gives the script path even when sourced — $0 gives the shell name when sourced
ENV_FILE="$(dirname "${BASH_SOURCE[0]}")/../sdlc_bootstrap/.env"

if [ ! -f "$ENV_FILE" ]; then
  echo "ERROR: .env file not found at $ENV_FILE"
  return 1
fi

# Source the .env file to load all variables
set -a
source "$ENV_FILE"
set +a

# Map SDLC_<ENV>_AZURE_*_TERRAFORM variables to ARM_* variables that Terraform expects
CLIENT_ID_VAR="SDLC_${ENV_UPPER}_AZURE_CLIENT_ID_TERRAFORM"
CLIENT_SECRET_VAR="SDLC_${ENV_UPPER}_AZURE_CLIENT_SECRET_TERRAFORM"
TENANT_ID_VAR="SDLC_${ENV_UPPER}_AZURE_TENANT_ID_TERRAFORM"
SUBSCRIPTION_ID_VAR="SDLC_${ENV_UPPER}_AZURE_SUBSCRIPTION_ID_TERRAFORM"

export ARM_CLIENT_ID="${!CLIENT_ID_VAR}"
export ARM_CLIENT_SECRET="${!CLIENT_SECRET_VAR}"
export ARM_TENANT_ID="${!TENANT_ID_VAR}"
export ARM_SUBSCRIPTION_ID="${!SUBSCRIPTION_ID_VAR}"

echo "ARM credentials set for environment: $ENV"
echo "  ARM_CLIENT_ID=$ARM_CLIENT_ID"
echo "  ARM_TENANT_ID=$ARM_TENANT_ID"
echo "  ARM_SUBSCRIPTION_ID=$ARM_SUBSCRIPTION_ID"
echo "  ARM_CLIENT_SECRET=***"
