terraform {
  backend "azurerm" {}

  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "1.6.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.40"
    }
    random = {
      source = "hashicorp/random"
    }
  }
}

data "azurerm_subnet" "subnet_a" {
  name                 = "core-infra-subnet-0-${var.env}"
  virtual_network_name = "core-infra-vnet-${var.env}"
  resource_group_name  = "core-infra-${var.env}"
}
