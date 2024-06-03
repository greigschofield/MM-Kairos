resource "azurerm_resource_group" "azmmclientrg-0" {
  location = "northeurope"
  name     = "AZMMClientApps"
}

resource "azurerm_resource_group" "res-0" {
  location = "northeurope"
  name     = "AZMMCoreRG01"
}

