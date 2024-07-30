
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

  identity {
    identity_ids = ["/subscriptions/2bd29ed6-34a6-42d7-8235-293e8ee67447/resourceGroups/AZMMCoreRG01/providers/Microsoft.ManagedIdentity/userAssignedIdentities/AppGWManagedID"]
    type         = "UserAssigned"
  }

lifecycle {
  prevent_destroy = true
}

sku {
    capacity = 1
    name     = "Standard_v2"
    tier     = "Standard_v2"
  }

  ssl_certificate {
  key_vault_secret_id = data.azurerm_key_vault_certificate.res-2.secret_id
  name                = "MMWildcard2024"
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

# start of applehealth config

  backend_address_pool {
    fqdns = ["applehealth-matchmakersoftware.azurewebsites.net"]
    name  = "applehealth-backendpool"
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

  http_listener {
    frontend_ip_configuration_name = "appGwPublicFrontendIpIPv4"
    frontend_port_name             = "port_443"
    host_name                      = "applehealth.matchmakersoftware.com"
    name                           = "applehealth-listenerhttps"
    protocol                       = "Https"
    require_sni                    = true
    ssl_certificate_name           = "MMWildcard2024"
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

# start of dt config
  backend_address_pool {
    fqdns = ["dt-matchmakersoftware.azurewebsites.net"]
    name  = "dt-backendpool"
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

  http_listener {
    frontend_ip_configuration_name = "appGwPublicFrontendIpIPv4"
    frontend_port_name             = "port_443"
    host_name                      = "dt.matchmakersoftware.com"
    name                           = "dt-listenerhttps"
    protocol                       = "Https"
    require_sni                    = true
    ssl_certificate_name           = "MMWildcard2024"
  }

  request_routing_rule {
    backend_address_pool_name  = "dt-backendpool"
    backend_http_settings_name = "dt-backendsetting"
    http_listener_name         = "dt-listenerhttps"
    name                       = "dt-routingrule"
    priority                   = 2
    rule_type                  = "Basic"
  }

#start of lta config

  backend_address_pool {
    fqdns = ["lta-matchmakersoftware.azurewebsites.net"]
    name  = "lta-backendpool"
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

  http_listener {
    frontend_ip_configuration_name = "appGwPublicFrontendIpIPv4"
    frontend_port_name             = "port_443"
    host_name                      = "lta.matchmakersoftware.com"
    name                           = "lta-listenerhttps"
    protocol                       = "Https"
    require_sni                    = true
    ssl_certificate_name           = "MMWildcard2024"
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
    backend_address_pool_name  = "lta-backendpool"
    backend_http_settings_name = "lta-backendsetting"
    http_listener_name         = "lta-listenerhttps"
    name                       = "lta-routingrule"
    priority                   = 1
    rule_type                  = "Basic"
  }
  
#end of lta config

#start of ir config

  backend_address_pool {
    fqdns = ["ir-matchmakersoftware.azurewebsites.net"]
    name  = "ir-backendpool"
  }

  backend_http_settings {
    affinity_cookie_name  = "ApplicationGatewayAffinity"
    cookie_based_affinity = "Enabled"
    name                  = "ir-backendsetting"
    port                  = 443
    probe_name            = "ir-healthprobe"
    protocol              = "Https"
    request_timeout       = 20
  }

  http_listener {
    frontend_ip_configuration_name = "appGwPublicFrontendIpIPv4"
    frontend_port_name             = "port_443"
    host_name                      = "ir.matchmakersoftware.com"
    name                           = "ir-listenerhttps"
    protocol                       = "Https"
    require_sni                    = true
    ssl_certificate_name           = "MMWildcard2024"
  }

  probe {
    host                = "ir-matchmakersoftware.azurewebsites.net"
    interval            = 30
    name                = "ir-healthprobe"
    path                = "/"
    protocol            = "Https"
    timeout             = 30
    unhealthy_threshold = 3
    match {
      status_code = ["200-399"]
    }
  }

  request_routing_rule {
    backend_address_pool_name  = "ir-backendpool"
    backend_http_settings_name = "ir-backendsetting"
    http_listener_name         = "ir-listenerhttps"
    name                       = "ir-routingrule"
    priority                   = 4
    rule_type                  = "Basic"
  }
  
  
#end of ir config

#start of rs config

  backend_address_pool {
    fqdns = ["rs-matchmakersoftware.azurewebsites.net"]
    name  = "rs-backendpool"
  }

  backend_http_settings {
    affinity_cookie_name  = "ApplicationGatewayAffinity"
    cookie_based_affinity = "Enabled"
    name                  = "rs-backendsetting"
    port                  = 443
    probe_name            = "rs-healthprobe"
    protocol              = "Https"
    request_timeout       = 20
  }

  http_listener {
    frontend_ip_configuration_name = "appGwPublicFrontendIpIPv4"
    frontend_port_name             = "port_443"
    host_name                      = "rs.matchmakersoftware.com"
    name                           = "rs-listenerhttps"
    protocol                       = "Https"
    require_sni                    = true
    ssl_certificate_name           = "MMWildcard2024"
  }

  probe {
    host                = "rs-matchmakersoftware.azurewebsites.net"
    interval            = 30
    name                = "rs-healthprobe"
    path                = "/"
    protocol            = "Https"
    timeout             = 30
    unhealthy_threshold = 3
    match {
      status_code = ["200-399"]
    }
  }

  request_routing_rule {
    backend_address_pool_name  = "rs-backendpool"
    backend_http_settings_name = "rs-backendsetting"
    http_listener_name         = "rs-listenerhttps"
    name                       = "rs-routingrule"
    priority                   = 5
    rule_type                  = "Basic"
  }
  


#end of rs config

#start of se config

  backend_address_pool {
    fqdns = ["se-matchmakersoftware.azurewebsites.net"]
    name  = "se-backendpool"
  }

  backend_http_settings {
    affinity_cookie_name  = "ApplicationGatewayAffinity"
    cookie_based_affinity = "Enabled"
    name                  = "se-backendsetting"
    port                  = 443
    probe_name            = "se-healthprobe"
    protocol              = "Https"
    request_timeout       = 20
  }

  http_listener {
    frontend_ip_configuration_name = "appGwPublicFrontendIpIPv4"
    frontend_port_name             = "port_443"
    host_name                      = "se.matchmakersoftware.com"
    name                           = "se-listenerhttps"
    protocol                       = "Https"
    require_sni                    = true
    ssl_certificate_name           = "MMWildcard2024"
  }

  probe {
    host                = "se-matchmakersoftware.azurewebsites.net"
    interval            = 30
    name                = "se-healthprobe"
    path                = "/"
    protocol            = "Https"
    timeout             = 30
    unhealthy_threshold = 3
    match {
      status_code = ["200-399"]
    }
  }

  request_routing_rule {
    backend_address_pool_name  = "se-backendpool"
    backend_http_settings_name = "se-backendsetting"
    http_listener_name         = "se-listenerhttps"
    name                       = "se-routingrule"
    priority                   = 7
    rule_type                  = "Basic"
  }
  
#end of se config

#start of smile-online config

  backend_address_pool {
    fqdns = ["smile-online-matchmakersoftware.azurewebsites.net"]
    name  = "smile-online-backendpool"
  }

  backend_http_settings {
    affinity_cookie_name  = "ApplicationGatewayAffinity"
    cookie_based_affinity = "Enabled"
    name                  = "smile-online-backendsetting"
    port                  = 443
    probe_name            = "smile-online-healthprobe"
    protocol              = "Https"
    request_timeout       = 20
  }

  http_listener {
    frontend_ip_configuration_name = "appGwPublicFrontendIpIPv4"
    frontend_port_name             = "port_443"
    host_name                      = "smile-online.matchmakersoftware.com"
    name                           = "smile-online-listenerhttps"
    protocol                       = "Https"
    require_sni                    = true
    ssl_certificate_name           = "MMWildcard2024"
  }

  probe {
    host                = "smile-online-matchmakersoftware.azurewebsites.net"
    interval            = 30
    name                = "smile-online-healthprobe"
    path                = "/"
    protocol            = "Https"
    timeout             = 30
    unhealthy_threshold = 3
    match {
      status_code = ["200-399"]
    }
  }

  request_routing_rule {
    backend_address_pool_name  = "smile-online-backendpool"
    backend_http_settings_name = "smile-online-backendsetting"
    http_listener_name         = "smile-online-listenerhttps"
    name                       = "smile-online-routingrule"
    priority                   = 6
    rule_type                  = "Basic"
  }
  
#end of smile-online config


#start of create-online config

  backend_address_pool {
    fqdns = ["create-online-matchmakersoftware.azurewebsites.net"]
    name  = "create-online-backendpool"
  }

  backend_http_settings {
    affinity_cookie_name  = "ApplicationGatewayAffinity"
    cookie_based_affinity = "Enabled"
    name                  = "create-online-backendsetting"
    port                  = 443
    probe_name            = "create-online-healthprobe"
    protocol              = "Https"
    request_timeout       = 20
  }

  http_listener {
    frontend_ip_configuration_name = "appGwPublicFrontendIpIPv4"
    frontend_port_name             = "port_443"
    host_name                      = "create-online.matchmakersoftware.com"
    name                           = "create-online-listenerhttps"
    protocol                       = "Https"
    require_sni                    = true
    ssl_certificate_name           = "MMWildcard2024"
  }

  probe {
    host                = "create-online-matchmakersoftware.azurewebsites.net"
    interval            = 30
    name                = "create-online-healthprobe"
    path                = "/"
    protocol            = "Https"
    timeout             = 30
    unhealthy_threshold = 3
    match {
      status_code = ["200-399"]
    }
  }

  request_routing_rule {
    backend_address_pool_name  = "create-online-backendpool"
    backend_http_settings_name = "create-online-backendsetting"
    http_listener_name         = "create-online-listenerhttps"
    name                       = "create-online-routingrule"
    priority                   = 8
    rule_type                  = "Basic"
  }
  
#end of create-online config

#start of br config
#change the priority to a unique number

  backend_address_pool {
    fqdns = ["br-matchmakersoftware.azurewebsites.net"]
    name  = "br-backendpool"
  }

  backend_http_settings {
    affinity_cookie_name  = "ApplicationGatewayAffinity"
    cookie_based_affinity = "Enabled"
    name                  = "br-backendsetting"
    port                  = 443
    probe_name            = "br-healthprobe"
    protocol              = "Https"
    request_timeout       = 20
  }

  http_listener {
    frontend_ip_configuration_name = "appGwPublicFrontendIpIPv4"
    frontend_port_name             = "port_443"
    host_name                      = "br.matchmakersoftware.com"
    name                           = "br-listenerhttps"
    protocol                       = "Https"
    require_sni                    = true
    ssl_certificate_name           = "MMWildcard2024"
  }

  probe {
    host                = "br-matchmakersoftware.azurewebsites.net"
    interval            = 30
    name                = "br-healthprobe"
    path                = "/"
    protocol            = "Https"
    timeout             = 30
    unhealthy_threshold = 3
    match {
      status_code = ["200-399"]
    }
  }

  request_routing_rule {
    backend_address_pool_name  = "br-backendpool"
    backend_http_settings_name = "br-backendsetting"
    http_listener_name         = "br-listenerhttps"
    name                       = "br-routingrule"
    priority                   = 10
    rule_type                  = "Basic"
  }
  
#end of br config

#start of pp config
#change the priority to a unique number

  backend_address_pool {
    fqdns = ["pp-matchmakersoftware.azurewebsites.net"]
    name  = "pp-backendpool"
  }

  backend_http_settings {
    affinity_cookie_name  = "ApplicationGatewayAffinity"
    cookie_based_affinity = "Enabled"
    name                  = "pp-backendsetting"
    port                  = 443
    probe_name            = "pp-healthprobe"
    protocol              = "Https"
    request_timeout       = 20
  }

  http_listener {
    frontend_ip_configuration_name = "appGwPublicFrontendIpIPv4"
    frontend_port_name             = "port_443"
    host_name                      = "pp.matchmakersoftware.com"
    name                           = "pp-listenerhttps"
    protocol                       = "Https"
    require_sni                    = true
    ssl_certificate_name           = "MMWildcard2024"
  }

  probe {
    host                = "pp-matchmakersoftware.azurewebsites.net"
    interval            = 30
    name                = "pp-healthprobe"
    path                = "/"
    protocol            = "Https"
    timeout             = 30
    unhealthy_threshold = 3
    match {
      status_code = ["200-399"]
    }
  }

  request_routing_rule {
    backend_address_pool_name  = "pp-backendpool"
    backend_http_settings_name = "pp-backendsetting"
    http_listener_name         = "pp-listenerhttps"
    name                       = "pp-routingrule"
    priority                   = 11
    rule_type                  = "Basic"
  }
  
#end of pp config

#start of pioneer-online config
#change the priority to a unique number

  backend_address_pool {
    fqdns = ["pioneer-online-matchmakersoftware.azurewebsites.net"]
    name  = "pioneer-online-backendpool"
  }

  backend_http_settings {
    affinity_cookie_name  = "ApplicationGatewayAffinity"
    cookie_based_affinity = "Enabled"
    name                  = "pioneer-online-backendsetting"
    port                  = 443
    probe_name            = "pioneer-online-healthprobe"
    protocol              = "Https"
    request_timeout       = 20
  }

  http_listener {
    frontend_ip_configuration_name = "appGwPublicFrontendIpIPv4"
    frontend_port_name             = "port_443"
    host_name                      = "pioneer-online.matchmakersoftware.com"
    name                           = "pioneer-online-listenerhttps"
    protocol                       = "Https"
    require_sni                    = true
    ssl_certificate_name           = "MMWildcard2024"
  }

  probe {
    host                = "pioneer-online-matchmakersoftware.azurewebsites.net"
    interval            = 30
    name                = "pioneer-online-healthprobe"
    path                = "/"
    protocol            = "Https"
    timeout             = 30
    unhealthy_threshold = 3
    match {
      status_code = ["200-399"]
    }
  }

  request_routing_rule {
    backend_address_pool_name  = "pioneer-online-backendpool"
    backend_http_settings_name = "pioneer-online-backendsetting"
    http_listener_name         = "pioneer-online-listenerhttps"
    name                       = "pioneer-online-routingrule"
    priority                   = 12
    rule_type                  = "Basic"
  }
  
#end of pioneer-online config

  
  depends_on = [
    azurerm_user_assigned_identity.res-3,
    azurerm_public_ip.res-8,
    azurerm_subnet.res-10,
  ]

}
