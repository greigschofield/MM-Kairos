resource "azurerm_monitor_smart_detector_alert_rule" "res-0" {
  description         = "Failure Anomalies notifies you of an unusual rise in the rate of failed HTTP requests or dependency calls."
  detector_type       = "FailureAnomaliesDetector"
  frequency           = "PT1M"
  name                = "Failure Anomalies - lta-matchmakersoftware"
  resource_group_name = "AZMMClientApps"
  scope_resource_ids  = ["/subscriptions/2bd29ed6-34a6-42d7-8235-293e8ee67447/resourcegroups/azmmclientapps/providers/microsoft.insights/components/lta-matchmakersoftware"]
  severity            = "Sev3"
  action_group {
    ids = ["/subscriptions/2bd29ed6-34a6-42d7-8235-293e8ee67447/resourceGroups/azmmcorerg01/providers/Microsoft.Insights/actionGroups/application insights smart detection"]
  }
}
resource "azurerm_application_insights" "res-1" {
  application_type    = "web"
  location            = "northeurope"
  name                = "lta-matchmakersoftware"
  resource_group_name = "AZMMClientApps"
  sampling_percentage = 0
  workspace_id        = "/subscriptions/2bd29ed6-34a6-42d7-8235-293e8ee67447/resourceGroups/DefaultResourceGroup-NEU/providers/Microsoft.OperationalInsights/workspaces/DefaultWorkspace-2bd29ed6-34a6-42d7-8235-293e8ee67447-NEU"
  depends_on = [
    azurerm_log_analytics_workspace.res-127,
  ]
}
resource "azurerm_key_vault" "res-2" {
  location            = "northeurope"
  name                = "AZMMKV01"
  resource_group_name = "AZMMCoreRG01"
  sku_name            = "standard"
  tenant_id           = "3a243d17-3d9f-43e2-96a9-222d4b6fada1"
  /** greig */
}
resource "azurerm_key_vault_certificate" "res-3" {
  key_vault_id = "/subscriptions/2bd29ed6-34a6-42d7-8235-293e8ee67447/resourceGroups/AZMMCoreRG01/providers/Microsoft.KeyVault/vaults/AZMMKV01"
  name         = "MMWildcardKV2024"
  certificate_policy {
    issuer_parameters {
      name = "Unknown"
    }
    key_properties {
      exportable = true
      key_type   = "RSA"
      reuse_key  = false
    }
    lifetime_action {
      action {
        action_type = "EmailContacts"
      }
      trigger {
        lifetime_percentage = 80
      }
    }
    secret_properties {
      content_type = "application/x-pkcs12"
    }
  }
  depends_on = [
    azurerm_key_vault.res-2,
  ]
}
resource "azurerm_user_assigned_identity" "res-4" {
  location            = "uksouth"
  name                = "AppGWManagedID"
  resource_group_name = "AZMMCoreRG01"
}
resource "azurerm_application_gateway" "res-5" {
  enable_http2        = true
  location            = "northeurope"
  name                = "AZMMAGW01"
  resource_group_name = "AZMMCoreRG01"
  backend_address_pool {
    fqdns = ["applehealth-matchmakersoftware.azurewebsites.net"]
    name  = "applehealth-backendpool"
  }
  backend_address_pool {
    fqdns = ["dt-matchmakersoftware.azurewebsites.net"]
    name  = "dt-backendpool"
  }
  backend_address_pool {
    fqdns = ["lta-matchmakersoftware.azurewebsites.net"]
    name  = "lta-backendpool"
  }
  backend_http_settings {
    affinity_cookie_name  = "ApplicationGatewayAffinity"
    cookie_based_affinity = "Enabled"
    name                  = "applehealth-backendsetting"
    port                  = 443
    probe_name            = "applehealth-healthprobe"
    protocol              = "Https"
    request_timeout       = 20
  }
  backend_http_settings {
    affinity_cookie_name  = "ApplicationGatewayAffinity"
    cookie_based_affinity = "Enabled"
    name                  = "dt-backendsetting"
    port                  = 443
    probe_name            = "dt-healthprobe"
    protocol              = "Https"
    request_timeout       = 20
  }
  backend_http_settings {
    affinity_cookie_name  = "ApplicationGatewayAffinity"
    cookie_based_affinity = "Enabled"
    name                  = "lta-backendsetting"
    port                  = 443
    probe_name            = "lta-healthprobe"
    protocol              = "Https"
    request_timeout       = 20
  }
  frontend_ip_configuration {
    name                 = "appGwPublicFrontendIpIPv4"
    public_ip_address_id = "/subscriptions/2bd29ed6-34a6-42d7-8235-293e8ee67447/resourceGroups/AZMMCoreRG01/providers/Microsoft.Network/publicIPAddresses/AZMMAGW01PIP"
  }
  frontend_port {
    name = "port_443"
    port = 443
  }
  frontend_port {
    name = "port_80"
    port = 80
  }
  gateway_ip_configuration {
    name      = "appGatewayIpConfig"
    subnet_id = "/subscriptions/2bd29ed6-34a6-42d7-8235-293e8ee67447/resourceGroups/AZMMCoreRG01/providers/Microsoft.Network/virtualNetworks/AZMMVNET01/subnets/AGWSNET01"
  }
  http_listener {
    frontend_ip_configuration_name = "appGwPublicFrontendIpIPv4"
    frontend_port_name             = "port_443"
    host_name                      = "applehealth.matchmakersoftware.com"
    name                           = "applehealth-listenerhttps"
    protocol                       = "Https"
    require_sni                    = true
    ssl_certificate_name           = "MMWildcard2024"
  }
  http_listener {
    frontend_ip_configuration_name = "appGwPublicFrontendIpIPv4"
    frontend_port_name             = "port_443"
    host_name                      = "dt.matchmakersoftware.com"
    name                           = "dt-listenerhttps"
    protocol                       = "Https"
    require_sni                    = true
    ssl_certificate_name           = "MMWildcard2024"
  }
  http_listener {
    frontend_ip_configuration_name = "appGwPublicFrontendIpIPv4"
    frontend_port_name             = "port_443"
    host_name                      = "lta.matchmakersoftware.com"
    name                           = "lta-listenerhttps"
    protocol                       = "Https"
    require_sni                    = true
    ssl_certificate_name           = "MMWildcard2024"
  }
  identity {
    identity_ids = ["/subscriptions/2bd29ed6-34a6-42d7-8235-293e8ee67447/resourceGroups/AZMMCoreRG01/providers/Microsoft.ManagedIdentity/userAssignedIdentities/AppGWManagedID"]
    type         = "UserAssigned"
  }
  probe {
    host                = "applehealth-matchmakersoftware.azurewebsites.net"
    interval            = 30
    name                = "applehealth-healthprobe"
    path                = "/"
    protocol            = "Https"
    timeout             = 30
    unhealthy_threshold = 3
    match {
      status_code = []
    }
  }
  probe {
    host                = "dt-matchmakersoftware.azurewebsites.net"
    interval            = 30
    name                = "dt-healthprobe"
    path                = "/"
    protocol            = "Https"
    timeout             = 30
    unhealthy_threshold = 3
    match {
      status_code = ["200-399"]
    }
  }
  probe {
    host                = "lta-matchmakersoftware.azurewebsites.net"
    interval            = 30
    name                = "lta-healthprobe"
    path                = "/"
    protocol            = "Https"
    timeout             = 30
    unhealthy_threshold = 3
    match {
      status_code = ["200-399"]
    }
  }
  request_routing_rule {
    backend_address_pool_name  = "applehealth-backendpool"
    backend_http_settings_name = "applehealth-backendsetting"
    http_listener_name         = "applehealth-listenerhttps"
    name                       = "applehealth-routingrule"
    priority                   = 3
    rule_type                  = "Basic"
  }
  request_routing_rule {
    backend_address_pool_name  = "dt-backendpool"
    backend_http_settings_name = "dt-backendsetting"
    http_listener_name         = "dt-listenerhttps"
    name                       = "dt-routingrule"
    priority                   = 2
    rule_type                  = "Basic"
  }
  request_routing_rule {
    backend_address_pool_name  = "lta-backendpool"
    backend_http_settings_name = "lta-backendsetting"
    http_listener_name         = "lta-listenerhttps"
    name                       = "lta-routingrule"
    priority                   = 1
    rule_type                  = "Basic"
  }
  sku {
    capacity = 1
    name     = "Standard_v2"
    tier     = "Standard_v2"
  }
  ssl_certificate {
    key_vault_secret_id = "https://azmmkv01.vault.azure.net/secrets/MMWildcardKV2024"
    name                = "MMWildcard2024"
  }
  ssl_certificate {
    name = "matchmakerwildcard"
  }
  depends_on = [
    azurerm_user_assigned_identity.res-4,
    azurerm_public_ip.res-9,
    azurerm_subnet.res-11,
  ]
}
resource "azurerm_private_dns_zone" "res-6" {
  name                = "privatelink.database.windows.net"
  resource_group_name = "AZMMCoreRG01"
}
resource "azurerm_private_dns_zone_virtual_network_link" "res-7" {
  name                  = "mp2zoxnjsbkyw"
  private_dns_zone_name = "privatelink.database.windows.net"
  resource_group_name   = "AZMMCoreRG01"
  virtual_network_id    = "/subscriptions/2bd29ed6-34a6-42d7-8235-293e8ee67447/resourceGroups/AZMMCoreRG01/providers/Microsoft.Network/virtualNetworks/AZMMVNET01"
  depends_on = [
    azurerm_private_dns_zone.res-6,
    azurerm_virtual_network.res-10,
  ]
}
resource "azurerm_private_endpoint" "res-8" {
  location            = "northeurope"
  name                = "AZMMSQL01PEP01"
  resource_group_name = "AZMMCoreRG01"
  subnet_id           = "/subscriptions/2bd29ed6-34a6-42d7-8235-293e8ee67447/resourceGroups/AZMMCoreRG01/providers/Microsoft.Network/virtualNetworks/AZMMVNET01/subnets/SQLSNET01"
  private_service_connection {
    is_manual_connection           = false
    name                           = "AZMMSQL01PEP01"
    private_connection_resource_id = "/subscriptions/2bd29ed6-34a6-42d7-8235-293e8ee67447/resourceGroups/AZMMCoreRG01/providers/Microsoft.Sql/servers/azmmsql01"
    subresource_names              = ["SqlServer"]
  }
  depends_on = [
    azurerm_subnet.res-13,
    azurerm_mssql_server.res-14,
  ]
}
resource "azurerm_public_ip" "res-9" {
  allocation_method   = "Static"
  location            = "northeurope"
  name                = "AZMMAGW01PIP"
  resource_group_name = "AZMMCoreRG01"
  sku                 = "Standard"
}
resource "azurerm_virtual_network" "res-10" {
  address_space       = ["10.191.0.0/16"]
  location            = "northeurope"
  name                = "AZMMVNET01"
  resource_group_name = "AZMMCoreRG01"
}
resource "azurerm_subnet" "res-11" {
  address_prefixes     = ["10.191.3.0/24"]
  name                 = "AGWSNET01"
  resource_group_name  = "AZMMCoreRG01"
  virtual_network_name = "AZMMVNET01"
  depends_on = [
    azurerm_virtual_network.res-10,
  ]
}
resource "azurerm_subnet" "res-12" {
  address_prefixes     = ["10.191.1.0/24"]
  name                 = "AppSNET01"
  resource_group_name  = "AZMMCoreRG01"
  service_endpoints    = ["Microsoft.Storage"]
  virtual_network_name = "AZMMVNET01"
  delegation {
    name = "delegation"
    service_delegation {
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
      name    = "Microsoft.Web/serverFarms"
    }
  }
  depends_on = [
    azurerm_virtual_network.res-10,
  ]
}
resource "azurerm_subnet" "res-13" {
  address_prefixes     = ["10.191.2.0/24"]
  name                 = "SQLSNET01"
  resource_group_name  = "AZMMCoreRG01"
  virtual_network_name = "AZMMVNET01"
  depends_on = [
    azurerm_virtual_network.res-10,
  ]
}
resource "azurerm_mssql_server" "res-14" {
  administrator_login = "CloudSA6cb5ca8a"
  administrator_login_password = "D2i7!7H0Sx7T"
  location            = "northeurope"
  name                = "azmmsql01"
  resource_group_name = "AZMMCoreRG01"
  version             = "12.0"
}
resource "azurerm_mssql_database" "res-24" {
  name      = "15886"
  server_id = "/subscriptions/2bd29ed6-34a6-42d7-8235-293e8ee67447/resourceGroups/AZMMCoreRG01/providers/Microsoft.Sql/servers/azmmsql01"
  depends_on = [
    azurerm_mssql_server.res-14,
  ]
}
resource "azurerm_mssql_database_extended_auditing_policy" "res-35" {
  database_id            = "/subscriptions/2bd29ed6-34a6-42d7-8235-293e8ee67447/resourceGroups/AZMMCoreRG01/providers/Microsoft.Sql/servers/azmmsql01/databases/15886"
  enabled                = false
  log_monitoring_enabled = false
  depends_on = [
    azurerm_mssql_database.res-24,
  ]
}
resource "azurerm_mssql_database" "res-41" {
  name                 = "17008"
  server_id            = "/subscriptions/2bd29ed6-34a6-42d7-8235-293e8ee67447/resourceGroups/AZMMCoreRG01/providers/Microsoft.Sql/servers/azmmsql01"
  storage_account_type = "Zone"
  depends_on = [
    azurerm_mssql_server.res-14,
  ]
}
resource "azurerm_mssql_database_extended_auditing_policy" "res-52" {
  database_id            = "/subscriptions/2bd29ed6-34a6-42d7-8235-293e8ee67447/resourceGroups/AZMMCoreRG01/providers/Microsoft.Sql/servers/azmmsql01/databases/17008"
  enabled                = false
  log_monitoring_enabled = false
  depends_on = [
    azurerm_mssql_database.res-41,
  ]
}
resource "azurerm_mssql_database" "res-58" {
  name                 = "17009"
  server_id            = "/subscriptions/2bd29ed6-34a6-42d7-8235-293e8ee67447/resourceGroups/AZMMCoreRG01/providers/Microsoft.Sql/servers/azmmsql01"
  storage_account_type = "Zone"
  depends_on = [
    azurerm_mssql_server.res-14,
  ]
}
resource "azurerm_mssql_database_extended_auditing_policy" "res-69" {
  database_id            = "/subscriptions/2bd29ed6-34a6-42d7-8235-293e8ee67447/resourceGroups/AZMMCoreRG01/providers/Microsoft.Sql/servers/azmmsql01/databases/17009"
  enabled                = false
  log_monitoring_enabled = false
  depends_on = [
    azurerm_mssql_database.res-58,
  ]
}
resource "azurerm_mssql_database" "res-75" {
  name                 = "2179"
  server_id            = "/subscriptions/2bd29ed6-34a6-42d7-8235-293e8ee67447/resourceGroups/AZMMCoreRG01/providers/Microsoft.Sql/servers/azmmsql01"
  storage_account_type = "Local"
  depends_on = [
    azurerm_mssql_server.res-14,
  ]
}
resource "azurerm_mssql_database_extended_auditing_policy" "res-86" {
  database_id            = "/subscriptions/2bd29ed6-34a6-42d7-8235-293e8ee67447/resourceGroups/AZMMCoreRG01/providers/Microsoft.Sql/servers/azmmsql01/databases/2179"
  enabled                = false
  log_monitoring_enabled = false
  depends_on = [
    azurerm_mssql_database.res-75,
  ]
}
resource "azurerm_mssql_database" "res-92" {
  name      = "kairos_installdb"
  server_id = "/subscriptions/2bd29ed6-34a6-42d7-8235-293e8ee67447/resourceGroups/AZMMCoreRG01/providers/Microsoft.Sql/servers/azmmsql01"
  depends_on = [
    azurerm_mssql_server.res-14,
  ]
}
resource "azurerm_mssql_database_extended_auditing_policy" "res-98" {
  database_id            = "/subscriptions/2bd29ed6-34a6-42d7-8235-293e8ee67447/resourceGroups/AZMMCoreRG01/providers/Microsoft.Sql/servers/azmmsql01/databases/kairos_installdb"
  enabled                = false
  log_monitoring_enabled = false
  depends_on = [
    azurerm_mssql_database.res-92,
  ]
}
resource "azurerm_mssql_database_extended_auditing_policy" "res-107" {
  database_id            = "/subscriptions/2bd29ed6-34a6-42d7-8235-293e8ee67447/resourceGroups/AZMMCoreRG01/providers/Microsoft.Sql/servers/azmmsql01/databases/master"
  enabled                = false
  log_monitoring_enabled = false
}
resource "azurerm_mssql_server_microsoft_support_auditing_policy" "res-113" {
  enabled                = false
  log_monitoring_enabled = false
  server_id              = "/subscriptions/2bd29ed6-34a6-42d7-8235-293e8ee67447/resourceGroups/AZMMCoreRG01/providers/Microsoft.Sql/servers/azmmsql01"
  depends_on = [
    azurerm_mssql_server.res-14,
  ]
}
resource "azurerm_mssql_server_transparent_data_encryption" "res-114" {
  server_id = "/subscriptions/2bd29ed6-34a6-42d7-8235-293e8ee67447/resourceGroups/AZMMCoreRG01/providers/Microsoft.Sql/servers/azmmsql01"
  depends_on = [
    azurerm_mssql_server.res-14,
  ]
}
resource "azurerm_mssql_server_extended_auditing_policy" "res-115" {
  enabled                = false
  log_monitoring_enabled = false
  server_id              = "/subscriptions/2bd29ed6-34a6-42d7-8235-293e8ee67447/resourceGroups/AZMMCoreRG01/providers/Microsoft.Sql/servers/azmmsql01"
  depends_on = [
    azurerm_mssql_server.res-14,
  ]
}
resource "azurerm_mssql_firewall_rule" "res-116" {
  end_ip_address   = "51.183.253.81"
  name             = "ClientIPAddress_2024-2-19_13-31-2"
  server_id        = "/subscriptions/2bd29ed6-34a6-42d7-8235-293e8ee67447/resourceGroups/AZMMCoreRG01/providers/Microsoft.Sql/servers/azmmsql01"
  start_ip_address = "51.183.253.81"
  depends_on = [
    azurerm_mssql_server.res-14,
  ]
}
resource "azurerm_mssql_firewall_rule" "res-117" {
  end_ip_address   = "217.37.57.251"
  name             = "MatchMakerIP"
  server_id        = "/subscriptions/2bd29ed6-34a6-42d7-8235-293e8ee67447/resourceGroups/AZMMCoreRG01/providers/Microsoft.Sql/servers/azmmsql01"
  start_ip_address = "217.37.57.250"
  depends_on = [
    azurerm_mssql_server.res-14,
  ]
}
resource "azurerm_mssql_server_security_alert_policy" "res-120" {
  resource_group_name = "AZMMCoreRG01"
  server_name         = "azmmsql01"
  state               = "Disabled"
  depends_on = [
    azurerm_mssql_server.res-14,
  ]
}

