terraform {
  backend "azurerm" {
    resource_group_name  = "rg-sdlc-terraform-dev"
    storage_account_name = "stsdlcindentdev"
    container_name       = "tfstate"
    # key is passed at runtime: -backend-config="key=base.tfstate"
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

provider "azurerm" {
  features {}
}
