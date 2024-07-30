resource "azurerm_service_plan" "res-13" {
  location            = "northeurope"
  name                = "AZMMASP01"
  os_type             = "Windows"
  resource_group_name = "AZMMCoreRG01"
  sku_name            = "S1"
  depends_on = [
    azurerm_resource_group.res-0,
  ]
}

resource "azurerm_service_plan" "webappsp2" {
  location            = "northeurope"
  name                = "AZMMASP02"
  os_type             = "Windows"
  resource_group_name = "AZMMCoreRG01"
  sku_name            = "P0v3"
  depends_on = [
    azurerm_resource_group.res-0,
  ]
}

resource "azurerm_service_plan" "webappsp3" {
  location            = "northeurope"
  name                = "AZMMASP03"
  os_type             = "Windows"
  resource_group_name = "AZMMCoreRG01"
  sku_name            = "S1"
  depends_on = [
    azurerm_resource_group.res-0,
  ]
}

resource "azurerm_service_plan" "webappsp4" {
  location            = "northeurope"
  name                = "AZMMASP04"
  os_type             = "Windows"
  resource_group_name = "AZMMCoreRG01"
  sku_name            = "P0v3"
  depends_on = [
    azurerm_resource_group.res-0,
  ]
}

resource "azurerm_service_plan" "webappsp5" {
  location            = "northeurope"
  name                = "AZMMASP05"
  os_type             = "Windows"
  resource_group_name = "AZMMCoreRG01"
  sku_name            = "S1"
  depends_on = [
    azurerm_resource_group.res-0,
  ]
}