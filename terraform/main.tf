terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.92.0"
    }
  }
  required_version = ">= 1.7.4"
}

provider "azurerm" {
  features {}

}
