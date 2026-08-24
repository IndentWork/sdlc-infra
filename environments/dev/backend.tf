# --- Terraform remote state backend ---
# State is stored in the Azure Storage Account created by sdlc_bootstrap.
# Storage account: stsdlcindentdev  (created by sdlc_bootstrap/create/01_create_storage.sh)
# Container: tfstate
# Key: dev.tfstate  (one state file per environment)
#
# Why remote state: allows multiple people and CI pipelines to share the same state,
# with locking so two applies never run at the same time.

terraform {
  backend "azurerm" {
    resource_group_name  = "rg-sdlc-terraform-dev"
    storage_account_name = "stsdlcindentdev"
    container_name       = "tfstate"
    key                  = "dev.tfstate"
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

# The azurerm provider authenticates using the Terraform SP credentials
# set as GitHub org secrets (SDLC_DEV_AZURE_*_TERRAFORM).
# When running locally, these must be exported as ARM_* environment variables.
# subscription_id is not set here — the provider reads it automatically from
# ARM_SUBSCRIPTION_ID environment variable set by the pipeline (or set_env.sh locally).
provider "azurerm" {
  features {}
}
