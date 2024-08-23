resource "azurerm_windows_web_app" "azmmclientrg-182" {
  app_settings = {
    MM_DEFAULT_VERSION   = "mmakerdt"
    MM_EXTENSION_VERSION = "&)ku4\\92MxA_j|>*V,YS(@(#3=Ivs4<*0k^mwzpiS7JWe4QjC("
    WEBSITE_TIME_ZONE    = "GMT Standard Time"
  }
  client_affinity_enabled   = true
  https_only                = true
  location                  = "northeurope"
  name                      = "dt-matchmakersoftware"
  resource_group_name       = "AZMMClientApps"
  service_plan_id           = "/subscriptions/2bd29ed6-34a6-42d7-8235-293e8ee67447/resourceGroups/AZMMCoreRG01/providers/Microsoft.Web/serverFarms/AZMMASP01"
  virtual_network_subnet_id = "/subscriptions/2bd29ed6-34a6-42d7-8235-293e8ee67447/resourceGroups/AZMMCoreRG01/providers/Microsoft.Network/virtualNetworks/AZMMVNET01/subnets/AppSNET01"
  connection_string {
    name  = "mmakerConnString"
    type  = "SQLAzure"
    value = "data source=tcp:azmmsql01.database.windows.net;initial catalog=17009;persist security info=True;App=EntityFramework;Connection Timeout=60"
  }
  identity {
    type = "SystemAssigned"
  }
  logs {
    detailed_error_messages = true
  }
  site_config {
    ftps_state                    = "FtpsOnly"
    ip_restriction_default_action = "Deny"
    use_32_bit_worker             = false
    vnet_route_all_enabled        = true
    websockets_enabled            = true
    ip_restriction {
      description = "AccessFromAppGateway"
      priority    = 200
      service_tag = "GatewayManager"
    }
    ip_restriction {
      description = "Applicaiton Gateway FrontEnd"
      ip_address  = "98.71.72.6/32"
      priority    = 300
    }
    ip_restriction {
      description = "MatchMaker Office"
      ip_address  = "217.37.57.250/32"
      priority    = 400
    }
  }
  depends_on = [
    azurerm_resource_group.azmmclientrg-0,
  ]

  lifecycle {
    ignore_changes = all
    prevent_destroy = true
  }

}
resource "azurerm_app_service_custom_hostname_binding" "azmmclientrg-187" {
  app_service_name    = "dt-matchmakersoftware"
  hostname            = "dt-matchmakersoftware.azurewebsites.net"
  resource_group_name = "AZMMClientApps"
  depends_on = [
    azurerm_windows_web_app.azmmclientrg-182,
  ]
}
resource "azurerm_app_service_custom_hostname_binding" "azmmclientrg-188" {
  app_service_name    = "dt-matchmakersoftware"
  hostname            = "dt.matchmakersoftware.com"
  resource_group_name = "AZMMClientApps"
  depends_on = [
    azurerm_windows_web_app.azmmclientrg-182,
  ]
}
#changed for new branch
