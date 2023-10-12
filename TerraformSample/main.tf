provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "example-tf-rg"
  location = "East US"
}