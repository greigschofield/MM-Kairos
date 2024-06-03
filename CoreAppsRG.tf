
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

resource "azurerm_app_service_certificate" "azmmclientrg-365" {
  location            = "northeurope"
  name                = "AZMMKV01-MMWildcardKV2024"
  resource_group_name = "azmmclientapps"
key_vault_secret_id = "https://azmmkv01.vault.azure.net/secrets/MMWildcardKV2024/e1fac60ef8e54c1bba8d835bd1fb0d52"
  depends_on = [
    azurerm_resource_group.azmmclientrg-0,
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


  /**
  ssl_certificate {
    key_vault_secret_id = "https://azmmkv01.vault.azure.net/secrets/MMWildcardKV2024/e1fac60ef8e54c1bba8d835bd1fb0d52"
    name                = "MMWildcard2024"
  }

  */

 
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
