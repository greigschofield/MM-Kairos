resource "azurerm_service_plan" "res-13" {
  location            = "northeurope"
  name                = "AZMMASP01"
  os_type             = "Windows"
  resource_group_name = "AZMMCoreRG01"
  sku_name            = "P0v3"
  depends_on = [
    azurerm_resource_group.res-0,
  ]
}

resource "azurerm_service_plan" "webappsp2" {
  location            = "northeurope"
  name                = "AZMMASP02"
  os_type             = "Windows"
  resource_group_name = "AZMMCoreRG01"
  sku_name            = "P1v3"
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

resource "azurerm_service_plan" "webappsp6" {
  location            = "northeurope"
  name                = "AZMMASP06"
  os_type             = "Windows"
  resource_group_name = "AZMMCoreRG01"
  sku_name            = "P0v3"
  depends_on = [
    azurerm_resource_group.res-0,
  ]
}

resource "azurerm_service_plan" "webappsp7" {
  location            = "northeurope"
  name                = "AZMMASP07"
  os_type             = "Windows"
  resource_group_name = "AZMMCoreRG01"
  sku_name            = "S1"
  depends_on = [
    azurerm_resource_group.res-0,
  ]
}

resource "azurerm_service_plan" "webappsp8" {
  location            = "northeurope"
  name                = "AZMMASP08"
  os_type             = "Windows"
  resource_group_name = "AZMMCoreRG01"
  sku_name            = "S1"
  depends_on = [
    azurerm_resource_group.res-0,
  ]
}

resource "azurerm_service_plan" "webappsp9" {
  location            = "northeurope"
  name                = "AZMMASP09"
  os_type             = "Windows"
  resource_group_name = "AZMMCoreRG01"
 sku_name             = "P0v3"
  depends_on = [
    azurerm_resource_group.res-0,
  ]
}

resource "azurerm_service_plan" "webappsp10" {
  location            = "northeurope"
  name                = "AZMMASP10"
  os_type             = "Windows"
  resource_group_name = "AZMMCoreRG01"
 sku_name             = "S1"
  depends_on = [
    azurerm_resource_group.res-0,
  ]
}

resource "azurerm_service_plan" "webappsp11" {
  location            = "northeurope"
  name                = "AZMMASP11"
  os_type             = "Windows"
  resource_group_name = "AZMMCoreRG01"
 sku_name             = "P0v3"
  depends_on = [
    azurerm_resource_group.res-0,
  ]
}

resource "azurerm_service_plan" "webappsp12" {
  location            = "northeurope"
  name                = "AZMMASP12"
  os_type             = "Windows"
  resource_group_name = "AZMMCoreRG01"
 sku_name             = "S1"
  depends_on = [
    azurerm_resource_group.res-0,
  ]
}

resource "azurerm_service_plan" "webappsp13" {
  location            = "northeurope"
  name                = "AZMMASP13"
  os_type             = "Windows"
  resource_group_name = "AZMMCoreRG01"
  sku_name            = "P0v3"
  depends_on = [
    azurerm_resource_group.res-0,
  ]
}

resource "azurerm_service_plan" "webappsp14" {
  location            = "northeurope"
  name                = "AZMMASP14"
  os_type             = "Windows"
  resource_group_name = "AZMMCoreRG01"
 sku_name             = "S1"
  depends_on = [
    azurerm_resource_group.res-0,
  ]
}