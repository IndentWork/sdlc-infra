# --- Terraform remote state backend ---
# State is stored in the Azure Storage Account created by sdlc_bootstrap.
# Storage account is environment-specific: stsdlcindentdev (dev), stsdlcindentprod (prod).
# Container: tfstate
#
# The state file key is NOT set here — it is passed at runtime via -backend-config:
#   terraform init -backend-config="key=base.tfstate"
#   terraform init -backend-config="key=shared.tfstate"
#   terraform init -backend-config="key=a3f1c2b4.tfstate"
#
# This allows one backend.tf to serve all scopes (base, shared, dedicated tenants).

terraform {
  backend "azurerm" {
    resource_group_name  = "rg-sdlc-terraform-dev"
    storage_account_name = "stsdlcindentdev"
    container_name       = "tfstate"
    # key is passed at runtime — do not set here
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

# The azurerm provider authenticates using the Terraform SP credentials
# set as GitHub org secrets (SDLC_{ENV}_AZURE_*_TERRAFORM).
provider "azurerm" {
  features {}
}