/**
resource "azurerm_mssql_server_vulnerability_assessment" "res-122" {
  server_security_alert_policy_id = "/subscriptions/2bd29ed6-34a6-42d7-8235-293e8ee67447/resourceGroups/AZMMCoreRG01/providers/Microsoft.Sql/servers/azmmsql01/securityAlertPolicies/Default"
  storage_container_path          = ""
  depends_on = [
    azurerm_mssql_server_security_alert_policy.res-120,
  ]
}
*/

resource "azurerm_service_plan" "res-123" {
  location            = "northeurope"
  name                = "AZMMASP01"
  os_type             = "Windows"
  resource_group_name = "AZMMCoreRG01"
  sku_name            = "S1"
}
resource "azurerm_monitor_smart_detector_alert_rule" "res-124" {
  description         = "Failure Anomalies notifies you of an unusual rise in the rate of failed HTTP requests or dependency calls."
  detector_type       = "FailureAnomaliesDetector"
  frequency           = "PT1M"
  name                = "Failure Anomalies - AZMMApp01"
  resource_group_name = "AZMMCoreRG01"
  scope_resource_ids  = ["/subscriptions/2bd29ed6-34a6-42d7-8235-293e8ee67447/resourcegroups/azmmcorerg01/providers/microsoft.insights/components/azmmapp01"]
  severity            = "Sev3"
  action_group {
    ids = ["/subscriptions/2bd29ed6-34a6-42d7-8235-293e8ee67447/resourceGroups/azmmcorerg01/providers/Microsoft.Insights/actionGroups/application insights smart detection"]
  }
}
resource "azurerm_monitor_action_group" "res-125" {
  name                = "Application Insights Smart Detection"
  resource_group_name = "AZMMCoreRG01"
  short_name          = "SmartDetect"
  arm_role_receiver {
    name                    = "Monitoring Contributor"
    role_id                 = "749f88d5-cbae-40b8-bcfc-e573ddc772fa"
    use_common_alert_schema = true
  }
  arm_role_receiver {
    name                    = "Monitoring Reader"
    role_id                 = "43d0d8ad-25c7-4714-9337-8ba259a9fe05"
    use_common_alert_schema = true
  }
}
resource "azurerm_application_insights" "res-126" {
  application_type    = "web"
  location            = "northeurope"
  name                = "AZMMApp01"
  resource_group_name = "AZMMCoreRG01"
  sampling_percentage = 0
  workspace_id        = "/subscriptions/2bd29ed6-34a6-42d7-8235-293e8ee67447/resourceGroups/DefaultResourceGroup-NEU/providers/Microsoft.OperationalInsights/workspaces/DefaultWorkspace-2bd29ed6-34a6-42d7-8235-293e8ee67447-NEU"
  depends_on = [
    azurerm_log_analytics_workspace.res-127,
  ]
}
resource "azurerm_log_analytics_workspace" "res-127" {
  location            = "northeurope"
  name                = "DefaultWorkspace-2bd29ed6-34a6-42d7-8235-293e8ee67447-NEU"
  resource_group_name = "DefaultResourceGroup-NEU"
}
resource "azurerm_log_analytics_saved_search" "res-128" {
  category                   = "General Exploration"
  display_name               = "All Computers with their most recent data"
  log_analytics_workspace_id = "/subscriptions/2bd29ed6-34a6-42d7-8235-293e8ee67447/resourceGroups/DefaultResourceGroup-NEU/providers/Microsoft.OperationalInsights/workspaces/DefaultWorkspace-2bd29ed6-34a6-42d7-8235-293e8ee67447-NEU"
  name                       = "LogManagement(DefaultWorkspace-2bd29ed6-34a6-42d7-8235-293e8ee67447-NEU)_General|AlphabeticallySortedComputers"
  query                      = "search not(ObjectName == \"Advisor Metrics\" or ObjectName == \"ManagedSpace\") | summarize AggregatedValue = max(TimeGenerated) by Computer | limit 500000 | sort by Computer asc\r\n// Oql: NOT(ObjectName=\"Advisor Metrics\" OR ObjectName=ManagedSpace) | measure max(TimeGenerated) by Computer | top 500000 | Sort Computer // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PTT: True; SortI: True; SortF: True} // Version: 0.1.122"
  depends_on = [
    azurerm_log_analytics_workspace.res-127,
  ]
}
resource "azurerm_log_analytics_saved_search" "res-129" {
  category                   = "General Exploration"
  display_name               = "Stale Computers (data older than 24 hours)"
  log_analytics_workspace_id = "/subscriptions/2bd29ed6-34a6-42d7-8235-293e8ee67447/resourceGroups/DefaultResourceGroup-NEU/providers/Microsoft.OperationalInsights/workspaces/DefaultWorkspace-2bd29ed6-34a6-42d7-8235-293e8ee67447-NEU"
  name                       = "LogManagement(DefaultWorkspace-2bd29ed6-34a6-42d7-8235-293e8ee67447-NEU)_General|StaleComputers"
  query                      = "search not(ObjectName == \"Advisor Metrics\" or ObjectName == \"ManagedSpace\") | summarize lastdata = max(TimeGenerated) by Computer | limit 500000 | where lastdata < ago(24h)\r\n// Oql: NOT(ObjectName=\"Advisor Metrics\" OR ObjectName=ManagedSpace) | measure max(TimeGenerated) as lastdata by Computer | top 500000 | where lastdata < NOW-24HOURS // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PTT: True; SortI: True; SortF: True} // Version: 0.1.122"
  depends_on = [
    azurerm_log_analytics_workspace.res-127,
  ]
}
resource "azurerm_log_analytics_saved_search" "res-130" {
  category                   = "General Exploration"
  display_name               = "Which Management Group is generating the most data points?"
  log_analytics_workspace_id = "/subscriptions/2bd29ed6-34a6-42d7-8235-293e8ee67447/resourceGroups/DefaultResourceGroup-NEU/providers/Microsoft.OperationalInsights/workspaces/DefaultWorkspace-2bd29ed6-34a6-42d7-8235-293e8ee67447-NEU"
  name                       = "LogManagement(DefaultWorkspace-2bd29ed6-34a6-42d7-8235-293e8ee67447-NEU)_General|dataPointsPerManagementGroup"
  query                      = "search * | summarize AggregatedValue = count() by ManagementGroupName\r\n// Oql: * | Measure count() by ManagementGroupName // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PTT: True; SortI: True; SortF: True} // Version: 0.1.122"
  depends_on = [
    azurerm_log_analytics_workspace.res-127,
  ]
}
resource "azurerm_log_analytics_saved_search" "res-131" {
  category                   = "General Exploration"
  display_name               = "Distribution of data Types"
  log_analytics_workspace_id = "/subscriptions/2bd29ed6-34a6-42d7-8235-293e8ee67447/resourceGroups/DefaultResourceGroup-NEU/providers/Microsoft.OperationalInsights/workspaces/DefaultWorkspace-2bd29ed6-34a6-42d7-8235-293e8ee67447-NEU"
  name                       = "LogManagement(DefaultWorkspace-2bd29ed6-34a6-42d7-8235-293e8ee67447-NEU)_General|dataTypeDistribution"
  query                      = "search * | extend Type = $table | summarize AggregatedValue = count() by Type\r\n// Oql: * | Measure count() by Type // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PTT: True; SortI: True; SortF: True} // Version: 0.1.122"
  depends_on = [
    azurerm_log_analytics_workspace.res-127,
  ]
}
resource "azurerm_log_analytics_saved_search" "res-132" {
  category                   = "Log Management"
  display_name               = "All Events"
  log_analytics_workspace_id = "/subscriptions/2bd29ed6-34a6-42d7-8235-293e8ee67447/resourceGroups/DefaultResourceGroup-NEU/providers/Microsoft.OperationalInsights/workspaces/DefaultWorkspace-2bd29ed6-34a6-42d7-8235-293e8ee67447-NEU"
  name                       = "LogManagement(DefaultWorkspace-2bd29ed6-34a6-42d7-8235-293e8ee67447-NEU)_LogManagement|AllEvents"
  query                      = "Event | sort by TimeGenerated desc\r\n// Oql: Type=Event // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PTT: True; SortI: True; SortF: True} // Version: 0.1.122"
  depends_on = [
    azurerm_log_analytics_workspace.res-127,
  ]
}
resource "azurerm_log_analytics_saved_search" "res-133" {
  category                   = "Log Management"
  display_name               = "All Syslogs"
  log_analytics_workspace_id = "/subscriptions/2bd29ed6-34a6-42d7-8235-293e8ee67447/resourceGroups/DefaultResourceGroup-NEU/providers/Microsoft.OperationalInsights/workspaces/DefaultWorkspace-2bd29ed6-34a6-42d7-8235-293e8ee67447-NEU"
  name                       = "LogManagement(DefaultWorkspace-2bd29ed6-34a6-42d7-8235-293e8ee67447-NEU)_LogManagement|AllSyslog"
  query                      = "Syslog | sort by TimeGenerated desc\r\n// Oql: Type=Syslog // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PTT: True; SortI: True; SortF: True} // Version: 0.1.122"
  depends_on = [
    azurerm_log_analytics_workspace.res-127,
  ]
}
resource "azurerm_log_analytics_saved_search" "res-134" {
  category                   = "Log Management"
  display_name               = "All Syslog Records grouped by Facility"
  log_analytics_workspace_id = "/subscriptions/2bd29ed6-34a6-42d7-8235-293e8ee67447/resourceGroups/DefaultResourceGroup-NEU/providers/Microsoft.OperationalInsights/workspaces/DefaultWorkspace-2bd29ed6-34a6-42d7-8235-293e8ee67447-NEU"
  name                       = "LogManagement(DefaultWorkspace-2bd29ed6-34a6-42d7-8235-293e8ee67447-NEU)_LogManagement|AllSyslogByFacility"
  query                      = "Syslog | summarize AggregatedValue = count() by Facility\r\n// Oql: Type=Syslog | Measure count() by Facility // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PTT: True; SortI: True; SortF: True} // Version: 0.1.122"
  depends_on = [
    azurerm_log_analytics_workspace.res-127,
  ]
}
resource "azurerm_log_analytics_saved_search" "res-135" {
  category                   = "Log Management"
  display_name               = "All Syslog Records grouped by ProcessName"
  log_analytics_workspace_id = "/subscriptions/2bd29ed6-34a6-42d7-8235-293e8ee67447/resourceGroups/DefaultResourceGroup-NEU/providers/Microsoft.OperationalInsights/workspaces/DefaultWorkspace-2bd29ed6-34a6-42d7-8235-293e8ee67447-NEU"
  name                       = "LogManagement(DefaultWorkspace-2bd29ed6-34a6-42d7-8235-293e8ee67447-NEU)_LogManagement|AllSyslogByProcessName"
  query                      = "Syslog | summarize AggregatedValue = count() by ProcessName\r\n// Oql: Type=Syslog | Measure count() by ProcessName // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PTT: True; SortI: True; SortF: True} // Version: 0.1.122"
  depends_on = [
    azurerm_log_analytics_workspace.res-127,
  ]
}
resource "azurerm_log_analytics_saved_search" "res-136" {
  category                   = "Log Management"
  display_name               = "All Syslog Records with Errors"
  log_analytics_workspace_id = "/subscriptions/2bd29ed6-34a6-42d7-8235-293e8ee67447/resourceGroups/DefaultResourceGroup-NEU/providers/Microsoft.OperationalInsights/workspaces/DefaultWorkspace-2bd29ed6-34a6-42d7-8235-293e8ee67447-NEU"
  name                       = "LogManagement(DefaultWorkspace-2bd29ed6-34a6-42d7-8235-293e8ee67447-NEU)_LogManagement|AllSyslogsWithErrors"
  query                      = "Syslog | where SeverityLevel == \"error\" | sort by TimeGenerated desc\r\n// Oql: Type=Syslog SeverityLevel=error // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PTT: True; SortI: True; SortF: True} // Version: 0.1.122"
  depends_on = [
    azurerm_log_analytics_workspace.res-127,
  ]
}
resource "azurerm_log_analytics_saved_search" "res-137" {
  category                   = "Log Management"
  display_name               = "Average HTTP Request time by Client IP Address"
  log_analytics_workspace_id = "/subscriptions/2bd29ed6-34a6-42d7-8235-293e8ee67447/resourceGroups/DefaultResourceGroup-NEU/providers/Microsoft.OperationalInsights/workspaces/DefaultWorkspace-2bd29ed6-34a6-42d7-8235-293e8ee67447-NEU"
  name                       = "LogManagement(DefaultWorkspace-2bd29ed6-34a6-42d7-8235-293e8ee67447-NEU)_LogManagement|AverageHTTPRequestTimeByClientIPAddress"
  query                      = "search * | extend Type = $table | where Type == W3CIISLog | summarize AggregatedValue = avg(TimeTaken) by cIP\r\n// Oql: Type=W3CIISLog | Measure Avg(TimeTaken) by cIP // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PEF: True; SortI: True; SortF: True} // Version: 0.1.122"
  depends_on = [
    azurerm_log_analytics_workspace.res-127,
  ]
}
resource "azurerm_log_analytics_saved_search" "res-138" {
  category                   = "Log Management"
  display_name               = "Average HTTP Request time by HTTP Method"
  log_analytics_workspace_id = "/subscriptions/2bd29ed6-34a6-42d7-8235-293e8ee67447/resourceGroups/DefaultResourceGroup-NEU/providers/Microsoft.OperationalInsights/workspaces/DefaultWorkspace-2bd29ed6-34a6-42d7-8235-293e8ee67447-NEU"
  name                       = "LogManagement(DefaultWorkspace-2bd29ed6-34a6-42d7-8235-293e8ee67447-NEU)_LogManagement|AverageHTTPRequestTimeHTTPMethod"
  query                      = "search * | extend Type = $table | where Type == W3CIISLog | summarize AggregatedValue = avg(TimeTaken) by csMethod\r\n// Oql: Type=W3CIISLog | Measure Avg(TimeTaken) by csMethod // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PEF: True; SortI: True; SortF: True} // Version: 0.1.122"
  depends_on = [
    azurerm_log_analytics_workspace.res-127,
  ]
}
resource "azurerm_log_analytics_saved_search" "res-139" {
  category                   = "Log Management"
  display_name               = "Count of IIS Log Entries by Client IP Address"
  log_analytics_workspace_id = "/subscriptions/2bd29ed6-34a6-42d7-8235-293e8ee67447/resourceGroups/DefaultResourceGroup-NEU/providers/Microsoft.OperationalInsights/workspaces/DefaultWorkspace-2bd29ed6-34a6-42d7-8235-293e8ee67447-NEU"
  name                       = "LogManagement(DefaultWorkspace-2bd29ed6-34a6-42d7-8235-293e8ee67447-NEU)_LogManagement|CountIISLogEntriesClientIPAddress"
  query                      = "search * | extend Type = $table | where Type == W3CIISLog | summarize AggregatedValue = count() by cIP\r\n// Oql: Type=W3CIISLog | Measure count() by cIP // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PEF: True; SortI: True; SortF: True} // Version: 0.1.122"
  depends_on = [
    azurerm_log_analytics_workspace.res-127,
  ]
}
resource "azurerm_log_analytics_saved_search" "res-140" {
  category                   = "Log Management"
  display_name               = "Count of IIS Log Entries by HTTP Request Method"
  log_analytics_workspace_id = "/subscriptions/2bd29ed6-34a6-42d7-8235-293e8ee67447/resourceGroups/DefaultResourceGroup-NEU/providers/Microsoft.OperationalInsights/workspaces/DefaultWorkspace-2bd29ed6-34a6-42d7-8235-293e8ee67447-NEU"
  name                       = "LogManagement(DefaultWorkspace-2bd29ed6-34a6-42d7-8235-293e8ee67447-NEU)_LogManagement|CountIISLogEntriesHTTPRequestMethod"
  query                      = "search * | extend Type = $table | where Type == W3CIISLog | summarize AggregatedValue = count() by csMethod\r\n// Oql: Type=W3CIISLog | Measure count() by csMethod // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PEF: True; SortI: True; SortF: True} // Version: 0.1.122"
  depends_on = [
    azurerm_log_analytics_workspace.res-127,
  ]
}
resource "azurerm_log_analytics_saved_search" "res-141" {
  category                   = "Log Management"
  display_name               = "Count of IIS Log Entries by HTTP User Agent"
  log_analytics_workspace_id = "/subscriptions/2bd29ed6-34a6-42d7-8235-293e8ee67447/resourceGroups/DefaultResourceGroup-NEU/providers/Microsoft.OperationalInsights/workspaces/DefaultWorkspace-2bd29ed6-34a6-42d7-8235-293e8ee67447-NEU"
  name                       = "LogManagement(DefaultWorkspace-2bd29ed6-34a6-42d7-8235-293e8ee67447-NEU)_LogManagement|CountIISLogEntriesHTTPUserAgent"
  query                      = "search * | extend Type = $table | where Type == W3CIISLog | summarize AggregatedValue = count() by csUserAgent\r\n// Oql: Type=W3CIISLog | Measure count() by csUserAgent // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PEF: True; SortI: True; SortF: True} // Version: 0.1.122"
  depends_on = [
    azurerm_log_analytics_workspace.res-127,
  ]
}
resource "azurerm_log_analytics_saved_search" "res-142" {
  category                   = "Log Management"
  display_name               = "Count of IIS Log Entries by Host requested by client"
  log_analytics_workspace_id = "/subscriptions/2bd29ed6-34a6-42d7-8235-293e8ee67447/resourceGroups/DefaultResourceGroup-NEU/providers/Microsoft.OperationalInsights/workspaces/DefaultWorkspace-2bd29ed6-34a6-42d7-8235-293e8ee67447-NEU"
  name                       = "LogManagement(DefaultWorkspace-2bd29ed6-34a6-42d7-8235-293e8ee67447-NEU)_LogManagement|CountOfIISLogEntriesByHostRequestedByClient"
  query                      = "search * | extend Type = $table | where Type == W3CIISLog | summarize AggregatedValue = count() by csHost\r\n// Oql: Type=W3CIISLog | Measure count() by csHost // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PEF: True; SortI: True; SortF: True} // Version: 0.1.122"
  depends_on = [
    azurerm_log_analytics_workspace.res-127,
  ]
}
resource "azurerm_log_analytics_saved_search" "res-143" {
  category                   = "Log Management"
  display_name               = "Count of IIS Log Entries by URL for the host \"www.contoso.com\" (replace with your own)"
  log_analytics_workspace_id = "/subscriptions/2bd29ed6-34a6-42d7-8235-293e8ee67447/resourceGroups/DefaultResourceGroup-NEU/providers/Microsoft.OperationalInsights/workspaces/DefaultWorkspace-2bd29ed6-34a6-42d7-8235-293e8ee67447-NEU"
  name                       = "LogManagement(DefaultWorkspace-2bd29ed6-34a6-42d7-8235-293e8ee67447-NEU)_LogManagement|CountOfIISLogEntriesByURLForHost"
  query                      = "search csHost == \"www.contoso.com\" | extend Type = $table | where Type == W3CIISLog | summarize AggregatedValue = count() by csUriStem\r\n// Oql: Type=W3CIISLog csHost=\"www.contoso.com\" | Measure count() by csUriStem // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PEF: True; SortI: True; SortF: True} // Version: 0.1.122"
  depends_on = [
    azurerm_log_analytics_workspace.res-127,
  ]
}
resource "azurerm_log_analytics_saved_search" "res-144" {
  category                   = "Log Management"
  display_name               = "Count of IIS Log Entries by URL requested by client (without query strings)"
  log_analytics_workspace_id = "/subscriptions/2bd29ed6-34a6-42d7-8235-293e8ee67447/resourceGroups/DefaultResourceGroup-NEU/providers/Microsoft.OperationalInsights/workspaces/DefaultWorkspace-2bd29ed6-34a6-42d7-8235-293e8ee67447-NEU"
  name                       = "LogManagement(DefaultWorkspace-2bd29ed6-34a6-42d7-8235-293e8ee67447-NEU)_LogManagement|CountOfIISLogEntriesByURLRequestedByClient"
  query                      = "search * | extend Type = $table | where Type == W3CIISLog | summarize AggregatedValue = count() by csUriStem\r\n// Oql: Type=W3CIISLog | Measure count() by csUriStem // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PEF: True; SortI: True; SortF: True} // Version: 0.1.122"
  depends_on = [
    azurerm_log_analytics_workspace.res-127,
  ]
}
resource "azurerm_log_analytics_saved_search" "res-145" {
  category                   = "Log Management"
  display_name               = "Count of Events with level \"Warning\" grouped by Event ID"
  log_analytics_workspace_id = "/subscriptions/2bd29ed6-34a6-42d7-8235-293e8ee67447/resourceGroups/DefaultResourceGroup-NEU/providers/Microsoft.OperationalInsights/workspaces/DefaultWorkspace-2bd29ed6-34a6-42d7-8235-293e8ee67447-NEU"
  name                       = "LogManagement(DefaultWorkspace-2bd29ed6-34a6-42d7-8235-293e8ee67447-NEU)_LogManagement|CountOfWarningEvents"
  query                      = "Event | where EventLevelName == \"warning\" | summarize AggregatedValue = count() by EventID\r\n// Oql: Type=Event EventLevelName=warning | Measure count() by EventID // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PTT: True; SortI: True; SortF: True} // Version: 0.1.122"
  depends_on = [
    azurerm_log_analytics_workspace.res-127,
  ]
}
resource "azurerm_log_analytics_saved_search" "res-146" {
  category                   = "Log Management"
  display_name               = "Shows breakdown of response codes"
  log_analytics_workspace_id = "/subscriptions/2bd29ed6-34a6-42d7-8235-293e8ee67447/resourceGroups/DefaultResourceGroup-NEU/providers/Microsoft.OperationalInsights/workspaces/DefaultWorkspace-2bd29ed6-34a6-42d7-8235-293e8ee67447-NEU"
  name                       = "LogManagement(DefaultWorkspace-2bd29ed6-34a6-42d7-8235-293e8ee67447-NEU)_LogManagement|DisplayBreakdownRespondCodes"
  query                      = "search * | extend Type = $table | where Type == W3CIISLog | summarize AggregatedValue = count() by scStatus\r\n// Oql: Type=W3CIISLog | Measure count() by scStatus // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PEF: True; SortI: True; SortF: True} // Version: 0.1.122"
  depends_on = [
    azurerm_log_analytics_workspace.res-127,
  ]
}
resource "azurerm_log_analytics_saved_search" "res-147" {
  category                   = "Log Management"
  display_name               = "Count of Events grouped by Event Log"
  log_analytics_workspace_id = "/subscriptions/2bd29ed6-34a6-42d7-8235-293e8ee67447/resourceGroups/DefaultResourceGroup-NEU/providers/Microsoft.OperationalInsights/workspaces/DefaultWorkspace-2bd29ed6-34a6-42d7-8235-293e8ee67447-NEU"
  name                       = "LogManagement(DefaultWorkspace-2bd29ed6-34a6-42d7-8235-293e8ee67447-NEU)_LogManagement|EventsByEventLog"
  query                      = "Event | summarize AggregatedValue = count() by EventLog\r\n// Oql: Type=Event | Measure count() by EventLog // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PTT: True; SortI: True; SortF: True} // Version: 0.1.122"
  depends_on = [
    azurerm_log_analytics_workspace.res-127,
  ]
}
resource "azurerm_log_analytics_saved_search" "res-148" {
  category                   = "Log Management"
  display_name               = "Count of Events grouped by Event Source"
  log_analytics_workspace_id = "/subscriptions/2bd29ed6-34a6-42d7-8235-293e8ee67447/resourceGroups/DefaultResourceGroup-NEU/providers/Microsoft.OperationalInsights/workspaces/DefaultWorkspace-2bd29ed6-34a6-42d7-8235-293e8ee67447-NEU"
  name                       = "LogManagement(DefaultWorkspace-2bd29ed6-34a6-42d7-8235-293e8ee67447-NEU)_LogManagement|EventsByEventSource"
  query                      = "Event | summarize AggregatedValue = count() by Source\r\n// Oql: Type=Event | Measure count() by Source // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PTT: True; SortI: True; SortF: True} // Version: 0.1.122"
  depends_on = [
    azurerm_log_analytics_workspace.res-127,
  ]
}
resource "azurerm_log_analytics_saved_search" "res-149" {
  category                   = "Log Management"
  display_name               = "Count of Events grouped by Event ID"
  log_analytics_workspace_id = "/subscriptions/2bd29ed6-34a6-42d7-8235-293e8ee67447/resourceGroups/DefaultResourceGroup-NEU/providers/Microsoft.OperationalInsights/workspaces/DefaultWorkspace-2bd29ed6-34a6-42d7-8235-293e8ee67447-NEU"
  name                       = "LogManagement(DefaultWorkspace-2bd29ed6-34a6-42d7-8235-293e8ee67447-NEU)_LogManagement|EventsByEventsID"
  query                      = "Event | summarize AggregatedValue = count() by EventID\r\n// Oql: Type=Event | Measure count() by EventID // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PTT: True; SortI: True; SortF: True} // Version: 0.1.122"
  depends_on = [
    azurerm_log_analytics_workspace.res-127,
  ]
}
resource "azurerm_log_analytics_saved_search" "res-150" {
  category                   = "Log Management"
  display_name               = "Events in the Operations Manager Event Log whose Event ID is in the range between 2000 and 3000"
  log_analytics_workspace_id = "/subscriptions/2bd29ed6-34a6-42d7-8235-293e8ee67447/resourceGroups/DefaultResourceGroup-NEU/providers/Microsoft.OperationalInsights/workspaces/DefaultWorkspace-2bd29ed6-34a6-42d7-8235-293e8ee67447-NEU"
  name                       = "LogManagement(DefaultWorkspace-2bd29ed6-34a6-42d7-8235-293e8ee67447-NEU)_LogManagement|EventsInOMBetween2000to3000"
  query                      = "Event | where EventLog == \"Operations Manager\" and EventID >= 2000 and EventID <= 3000 | sort by TimeGenerated desc\r\n// Oql: Type=Event EventLog=\"Operations Manager\" EventID:[2000..3000] // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PTT: True; SortI: True; SortF: True} // Version: 0.1.122"
  depends_on = [
    azurerm_log_analytics_workspace.res-127,
  ]
}
resource "azurerm_log_analytics_saved_search" "res-151" {
  category                   = "Log Management"
  display_name               = "Count of Events containing the word \"started\" grouped by EventID"
  log_analytics_workspace_id = "/subscriptions/2bd29ed6-34a6-42d7-8235-293e8ee67447/resourceGroups/DefaultResourceGroup-NEU/providers/Microsoft.OperationalInsights/workspaces/DefaultWorkspace-2bd29ed6-34a6-42d7-8235-293e8ee67447-NEU"
  name                       = "LogManagement(DefaultWorkspace-2bd29ed6-34a6-42d7-8235-293e8ee67447-NEU)_LogManagement|EventsWithStartedinEventID"
  query                      = "search in (Event) \"started\" | summarize AggregatedValue = count() by EventID\r\n// Oql: Type=Event \"started\" | Measure count() by EventID // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PTT: True; SortI: True; SortF: True} // Version: 0.1.122"
  depends_on = [
    azurerm_log_analytics_workspace.res-127,
  ]
}
resource "azurerm_log_analytics_saved_search" "res-152" {
  category                   = "Log Management"
  display_name               = "Find the maximum time taken for each page"
  log_analytics_workspace_id = "/subscriptions/2bd29ed6-34a6-42d7-8235-293e8ee67447/resourceGroups/DefaultResourceGroup-NEU/providers/Microsoft.OperationalInsights/workspaces/DefaultWorkspace-2bd29ed6-34a6-42d7-8235-293e8ee67447-NEU"
  name                       = "LogManagement(DefaultWorkspace-2bd29ed6-34a6-42d7-8235-293e8ee67447-NEU)_LogManagement|FindMaximumTimeTakenForEachPage"
  query                      = "search * | extend Type = $table | where Type == W3CIISLog | summarize AggregatedValue = max(TimeTaken) by csUriStem\r\n// Oql: Type=W3CIISLog | Measure Max(TimeTaken) by csUriStem // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PEF: True; SortI: True; SortF: True} // Version: 0.1.122"
  depends_on = [
    azurerm_log_analytics_workspace.res-127,
  ]
}
resource "azurerm_log_analytics_saved_search" "res-153" {
  category                   = "Log Management"
  display_name               = "IIS Log Entries for a specific client IP Address (replace with your own)"
  log_analytics_workspace_id = "/subscriptions/2bd29ed6-34a6-42d7-8235-293e8ee67447/resourceGroups/DefaultResourceGroup-NEU/providers/Microsoft.OperationalInsights/workspaces/DefaultWorkspace-2bd29ed6-34a6-42d7-8235-293e8ee67447-NEU"
  name                       = "LogManagement(DefaultWorkspace-2bd29ed6-34a6-42d7-8235-293e8ee67447-NEU)_LogManagement|IISLogEntriesForClientIP"
  query                      = "search cIP == \"192.168.0.1\" | extend Type = $table | where Type == W3CIISLog | sort by TimeGenerated desc | project csUriStem, scBytes, csBytes, TimeTaken, scStatus\r\n// Oql: Type=W3CIISLog cIP=\"192.168.0.1\" | Select csUriStem,scBytes,csBytes,TimeTaken,scStatus // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PEF: True; SortI: True; SortF: True} // Version: 0.1.122"
  depends_on = [
    azurerm_log_analytics_workspace.res-127,
  ]
}
resource "azurerm_log_analytics_saved_search" "res-154" {
  category                   = "Log Management"
  display_name               = "All IIS Log Entries"
  log_analytics_workspace_id = "/subscriptions/2bd29ed6-34a6-42d7-8235-293e8ee67447/resourceGroups/DefaultResourceGroup-NEU/providers/Microsoft.OperationalInsights/workspaces/DefaultWorkspace-2bd29ed6-34a6-42d7-8235-293e8ee67447-NEU"
  name                       = "LogManagement(DefaultWorkspace-2bd29ed6-34a6-42d7-8235-293e8ee67447-NEU)_LogManagement|ListAllIISLogEntries"
  query                      = "search * | extend Type = $table | where Type == W3CIISLog | sort by TimeGenerated desc\r\n// Oql: Type=W3CIISLog // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PEF: True; SortI: True; SortF: True} // Version: 0.1.122"
  depends_on = [
    azurerm_log_analytics_workspace.res-127,
  ]
}
resource "azurerm_log_analytics_saved_search" "res-155" {
  category                   = "Log Management"
  display_name               = "How many connections to Operations Manager's SDK service by day"
  log_analytics_workspace_id = "/subscriptions/2bd29ed6-34a6-42d7-8235-293e8ee67447/resourceGroups/DefaultResourceGroup-NEU/providers/Microsoft.OperationalInsights/workspaces/DefaultWorkspace-2bd29ed6-34a6-42d7-8235-293e8ee67447-NEU"
  name                       = "LogManagement(DefaultWorkspace-2bd29ed6-34a6-42d7-8235-293e8ee67447-NEU)_LogManagement|NoOfConnectionsToOMSDKService"
  query                      = "Event | where EventID == 26328 and EventLog == \"Operations Manager\" | summarize AggregatedValue = count() by bin(TimeGenerated, 1d) | sort by TimeGenerated desc\r\n// Oql: Type=Event EventID=26328 EventLog=\"Operations Manager\" | Measure count() interval 1DAY // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PTT: True; SortI: True; SortF: True} // Version: 0.1.122"
  depends_on = [
    azurerm_log_analytics_workspace.res-127,
  ]
}
resource "azurerm_log_analytics_saved_search" "res-156" {
  category                   = "Log Management"
  display_name               = "When did my servers initiate restart?"
  log_analytics_workspace_id = "/subscriptions/2bd29ed6-34a6-42d7-8235-293e8ee67447/resourceGroups/DefaultResourceGroup-NEU/providers/Microsoft.OperationalInsights/workspaces/DefaultWorkspace-2bd29ed6-34a6-42d7-8235-293e8ee67447-NEU"
  name                       = "LogManagement(DefaultWorkspace-2bd29ed6-34a6-42d7-8235-293e8ee67447-NEU)_LogManagement|ServerRestartTime"
  query                      = "search in (Event) \"shutdown\" and EventLog == \"System\" and Source == \"User32\" and EventID == 1074 | sort by TimeGenerated desc | project TimeGenerated, Computer\r\n// Oql: shutdown Type=Event EventLog=System Source=User32 EventID=1074 | Select TimeGenerated,Computer // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PTT: True; SortI: True; SortF: True} // Version: 0.1.122"
  depends_on = [
    azurerm_log_analytics_workspace.res-127,
  ]
}
resource "azurerm_log_analytics_saved_search" "res-157" {
  category                   = "Log Management"
  display_name               = "Shows which pages people are getting a 404 for"
  log_analytics_workspace_id = "/subscriptions/2bd29ed6-34a6-42d7-8235-293e8ee67447/resourceGroups/DefaultResourceGroup-NEU/providers/Microsoft.OperationalInsights/workspaces/DefaultWorkspace-2bd29ed6-34a6-42d7-8235-293e8ee67447-NEU"
  name                       = "LogManagement(DefaultWorkspace-2bd29ed6-34a6-42d7-8235-293e8ee67447-NEU)_LogManagement|Show404PagesList"
  query                      = "search scStatus == 404 | extend Type = $table | where Type == W3CIISLog | summarize AggregatedValue = count() by csUriStem\r\n// Oql: Type=W3CIISLog scStatus=404 | Measure count() by csUriStem // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PEF: True; SortI: True; SortF: True} // Version: 0.1.122"
  depends_on = [
    azurerm_log_analytics_workspace.res-127,
  ]
}
resource "azurerm_log_analytics_saved_search" "res-158" {
  category                   = "Log Management"
  display_name               = "Shows servers that are throwing internal server error"
  log_analytics_workspace_id = "/subscriptions/2bd29ed6-34a6-42d7-8235-293e8ee67447/resourceGroups/DefaultResourceGroup-NEU/providers/Microsoft.OperationalInsights/workspaces/DefaultWorkspace-2bd29ed6-34a6-42d7-8235-293e8ee67447-NEU"
  name                       = "LogManagement(DefaultWorkspace-2bd29ed6-34a6-42d7-8235-293e8ee67447-NEU)_LogManagement|ShowServersThrowingInternalServerError"
  query                      = "search scStatus == 500 | extend Type = $table | where Type == W3CIISLog | summarize AggregatedValue = count() by sComputerName\r\n// Oql: Type=W3CIISLog scStatus=500 | Measure count() by sComputerName // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PEF: True; SortI: True; SortF: True} // Version: 0.1.122"
  depends_on = [
    azurerm_log_analytics_workspace.res-127,
  ]
}
resource "azurerm_log_analytics_saved_search" "res-159" {
  category                   = "Log Management"
  display_name               = "Total Bytes received by each Azure Role Instance"
  log_analytics_workspace_id = "/subscriptions/2bd29ed6-34a6-42d7-8235-293e8ee67447/resourceGroups/DefaultResourceGroup-NEU/providers/Microsoft.OperationalInsights/workspaces/DefaultWorkspace-2bd29ed6-34a6-42d7-8235-293e8ee67447-NEU"
  name                       = "LogManagement(DefaultWorkspace-2bd29ed6-34a6-42d7-8235-293e8ee67447-NEU)_LogManagement|TotalBytesReceivedByEachAzureRoleInstance"
  query                      = "search * | extend Type = $table | where Type == W3CIISLog | summarize AggregatedValue = sum(csBytes) by RoleInstance\r\n// Oql: Type=W3CIISLog | Measure Sum(csBytes) by RoleInstance // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PEF: True; SortI: True; SortF: True} // Version: 0.1.122"
  depends_on = [
    azurerm_log_analytics_workspace.res-127,
  ]
}
resource "azurerm_log_analytics_saved_search" "res-160" {
  category                   = "Log Management"
  display_name               = "Total Bytes received by each IIS Computer"
  log_analytics_workspace_id = "/subscriptions/2bd29ed6-34a6-42d7-8235-293e8ee67447/resourceGroups/DefaultResourceGroup-NEU/providers/Microsoft.OperationalInsights/workspaces/DefaultWorkspace-2bd29ed6-34a6-42d7-8235-293e8ee67447-NEU"
  name                       = "LogManagement(DefaultWorkspace-2bd29ed6-34a6-42d7-8235-293e8ee67447-NEU)_LogManagement|TotalBytesReceivedByEachIISComputer"
  query                      = "search * | extend Type = $table | where Type == W3CIISLog | summarize AggregatedValue = sum(csBytes) by Computer | limit 500000\r\n// Oql: Type=W3CIISLog | Measure Sum(csBytes) by Computer | top 500000 // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PEF: True; SortI: True; SortF: True} // Version: 0.1.122"
  depends_on = [
    azurerm_log_analytics_workspace.res-127,
  ]
}
resource "azurerm_log_analytics_saved_search" "res-161" {
  category                   = "Log Management"
  display_name               = "Total Bytes responded back to clients by Client IP Address"
  log_analytics_workspace_id = "/subscriptions/2bd29ed6-34a6-42d7-8235-293e8ee67447/resourceGroups/DefaultResourceGroup-NEU/providers/Microsoft.OperationalInsights/workspaces/DefaultWorkspace-2bd29ed6-34a6-42d7-8235-293e8ee67447-NEU"
  name                       = "LogManagement(DefaultWorkspace-2bd29ed6-34a6-42d7-8235-293e8ee67447-NEU)_LogManagement|TotalBytesRespondedToClientsByClientIPAddress"
  query                      = "search * | extend Type = $table | where Type == W3CIISLog | summarize AggregatedValue = sum(scBytes) by cIP\r\n// Oql: Type=W3CIISLog | Measure Sum(scBytes) by cIP // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PEF: True; SortI: True; SortF: True} // Version: 0.1.122"
  depends_on = [
    azurerm_log_analytics_workspace.res-127,
  ]
}
resource "azurerm_log_analytics_saved_search" "res-162" {
  category                   = "Log Management"
  display_name               = "Total Bytes responded back to clients by each IIS ServerIP Address"
  log_analytics_workspace_id = "/subscriptions/2bd29ed6-34a6-42d7-8235-293e8ee67447/resourceGroups/DefaultResourceGroup-NEU/providers/Microsoft.OperationalInsights/workspaces/DefaultWorkspace-2bd29ed6-34a6-42d7-8235-293e8ee67447-NEU"
  name                       = "LogManagement(DefaultWorkspace-2bd29ed6-34a6-42d7-8235-293e8ee67447-NEU)_LogManagement|TotalBytesRespondedToClientsByEachIISServerIPAddress"
  query                      = "search * | extend Type = $table | where Type == W3CIISLog | summarize AggregatedValue = sum(scBytes) by sIP\r\n// Oql: Type=W3CIISLog | Measure Sum(scBytes) by sIP // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PEF: True; SortI: True; SortF: True} // Version: 0.1.122"
  depends_on = [
    azurerm_log_analytics_workspace.res-127,
  ]
}
resource "azurerm_log_analytics_saved_search" "res-163" {
  category                   = "Log Management"
  display_name               = "Total Bytes sent by Client IP Address"
  log_analytics_workspace_id = "/subscriptions/2bd29ed6-34a6-42d7-8235-293e8ee67447/resourceGroups/DefaultResourceGroup-NEU/providers/Microsoft.OperationalInsights/workspaces/DefaultWorkspace-2bd29ed6-34a6-42d7-8235-293e8ee67447-NEU"
  name                       = "LogManagement(DefaultWorkspace-2bd29ed6-34a6-42d7-8235-293e8ee67447-NEU)_LogManagement|TotalBytesSentByClientIPAddress"
  query                      = "search * | extend Type = $table | where Type == W3CIISLog | summarize AggregatedValue = sum(csBytes) by cIP\r\n// Oql: Type=W3CIISLog | Measure Sum(csBytes) by cIP // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PEF: True; SortI: True; SortF: True} // Version: 0.1.122"
  depends_on = [
    azurerm_log_analytics_workspace.res-127,
  ]
}
resource "azurerm_log_analytics_saved_search" "res-164" {
  category                   = "Log Management"
  display_name               = "All Events with level \"Warning\""
  log_analytics_workspace_id = "/subscriptions/2bd29ed6-34a6-42d7-8235-293e8ee67447/resourceGroups/DefaultResourceGroup-NEU/providers/Microsoft.OperationalInsights/workspaces/DefaultWorkspace-2bd29ed6-34a6-42d7-8235-293e8ee67447-NEU"
  name                       = "LogManagement(DefaultWorkspace-2bd29ed6-34a6-42d7-8235-293e8ee67447-NEU)_LogManagement|WarningEvents"
  query                      = "Event | where EventLevelName == \"warning\" | sort by TimeGenerated desc\r\n// Oql: Type=Event EventLevelName=warning // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PTT: True; SortI: True; SortF: True} // Version: 0.1.122"
  depends_on = [
    azurerm_log_analytics_workspace.res-127,
  ]
}
resource "azurerm_log_analytics_saved_search" "res-165" {
  category                   = "Log Management"
  display_name               = "Windows Firewall Policy settings have changed"
  log_analytics_workspace_id = "/subscriptions/2bd29ed6-34a6-42d7-8235-293e8ee67447/resourceGroups/DefaultResourceGroup-NEU/providers/Microsoft.OperationalInsights/workspaces/DefaultWorkspace-2bd29ed6-34a6-42d7-8235-293e8ee67447-NEU"
  name                       = "LogManagement(DefaultWorkspace-2bd29ed6-34a6-42d7-8235-293e8ee67447-NEU)_LogManagement|WindowsFireawallPolicySettingsChanged"
  query                      = "Event | where EventLog == \"Microsoft-Windows-Windows Firewall With Advanced Security/Firewall\" and EventID == 2008 | sort by TimeGenerated desc\r\n// Oql: Type=Event EventLog=\"Microsoft-Windows-Windows Firewall With Advanced Security/Firewall\" EventID=2008 // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PTT: True; SortI: True; SortF: True} // Version: 0.1.122"
  depends_on = [
    azurerm_log_analytics_workspace.res-127,
  ]
}
resource "azurerm_log_analytics_saved_search" "res-166" {
  category                   = "Log Management"
  display_name               = "On which machines and how many times have Windows Firewall Policy settings changed"
  log_analytics_workspace_id = "/subscriptions/2bd29ed6-34a6-42d7-8235-293e8ee67447/resourceGroups/DefaultResourceGroup-NEU/providers/Microsoft.OperationalInsights/workspaces/DefaultWorkspace-2bd29ed6-34a6-42d7-8235-293e8ee67447-NEU"
  name                       = "LogManagement(DefaultWorkspace-2bd29ed6-34a6-42d7-8235-293e8ee67447-NEU)_LogManagement|WindowsFireawallPolicySettingsChangedByMachines"
  query                      = "Event | where EventLog == \"Microsoft-Windows-Windows Firewall With Advanced Security/Firewall\" and EventID == 2008 | summarize AggregatedValue = count() by Computer | limit 500000\r\n// Oql: Type=Event EventLog=\"Microsoft-Windows-Windows Firewall With Advanced Security/Firewall\" EventID=2008 | measure count() by Computer | top 500000 // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PTT: True; SortI: True; SortF: True} // Version: 0.1.122"
  depends_on = [
    azurerm_log_analytics_workspace.res-127,
  ]
}
resource "azurerm_network_watcher" "res-694" {
  location            = "northeurope"
  name                = "NetworkWatcher_northeurope"
  resource_group_name = "NetworkWatcherRG"
}
resource "azurerm_app_service_certificate" "res-695" {
  location            = "northeurope"
  name                = "AZMMKV01-MMWildcardKV2024"
  resource_group_name = "azmmclientapps"
  key_vault_secret_id = azurerm_key_vault_certificate.res-3.secret_id
}
resource "azurerm_windows_web_app" "res-696" {
  app_settings = {
    MM_DEFAULT_VERSION   = "mmakerah"
    MM_EXTENSION_VERSION = "&_#;|,N,FTX{SQs\\i*{n(c(x\\Z|A1qS,^VVjX#[20{Z7)7;$f6"
    WEBSITE_TIME_ZONE    = "GMT Standard Time"
  }
  client_affinity_enabled   = true
  https_only                = true
  location                  = "northeurope"
  name                      = "applehealth-matchmakersoftware"
  resource_group_name       = "azmmclientapps"
  service_plan_id           = "/subscriptions/2bd29ed6-34a6-42d7-8235-293e8ee67447/resourceGroups/AZMMCoreRG01/providers/Microsoft.Web/serverFarms/AZMMASP01"
  virtual_network_subnet_id = "/subscriptions/2bd29ed6-34a6-42d7-8235-293e8ee67447/resourceGroups/AZMMCoreRG01/providers/Microsoft.Network/virtualNetworks/AZMMVNET01/subnets/AppSNET01"
  connection_string {
    name  = "mmakerConnString"
    type  = "SQLAzure"
    value = "data source=tcp:azmmsql01.database.windows.net;initial catalog=17008;persist security info=True;App=EntityFramework;Connection Timeout=60"
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
    azurerm_subnet.res-12,
    azurerm_service_plan.res-123,
  ]
}
resource "azurerm_app_service_custom_hostname_binding" "res-701" {
  app_service_name    = "applehealth-matchmakersoftware"
  hostname            = "applehealth-matchmakersoftware.azurewebsites.net"
  resource_group_name = "azmmclientapps"
  depends_on = [
    azurerm_windows_web_app.res-696,
  ]
}
resource "azurerm_app_service_custom_hostname_binding" "res-702" {
  app_service_name    = "applehealth-matchmakersoftware"
  hostname            = "applehealth.matchmakersoftware.com"
  resource_group_name = "azmmclientapps"
  depends_on = [
    azurerm_windows_web_app.res-696,
  ]
}
resource "azurerm_windows_web_app" "res-870" {
  app_settings = {
    MM_DEFAULT_VERSION   = "mmakerdt"
    MM_EXTENSION_VERSION = "&)ku4\\92MxA_j|>*V,YS(@(#3=Ivs4<*0k^mwzpiS7JWe4QjC("
    WEBSITE_TIME_ZONE    = "GMT Standard Time"
  }
  client_affinity_enabled   = true
  https_only                = true
  location                  = "northeurope"
  name                      = "dt-matchmakersoftware"
  resource_group_name       = "azmmclientapps"
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
    azurerm_subnet.res-12,
    azurerm_service_plan.res-123,
  ]
}
resource "azurerm_app_service_custom_hostname_binding" "res-875" {
  app_service_name    = "dt-matchmakersoftware"
  hostname            = "dt-matchmakersoftware.azurewebsites.net"
  resource_group_name = "azmmclientapps"
  depends_on = [
    azurerm_windows_web_app.res-870,
  ]
}
resource "azurerm_app_service_custom_hostname_binding" "res-876" {
  app_service_name    = "dt-matchmakersoftware"
  hostname            = "dt.matchmakersoftware.com"
  resource_group_name = "azmmclientapps"
  depends_on = [
    azurerm_windows_web_app.res-870,
  ]
}
resource "azurerm_windows_web_app" "res-1044" {
  app_settings = {
    APPLICATIONINSIGHTS_CONNECTION_STRING      = "InstrumentationKey=e62501d5-31c1-45f2-a54e-8ea998494ed0;IngestionEndpoint=https://northeurope-2.in.applicationinsights.azure.com/;LiveEndpoint=https://northeurope.livediagnostics.monitor.azure.com/"
    ApplicationInsightsAgent_EXTENSION_VERSION = "~2"
    MM_DEFAULT_VERSION                         = "mmakerlta"
    MM_EXTENSION_VERSION                       = "n4-UL:g5aHw%et+Wt!r}i%$Hm6q4T%CupX2B8M)ftbco]*!?g%"
    WEBSITE_TIME_ZONE                          = "GMT Standard Time"
    XDT_MicrosoftApplicationInsights_Mode      = "default"
  }
  client_affinity_enabled   = true
  https_only                = true
  location                  = "northeurope"
  name                      = "lta-matchmakersoftware"
  resource_group_name       = "azmmclientapps"
  service_plan_id           = "/subscriptions/2bd29ed6-34a6-42d7-8235-293e8ee67447/resourceGroups/AZMMCoreRG01/providers/Microsoft.Web/serverFarms/AZMMASP01"
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
    azurerm_subnet.res-12,
    azurerm_service_plan.res-123,
  ]
}
resource "azurerm_app_service_custom_hostname_binding" "res-1049" {
  app_service_name    = "lta-matchmakersoftware"
  hostname            = "lta-matchmakersoftware.azurewebsites.net"
  resource_group_name = "azmmclientapps"
  depends_on = [
    azurerm_windows_web_app.res-1044,
  ]
}
resource "azurerm_app_service_custom_hostname_binding" "res-1050" {
  app_service_name    = "lta-matchmakersoftware"
  hostname            = "lta.matchmakersoftware.com"
  resource_group_name = "azmmclientapps"
  depends_on = [
    azurerm_windows_web_app.res-1044,
  ]
}
resource "azurerm_private_dns_a_record" "res-1218" {
  name                = "azmmsql01"
  records             = ["10.191.2.4"]
  resource_group_name = "azmmcorerg01"
  ttl                 = 3600
  zone_name           = "privatelink.database.windows.net"
  depends_on = [
    azurerm_private_dns_zone.res-6,
  ]
}
