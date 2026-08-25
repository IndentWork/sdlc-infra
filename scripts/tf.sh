#!/bin/bash
# tf.sh — Terraform helper for local runs
#
# Loads ARM_* credentials from sdlc_bootstrap/.env and runs terraform commands.
#
# Usage:
#   source ./tf.sh dev plan
#   source ./tf.sh dev apply
#   source ./tf.sh dev destroy
#   source ./tf.sh dev init
#
# Must be sourced (not executed) so ARM_* exports stay in your shell session.

ENV=$1
COMMAND=$2

if [ -z "$ENV" ] || [ -z "$COMMAND" ]; then
  echo "Usage: source ./tf.sh <env> <command>"
  echo "  env     : dev | prod"
  echo "  command : init | plan | apply | destroy"
  return 1
fi

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
ENV_DIR="$SCRIPT_DIR/../environments/$ENV"

if [ ! -d "$ENV_DIR" ]; then
  echo "ERROR: environment folder not found: $ENV_DIR"
  return 1
fi

# Load ARM_* credentials from sdlc_bootstrap/.env
echo "==> Loading credentials for environment: $ENV"
source "$SCRIPT_DIR/set_env.sh" "$ENV"

# Run the requested terraform command from the correct environment folder
echo "==> Running: terraform $COMMAND (environment: $ENV)"
cd "$ENV_DIR"

case "$COMMAND" in
  init)
    terraform init
    ;;
  plan)
    terraform init -reconfigure 2>/dev/null || terraform init
    terraform plan
    ;;
  apply)
    terraform init -reconfigure 2>/dev/null || terraform init
    terraform apply
    ;;
  destroy)
    terraform init -reconfigure 2>/dev/null || terraform init
    terraform destroy
    ;;
  *)
    echo "ERROR: Unknown command '$COMMAND'. Use: init | plan | apply | destroy"
    return 1
    ;;
esac
