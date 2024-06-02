resource "azurerm_resource_group" "res-0" {
  location = "northeurope"
  name     = "AZMMCoreRG01"
}
resource "azurerm_key_vault" "res-1" {
  location            = "northeurope"
  name                = "AZMMKV01"
  resource_group_name = "AZMMCoreRG01"
  sku_name            = "standard"
  tenant_id           = "3a243d17-3d9f-43e2-96a9-222d4b6fada1"
  depends_on = [
    azurerm_resource_group.res-0,
  ]
}
/**
resource "azurerm_key_vault_certificate" "res-2" {
  key_vault_id = "/subscriptions/2bd29ed6-34a6-42d7-8235-293e8ee67447/resourceGroups/AZMMCoreRG01/providers/Microsoft.KeyVault/vaults/AZMMKV01"
  name         = "AZMMKV01-MMWildcardKV2024"
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
    azurerm_key_vault.res-1,
  ]
}
*/

data "azurerm_key_vault_certificate" "res-2" {
  name         = "AZMMKV01-MMWildcardKV2024"
  key_vault_id = azurerm_key_vault.res-1.id
}


resource "azurerm_user_assigned_identity" "res-3" {
  location            = "uksouth"
  name                = "AppGWManagedID"
  resource_group_name = "AZMMCoreRG01"
  depends_on = [
    azurerm_resource_group.res-0,
  ]
}
resource "azurerm_application_gateway" "res-4" {
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
  /**
  ssl_certificate {
    key_vault_secret_id = "https://azmmkv01.vault.azure.net/secrets/MMWildcardKV2024/e1fac60ef8e54c1bba8d835bd1fb0d52"
    name                = "MMWildcard2024"
  }

  */

  ssl_certificate {
  key_vault_secret_id = data.azurerm_key_vault_certificate.res-2.secret_id
  name                = "MMWildcard2024"
  }
  
  /**ssl_certificate {
    name = "matchmakerwildcard"
  }
  */

  depends_on = [
    azurerm_user_assigned_identity.res-3,
    azurerm_public_ip.res-8,
    azurerm_subnet.res-10,
  ]
}
resource "azurerm_private_dns_zone" "res-5" {
  name                = "privatelink.database.windows.net"
  resource_group_name = "AZMMCoreRG01"
  depends_on = [
    azurerm_resource_group.res-0,
  ]
}
resource "azurerm_private_dns_zone_virtual_network_link" "res-6" {
  name                  = "mp2zoxnjsbkyw"
  private_dns_zone_name = "privatelink.database.windows.net"
  resource_group_name   = "AZMMCoreRG01"
  virtual_network_id    = "/subscriptions/2bd29ed6-34a6-42d7-8235-293e8ee67447/resourceGroups/AZMMCoreRG01/providers/Microsoft.Network/virtualNetworks/AZMMVNET01"
  depends_on = [
    azurerm_private_dns_zone.res-5,
    azurerm_virtual_network.res-9,
  ]
}
resource "azurerm_private_endpoint" "res-7" {
  location            = "northeurope"
  name                = "AZMMSQL01PEP01"
  resource_group_name = "AZMMCoreRG01"
  subnet_id           = "/subscriptions/2bd29ed6-34a6-42d7-8235-293e8ee67447/resourceGroups/AZMMCoreRG01/providers/Microsoft.Network/virtualNetworks/AZMMVNET01/subnets/SQLSNET01"
  private_service_connection {
    is_manual_connection           = false
    name                           = "AZMMSQL01PEP01"
    private_connection_resource_id = "/subscriptions/2bd29ed6-34a6-42d7-8235-293e8ee67447/resourceGroups/AZMMCoreRG02/providers/Microsoft.Sql/servers/azmmsql01"
    subresource_names              = ["SqlServer"]
  }
  depends_on = [
    azurerm_subnet.res-12,
  ]
}
resource "azurerm_public_ip" "res-8" {
  allocation_method   = "Static"
  location            = "northeurope"
  name                = "AZMMAGW01PIP"
  resource_group_name = "AZMMCoreRG01"
  sku                 = "Standard"
  depends_on = [
    azurerm_resource_group.res-0,
  ]
}
resource "azurerm_virtual_network" "res-9" {
  address_space       = ["10.191.0.0/16"]
  location            = "northeurope"
  name                = "AZMMVNET01"
  resource_group_name = "AZMMCoreRG01"
  depends_on = [
    azurerm_resource_group.res-0,
  ]
}
resource "azurerm_subnet" "res-10" {
  address_prefixes     = ["10.191.3.0/24"]
  name                 = "AGWSNET01"
  resource_group_name  = "AZMMCoreRG01"
  virtual_network_name = "AZMMVNET01"
  depends_on = [
    azurerm_virtual_network.res-9,
  ]
}
resource "azurerm_subnet" "res-11" {
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
    azurerm_virtual_network.res-9,
  ]
}
resource "azurerm_subnet" "res-12" {
  address_prefixes     = ["10.191.2.0/24"]
  name                 = "SQLSNET01"
  resource_group_name  = "AZMMCoreRG01"
  virtual_network_name = "AZMMVNET01"
  depends_on = [
    azurerm_virtual_network.res-9,
  ]
}
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
resource "azurerm_monitor_smart_detector_alert_rule" "res-14" {
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
  depends_on = [
    azurerm_resource_group.res-0,
  ]
}
resource "azurerm_monitor_action_group" "res-15" {
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
  depends_on = [
    azurerm_resource_group.res-0,
  ]
}
resource "azurerm_application_insights" "res-16" {
  application_type    = "web"
  location            = "northeurope"
  name                = "AZMMApp01"
  resource_group_name = "AZMMCoreRG01"
  sampling_percentage = 0
  workspace_id        = "/subscriptions/2bd29ed6-34a6-42d7-8235-293e8ee67447/resourceGroups/DefaultResourceGroup-NEU/providers/Microsoft.OperationalInsights/workspaces/DefaultWorkspace-2bd29ed6-34a6-42d7-8235-293e8ee67447-NEU"
  depends_on = [
    azurerm_resource_group.res-0,
  ]
}
resource "azurerm_private_dns_a_record" "res-17" {
  name                = "azmmsql01"
  records             = ["10.191.2.4"]
  resource_group_name = "azmmcorerg01"
  ttl                 = 3600
  zone_name           = "privatelink.database.windows.net"
  depends_on = [
    azurerm_private_dns_zone.res-5,
  ]
}
