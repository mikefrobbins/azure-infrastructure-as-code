terraform {
  required_version = ">= 1.16.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.8"
    }
  }
}

provider "azurerm" {
  resource_providers_to_register = [
    "Microsoft.Compute",
    "Microsoft.Network",
  ]

  features {}
}
