
resource "azurerm_windows_web_app" "azmmclientrg-webbapp-pp" {
  app_settings = {
    APPLICATIONINSIGHTS_CONNECTION_STRING      = "InstrumentationKey=e62501d5-31c1-45f2-a54e-8ea998494ed0;IngestionEndpoint=https://northeurope-2.in.applicationinsights.azure.com/;LiveEndpoint=https://northeurope.livediagnostics.monitor.azure.com/"
    ApplicationInsightsAgent_EXTENSION_VERSION = "~2"
    MM_DEFAULT_VERSION                         = "mmakerpp"
    MM_EXTENSION_VERSION                       = "n4-UL:g5aHw%et+Wt!r}i%$Hm6q4T%CupX2B8M)ftbco]*!?g%"
    WEBSITE_TIME_ZONE                          = "GMT Standard Time"
    XDT_MicrosoftApplicationInsights_Mode      = "default"
  }
  client_affinity_enabled   = true
  https_only                = true
  location                  = "northeurope"
  name                      = "pp-matchmakersoftware"
  resource_group_name       = "azmmclientapps"
  service_plan_id           = "/subscriptions/2bd29ed6-34a6-42d7-8235-293e8ee67447/resourceGroups/AZMMCoreRG01/providers/Microsoft.Web/serverFarms/AZMMASP02"
  virtual_network_subnet_id = "/subscriptions/2bd29ed6-34a6-42d7-8235-293e8ee67447/resourceGroups/AZMMCoreRG01/providers/Microsoft.Network/virtualNetworks/AZMMVNET01/subnets/AppSNET01"
  connection_string {
    name  = "mmakerConnString"
    type  = "SQLAzure"
    value = "data source=tcp:azmmsql01.database.windows.net;initial catalog=2179;persist security info=True;App=EntityFramework;Connection Timeout=60"
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
  sticky_settings {
    app_setting_names = ["WEBSITE_TIME_ZONE"]
  }
  depends_on = [
    azurerm_resource_group.azmmclientrg-0,
  ]
  
  lifecycle {
    ignore_changes = all
    prevent_destroy = true
  }

}
/**
resource "azurerm_app_service_custom_hostname_binding" "azmmclientrg-custombinding-webapp-pp1" {
  app_service_name    = "pp-matchmakersoftware"
  hostname            = "pp-matchmakersoftware.azurewebsites.net"
  resource_group_name = "azmmclientapps"
}
*/

resource "azurerm_app_service_custom_hostname_binding" "azmmclientrg-custombinding-webapp-pp2" {
  app_service_name    = "pp-matchmakersoftware"
  hostname            = "pp.matchmakersoftware.com"
  resource_group_name = "azmmclientapps"
  
}

resource "azurerm_app_service_certificate_binding" "azmmclientrg-custombinding-cert-webapp-pp2" {
  hostname_binding_id = azurerm_app_service_custom_hostname_binding.azmmclientrg-custombinding-webapp-pp2.id
  certificate_id      = azurerm_app_service_certificate.azmmclientrg-365.id
  ssl_state           = "SniEnabled"
}


resource "azurerm_monitor_smart_detector_alert_rule" "azmmclientrg-smartalert-webapp-pp" {
  description         = "Failure Anomalies notifies you of an unusual rise in the rate of failed HTTP requests or dependency calls."
  detector_type       = "FailureAnomaliesDetector"
  frequency           = "PT1M"
  name                = "Failure Anomalies - pp-matchmakersoftware"
  resource_group_name = "AZMMClientApps"
  scope_resource_ids  = ["/subscriptions/2bd29ed6-34a6-42d7-8235-293e8ee67447/resourcegroups/azmmclientapps/providers/microsoft.insights/components/pp-matchmakersoftware"]
  severity            = "Sev3"
  action_group {
    ids = ["/subscriptions/2bd29ed6-34a6-42d7-8235-293e8ee67447/resourceGroups/azmmcorerg01/providers/Microsoft.Insights/actionGroups/application insights smart detection"]
  }
  depends_on = [
    azurerm_resource_group.azmmclientrg-0,
  ]
}
resource "azurerm_application_insights" "azmmclientrg-appinsight-webapp-pp" {
  application_type    = "web"
  location            = "northeurope"
  name                = "pp-matchmakersoftware"
  resource_group_name = "AZMMClientApps"
  sampling_percentage = 0
  workspace_id        = "/subscriptions/2bd29ed6-34a6-42d7-8235-293e8ee67447/resourceGroups/DefaultResourceGroup-NEU/providers/Microsoft.OperationalInsights/workspaces/DefaultWorkspace-2bd29ed6-34a6-42d7-8235-293e8ee67447-NEU"
  depends_on = [
    azurerm_resource_group.azmmclientrg-0,
  ]
}