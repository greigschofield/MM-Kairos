
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


#start of pioneer-auriga config

  backend_address_pool {
    fqdns = ["pioneer-auriga-matchmakersoftware.azurewebsites.net"]
    name  = "pioneer-auriga-backendpool"
  }

  backend_http_settings {
    affinity_cookie_name  = "ApplicationGatewayAffinity"
    cookie_based_affinity = "Enabled"
    name                  = "pioneer-auriga-backendsetting"
    port                  = 443
    probe_name            = "pioneer-auriga-healthprobe"
    protocol              = "Https"
    request_timeout       = 20
  }

  http_listener {
    frontend_ip_configuration_name = "appGwPublicFrontendIpIPv4"
    frontend_port_name             = "port_443"
    host_name                      = "pioneer-auriga.matchmakersoftware.com"
    name                           = "pioneer-auriga-listenerhttps"
    protocol                       = "Https"
    require_sni                    = true
    ssl_certificate_name           = "MMWildcard2024"
  }

  probe {
    host                = "pioneer-auriga-matchmakersoftware.azurewebsites.net"
    interval            = 30
    name                = "pioneer-auriga-healthprobe"
    path                = "/"
    protocol            = "Https"
    timeout             = 30
    unhealthy_threshold = 3
    match {
      status_code = ["200-399"]
    }
  }

  request_routing_rule {
    backend_address_pool_name  = "pioneer-auriga-backendpool"
    backend_http_settings_name = "pioneer-auriga-backendsetting"
    http_listener_name         = "pioneer-auriga-listenerhttps"
    name                       = "pioneer-auriga-routingrule"
    priority                   = 13
    rule_type                  = "Basic"
  }
  
#end of pioneer-auriga config


#start of HIE config
#change the priority to a unique number

  backend_address_pool {
    fqdns = ["HIE-matchmakersoftware.azurewebsites.net"]
    name  = "HIE-backendpool"
  }

  backend_http_settings {
    affinity_cookie_name  = "ApplicationGatewayAffinity"
    cookie_based_affinity = "Enabled"
    name                  = "HIE-backendsetting"
    port                  = 443
    probe_name            = "HIE-healthprobe"
    protocol              = "Https"
    request_timeout       = 20
  }

  http_listener {
    frontend_ip_configuration_name = "appGwPublicFrontendIpIPv4"
    frontend_port_name             = "port_443"
    host_name                      = "HIE.matchmakersoftware.com"
    name                           = "HIE-listenerhttps"
    protocol                       = "Https"
    require_sni                    = true
    ssl_certificate_name           = "MMWildcard2024"
  }

  probe {
    host                = "HIE-matchmakersoftware.azurewebsites.net"
    interval            = 30
    name                = "HIE-healthprobe"
    path                = "/"
    protocol            = "Https"
    timeout             = 30
    unhealthy_threshold = 3
    match {
      status_code = ["200-399"]
    }
  }

  request_routing_rule {
    backend_address_pool_name  = "HIE-backendpool"
    backend_http_settings_name = "HIE-backendsetting"
    http_listener_name         = "HIE-listenerhttps"
    name                       = "HIE-routingrule"
    priority                   = 14
    rule_type                  = "Basic"
  }
  
#end of HIE config

/**
#start of psg-training config


  backend_address_pool {
    fqdns = ["psg-training-matchmakersoftware.azurewebsites.net"]
    name  = "psg-training-backendpool"
  }

  backend_http_settings {
    affinity_cookie_name  = "ApplicationGatewayAffinity"
    cookie_based_affinity = "Enabled"
    name                  = "psg-training-backendsetting"
    port                  = 443
    probe_name            = "psg-training-healthprobe"
    protocol              = "Https"
    request_timeout       = 20
  }

  http_listener {
    frontend_ip_configuration_name = "appGwPublicFrontendIpIPv4"
    frontend_port_name             = "port_443"
    host_name                      = "psg-training.matchmakersoftware.com"
    name                           = "psg-training-listenerhttps"
    protocol                       = "Https"
    require_sni                    = true
    ssl_certificate_name           = "MMWildcard2024"
  }

  probe {
    host                = "psg-training-matchmakersoftware.azurewebsites.net"
    interval            = 30
    name                = "psg-training-healthprobe"
    path                = "/"
    protocol            = "Https"
    timeout             = 30
    unhealthy_threshold = 3
    match {
      status_code = ["200-399"]
    }
  }

  request_routing_rule {
    backend_address_pool_name  = "psg-training-backendpool"
    backend_http_settings_name = "psg-training-backendsetting"
    http_listener_name         = "psg-training-listenerhttps"
    name                       = "psg-training-routingrule"
    priority                   = 16
    rule_type                  = "Basic"
  }
  
#end of psg-training config

*/ 
#psg-training removed by request from Dharmesh 15/10

#find and replace pro-nursing
#merge into app-gw-core file
#start of pro-nursing config
#change the priority to a unique number

  backend_address_pool {
    fqdns = ["pro-nursing-matchmakersoftware.azurewebsites.net"]
    name  = "pro-nursing-backendpool"
  }

  backend_http_settings {
    affinity_cookie_name  = "ApplicationGatewayAffinity"
    cookie_based_affinity = "Enabled"
    name                  = "pro-nursing-backendsetting"
    port                  = 443
    probe_name            = "pro-nursing-healthprobe"
    protocol              = "Https"
    request_timeout       = 20
  }

  http_listener {
    frontend_ip_configuration_name = "appGwPublicFrontendIpIPv4"
    frontend_port_name             = "port_443"
    host_name                      = "pro-nursing.matchmakersoftware.com"
    name                           = "pro-nursing-listenerhttps"
    protocol                       = "Https"
    require_sni                    = true
    ssl_certificate_name           = "MMWildcard2024"
  }

  probe {
    host                = "pro-nursing-matchmakersoftware.azurewebsites.net"
    interval            = 30
    name                = "pro-nursing-healthprobe"
    path                = "/"
    protocol            = "Https"
    timeout             = 30
    unhealthy_threshold = 3
    match {
      status_code = ["200-399"]
    }
  }

  request_routing_rule {
    backend_address_pool_name  = "pro-nursing-backendpool"
    backend_http_settings_name = "pro-nursing-backendsetting"
    http_listener_name         = "pro-nursing-listenerhttps"
    name                       = "pro-nursing-routingrule"
    priority                   = 17
    rule_type                  = "Basic"
  }
  
#end of pro-nursing config
  
#find and replace jobsworth
#merge into app-gw-core file
#start of jobsworth config
#change the priority to a unique number

  backend_address_pool {
    fqdns = ["jobsworth-matchmakersoftware.azurewebsites.net"]
    name  = "jobsworth-backendpool"
  }

  backend_http_settings {
    affinity_cookie_name  = "ApplicationGatewayAffinity"
    cookie_based_affinity = "Enabled"
    name                  = "jobsworth-backendsetting"
    port                  = 443
    probe_name            = "jobsworth-healthprobe"
    protocol              = "Https"
    request_timeout       = 20
  }

  http_listener {
    frontend_ip_configuration_name = "appGwPublicFrontendIpIPv4"
    frontend_port_name             = "port_443"
    host_name                      = "jobsworth.matchmakersoftware.com"
    name                           = "jobsworth-listenerhttps"
    protocol                       = "Https"
    require_sni                    = true
    ssl_certificate_name           = "MMWildcard2024"
  }

  probe {
    host                = "jobsworth-matchmakersoftware.azurewebsites.net"
    interval            = 30
    name                = "jobsworth-healthprobe"
    path                = "/"
    protocol            = "Https"
    timeout             = 30
    unhealthy_threshold = 3
    match {
      status_code = ["200-399"]
    }
  }

  request_routing_rule {
    backend_address_pool_name  = "jobsworth-backendpool"
    backend_http_settings_name = "jobsworth-backendsetting"
    http_listener_name         = "jobsworth-listenerhttps"
    name                       = "jobsworth-routingrule"
    priority                   = 18
    rule_type                  = "Basic"
  }
  
#end of jobsworth config


#start of clockworkedu config
#change the priority to a unique number

  backend_address_pool {
    fqdns = ["clockworkedu-matchmakersoftware.azurewebsites.net"]
    name  = "clockworkedu-backendpool"
  }

  backend_http_settings {
    affinity_cookie_name  = "ApplicationGatewayAffinity"
    cookie_based_affinity = "Enabled"
    name                  = "clockworkedu-backendsetting"
    port                  = 443
    probe_name            = "clockworkedu-healthprobe"
    protocol              = "Https"
    request_timeout       = 20
  }

  http_listener {
    frontend_ip_configuration_name = "appGwPublicFrontendIpIPv4"
    frontend_port_name             = "port_443"
    host_name                      = "clockworkedu.matchmakersoftware.com"
    name                           = "clockworkedu-listenerhttps"
    protocol                       = "Https"
    require_sni                    = true
    ssl_certificate_name           = "MMWildcard2024"
  }

  probe {
    host                = "clockworkedu-matchmakersoftware.azurewebsites.net"
    interval            = 30
    name                = "clockworkedu-healthprobe"
    path                = "/"
    protocol            = "Https"
    timeout             = 30
    unhealthy_threshold = 3
    match {
      status_code = ["200-399"]
    }
  }

  request_routing_rule {
    backend_address_pool_name  = "clockworkedu-backendpool"
    backend_http_settings_name = "clockworkedu-backendsetting"
    http_listener_name         = "clockworkedu-listenerhttps"
    name                       = "clockworkedu-routingrule"
    priority                   = 21
    rule_type                  = "Basic"
  }
  
#end of clockworkedu config


#find and replace supplystar
#merge into app-gw-core file
#start of supplystar config
#change the priority to a unique number

  backend_address_pool {
    fqdns = ["supplystar-matchmakersoftware.azurewebsites.net"]
    name  = "supplystar-backendpool"
  }

  backend_http_settings {
    affinity_cookie_name  = "ApplicationGatewayAffinity"
    cookie_based_affinity = "Enabled"
    name                  = "supplystar-backendsetting"
    port                  = 443
    probe_name            = "supplystar-healthprobe"
    protocol              = "Https"
    request_timeout       = 20
  }

  http_listener {
    frontend_ip_configuration_name = "appGwPublicFrontendIpIPv4"
    frontend_port_name             = "port_443"
    host_name                      = "supplystar.matchmakersoftware.com"
    name                           = "supplystar-listenerhttps"
    protocol                       = "Https"
    require_sni                    = true
    ssl_certificate_name           = "MMWildcard2024"
  }

  probe {
    host                = "supplystar-matchmakersoftware.azurewebsites.net"
    interval            = 30
    name                = "supplystar-healthprobe"
    path                = "/"
    protocol            = "Https"
    timeout             = 30
    unhealthy_threshold = 3
    match {
      status_code = ["200-399"]
    }
  }

  request_routing_rule {
    backend_address_pool_name  = "supplystar-backendpool"
    backend_http_settings_name = "supplystar-backendsetting"
    http_listener_name         = "supplystar-listenerhttps"
    name                       = "supplystar-routingrule"
    priority                   = 22
    rule_type                  = "Basic"
  }
  
#end of supplystar config


#find and replace clockwork-online
#merge into app-gw-core file
#start of clockwork-online config
#change the priority to a unique number

  backend_address_pool {
    fqdns = ["clockwork-online-matchmakersoftware.azurewebsites.net"]
    name  = "clockwork-online-backendpool"
  }

  backend_http_settings {
    affinity_cookie_name  = "ApplicationGatewayAffinity"
    cookie_based_affinity = "Enabled"
    name                  = "clockwork-online-backendsetting"
    port                  = 443
    probe_name            = "clockwork-online-healthprobe"
    protocol              = "Https"
    request_timeout       = 20
  }

  http_listener {
    frontend_ip_configuration_name = "appGwPublicFrontendIpIPv4"
    frontend_port_name             = "port_443"
    host_name                      = "clockwork-online.matchmakersoftware.com"
    name                           = "clockwork-online-listenerhttps"
    protocol                       = "Https"
    require_sni                    = true
    ssl_certificate_name           = "MMWildcard2024"
  }

  probe {
    host                = "clockwork-online-matchmakersoftware.azurewebsites.net"
    interval            = 30
    name                = "clockwork-online-healthprobe"
    path                = "/"
    protocol            = "Https"
    timeout             = 30
    unhealthy_threshold = 3
    match {
      status_code = ["200-399"]
    }
  }

  request_routing_rule {
    backend_address_pool_name  = "clockwork-online-backendpool"
    backend_http_settings_name = "clockwork-online-backendsetting"
    http_listener_name         = "clockwork-online-listenerhttps"
    name                       = "clockwork-online-routingrule"
    priority                   = 23
    rule_type                  = "Basic"
  }
  
#end of clockwork-online config


#find and replace pronursing-auriga
#merge into app-gw-core file
#start of pronursing-auriga config
#change the priority to a unique number

  backend_address_pool {
    fqdns = ["pronursing-auriga-matchmakersoftware.azurewebsites.net"]
    name  = "pronursing-auriga-backendpool"
  }

  backend_http_settings {
    affinity_cookie_name  = "ApplicationGatewayAffinity"
    cookie_based_affinity = "Enabled"
    name                  = "pronursing-auriga-backendsetting"
    port                  = 443
    probe_name            = "pronursing-auriga-healthprobe"
    protocol              = "Https"
    request_timeout       = 20
  }

  http_listener {
    frontend_ip_configuration_name = "appGwPublicFrontendIpIPv4"
    frontend_port_name             = "port_443"
    host_name                      = "pronursing-auriga.matchmakersoftware.com"
    name                           = "pronursing-auriga-listenerhttps"
    protocol                       = "Https"
    require_sni                    = true
    ssl_certificate_name           = "MMWildcard2024"
  }

  probe {
    host                = "pronursing-auriga-matchmakersoftware.azurewebsites.net"
    interval            = 30
    name                = "pronursing-auriga-healthprobe"
    path                = "/"
    protocol            = "Https"
    timeout             = 30
    unhealthy_threshold = 3
    match {
      status_code = ["200-399"]
    }
  }

  request_routing_rule {
    backend_address_pool_name  = "pronursing-auriga-backendpool"
    backend_http_settings_name = "pronursing-auriga-backendsetting"
    http_listener_name         = "pronursing-auriga-listenerhttps"
    name                       = "pronursing-auriga-routingrule"
    priority                   = 24
    rule_type                  = "Basic"
  }
  
#end of pronursing-auriga config

#find and replace psgtraining
#merge into app-gw-core file
#start of psgtraining config
#change the priority to a unique number

  backend_address_pool {
    fqdns = ["psgtraining-matchmakersoftware.azurewebsites.net"]
    name  = "psgtraining-backendpool"
  }

  backend_http_settings {
    affinity_cookie_name  = "ApplicationGatewayAffinity"
    cookie_based_affinity = "Enabled"
    name                  = "psgtraining-backendsetting"
    port                  = 443
    probe_name            = "psgtraining-healthprobe"
    protocol              = "Https"
    request_timeout       = 20
  }

  http_listener {
    frontend_ip_configuration_name = "appGwPublicFrontendIpIPv4"
    frontend_port_name             = "port_443"
    host_name                      = "psgtraining.matchmakersoftware.com"
    name                           = "psgtraining-listenerhttps"
    protocol                       = "Https"
    require_sni                    = true
    ssl_certificate_name           = "MMWildcard2024"
  }

  probe {
    host                = "psgtraining-matchmakersoftware.azurewebsites.net"
    interval            = 30
    name                = "psgtraining-healthprobe"
    path                = "/"
    protocol            = "Https"
    timeout             = 30
    unhealthy_threshold = 3
    match {
      status_code = ["200-399"]
    }
  }

  request_routing_rule {
    backend_address_pool_name  = "psgtraining-backendpool"
    backend_http_settings_name = "psgtraining-backendsetting"
    http_listener_name         = "psgtraining-listenerhttps"
    name                       = "psgtraining-routingrule"
    priority                   = 25
    rule_type                  = "Basic"
  }
  
#end of psgtraining config


#find and replace psgtraining-online
#merge into app-gw-core file
#start of psgtraining-online config
#change the priority to a unique number

  backend_address_pool {
    fqdns = ["psgtraining-online-matchmakersoftware.azurewebsites.net"]
    name  = "psgtraining-online-backendpool"
  }

  backend_http_settings {
    affinity_cookie_name  = "ApplicationGatewayAffinity"
    cookie_based_affinity = "Enabled"
    name                  = "psgtraining-online-backendsetting"
    port                  = 443
    probe_name            = "psgtraining-online-healthprobe"
    protocol              = "Https"
    request_timeout       = 20
  }

  http_listener {
    frontend_ip_configuration_name = "appGwPublicFrontendIpIPv4"
    frontend_port_name             = "port_443"
    host_name                      = "psgtraining-online.matchmakersoftware.com"
    name                           = "psgtraining-online-listenerhttps"
    protocol                       = "Https"
    require_sni                    = true
    ssl_certificate_name           = "MMWildcard2024"
  }

  probe {
    host                = "psgtraining-online-matchmakersoftware.azurewebsites.net"
    interval            = 30
    name                = "psgtraining-online-healthprobe"
    path                = "/"
    protocol            = "Https"
    timeout             = 30
    unhealthy_threshold = 3
    match {
      status_code = ["200-399"]
    }
  }

  request_routing_rule {
    backend_address_pool_name  = "psgtraining-online-backendpool"
    backend_http_settings_name = "psgtraining-online-backendsetting"
    http_listener_name         = "psgtraining-online-listenerhttps"
    name                       = "psgtraining-online-routingrule"
    priority                   = 26
    rule_type                  = "Basic"
  }
  
#end of psgtraining-online config


#find and replace autoexperts
#merge into app-gw-core file
#start of autoexperts config
#change the priority to a unique number

  backend_address_pool {
    fqdns = ["autoexperts-matchmakersoftware.azurewebsites.net"]
    name  = "autoexperts-backendpool"
  }

  backend_http_settings {
    affinity_cookie_name  = "ApplicationGatewayAffinity"
    cookie_based_affinity = "Enabled"
    name                  = "autoexperts-backendsetting"
    port                  = 443
    probe_name            = "autoexperts-healthprobe"
    protocol              = "Https"
    request_timeout       = 20
  }

  http_listener {
    frontend_ip_configuration_name = "appGwPublicFrontendIpIPv4"
    frontend_port_name             = "port_443"
    host_name                      = "autoexperts.matchmakersoftware.com"
    name                           = "autoexperts-listenerhttps"
    protocol                       = "Https"
    require_sni                    = true
    ssl_certificate_name           = "MMWildcard2024"
  }

  probe {
    host                = "autoexperts-matchmakersoftware.azurewebsites.net"
    interval            = 30
    name                = "autoexperts-healthprobe"
    path                = "/"
    protocol            = "Https"
    timeout             = 30
    unhealthy_threshold = 3
    match {
      status_code = ["200-399"]
    }
  }

  request_routing_rule {
    backend_address_pool_name  = "autoexperts-backendpool"
    backend_http_settings_name = "autoexperts-backendsetting"
    http_listener_name         = "autoexperts-listenerhttps"
    name                       = "autoexperts-routingrule"
    priority                   = 27
    rule_type                  = "Basic"
  }
  
#end of autoexperts config


#find and replace nowedu-training
#merge into app-gw-core file
#start of nowedu-training config
#change the priority to a unique number

  backend_address_pool {
    fqdns = ["nowedu-training-matchmakersoftware.azurewebsites.net"]
    name  = "nowedu-training-backendpool"
  }

  backend_http_settings {
    affinity_cookie_name  = "ApplicationGatewayAffinity"
    cookie_based_affinity = "Enabled"
    name                  = "nowedu-training-backendsetting"
    port                  = 443
    probe_name            = "nowedu-training-healthprobe"
    protocol              = "Https"
    request_timeout       = 20
  }

  http_listener {
    frontend_ip_configuration_name = "appGwPublicFrontendIpIPv4"
    frontend_port_name             = "port_443"
    host_name                      = "nowedu-training.matchmakersoftware.com"
    name                           = "nowedu-training-listenerhttps"
    protocol                       = "Https"
    require_sni                    = true
    ssl_certificate_name           = "MMWildcard2024"
  }

  probe {
    host                = "nowedu-training-matchmakersoftware.azurewebsites.net"
    interval            = 30
    name                = "nowedu-training-healthprobe"
    path                = "/"
    protocol            = "Https"
    timeout             = 30
    unhealthy_threshold = 3
    match {
      status_code = ["200-399"]
    }
  }

  request_routing_rule {
    backend_address_pool_name  = "nowedu-training-backendpool"
    backend_http_settings_name = "nowedu-training-backendsetting"
    http_listener_name         = "nowedu-training-listenerhttps"
    name                       = "nowedu-training-routingrule"
    priority                   = 28
    rule_type                  = "Basic"
  }
  
#end of nowedu-training config


#find and replace chasetaylor
#merge into app-gw-core file
#start of chasetaylor config
#change the priority to a unique number

  backend_address_pool {
    fqdns = ["chasetaylor-matchmakersoftware.azurewebsites.net"]
    name  = "chasetaylor-backendpool"
  }

  backend_http_settings {
    affinity_cookie_name  = "ApplicationGatewayAffinity"
    cookie_based_affinity = "Enabled"
    name                  = "chasetaylor-backendsetting"
    port                  = 443
    probe_name            = "chasetaylor-healthprobe"
    protocol              = "Https"
    request_timeout       = 20
  }

  http_listener {
    frontend_ip_configuration_name = "appGwPublicFrontendIpIPv4"
    frontend_port_name             = "port_443"
    host_name                      = "chasetaylor.matchmakersoftware.com"
    name                           = "chasetaylor-listenerhttps"
    protocol                       = "Https"
    require_sni                    = true
    ssl_certificate_name           = "MMWildcard2024"
  }

  probe {
    host                = "chasetaylor-matchmakersoftware.azurewebsites.net"
    interval            = 30
    name                = "chasetaylor-healthprobe"
    path                = "/"
    protocol            = "Https"
    timeout             = 30
    unhealthy_threshold = 3
    match {
      status_code = ["200-399"]
    }
  }

  request_routing_rule {
    backend_address_pool_name  = "chasetaylor-backendpool"
    backend_http_settings_name = "chasetaylor-backendsetting"
    http_listener_name         = "chasetaylor-listenerhttps"
    name                       = "chasetaylor-routingrule"
    priority                   = 29
    rule_type                  = "Basic"
  }
  
#end of chasetaylor config


#find and replace autoexperts-online
#merge into app-gw-core file
#start of autoexperts-online config
#change the priority to a unique number

  backend_address_pool {
    fqdns = ["autoexperts-online-matchmakersoftware.azurewebsites.net"]
    name  = "autoexperts-online-backendpool"
  }

  backend_http_settings {
    affinity_cookie_name  = "ApplicationGatewayAffinity"
    cookie_based_affinity = "Enabled"
    name                  = "autoexperts-online-backendsetting"
    port                  = 443
    probe_name            = "autoexperts-online-healthprobe"
    protocol              = "Https"
    request_timeout       = 20
  }

  http_listener {
    frontend_ip_configuration_name = "appGwPublicFrontendIpIPv4"
    frontend_port_name             = "port_443"
    host_name                      = "autoexperts-online.matchmakersoftware.com"
    name                           = "autoexperts-online-listenerhttps"
    protocol                       = "Https"
    require_sni                    = true
    ssl_certificate_name           = "MMWildcard2024"
  }

  probe {
    host                = "autoexperts-online-matchmakersoftware.azurewebsites.net"
    interval            = 30
    name                = "autoexperts-online-healthprobe"
    path                = "/"
    protocol            = "Https"
    timeout             = 30
    unhealthy_threshold = 3
    match {
      status_code = ["200-399"]
    }
  }

  request_routing_rule {
    backend_address_pool_name  = "autoexperts-online-backendpool"
    backend_http_settings_name = "autoexperts-online-backendsetting"
    http_listener_name         = "autoexperts-online-listenerhttps"
    name                       = "autoexperts-online-routingrule"
    priority                   = 30
    rule_type                  = "Basic"
  }
  
#end of autoexperts-online config


#find and replace vantage
#merge into app-gw-core file
#start of vantage config
#change the priority to a unique number

  backend_address_pool {
    fqdns = ["vantage-matchmakersoftware.azurewebsites.net"]
    name  = "vantage-backendpool"
  }

  backend_http_settings {
    affinity_cookie_name  = "ApplicationGatewayAffinity"
    cookie_based_affinity = "Enabled"
    name                  = "vantage-backendsetting"
    port                  = 443
    probe_name            = "vantage-healthprobe"
    protocol              = "Https"
    request_timeout       = 20
  }

  http_listener {
    frontend_ip_configuration_name = "appGwPublicFrontendIpIPv4"
    frontend_port_name             = "port_443"
    host_name                      = "vantage.matchmakersoftware.com"
    name                           = "vantage-listenerhttps"
    protocol                       = "Https"
    require_sni                    = true
    ssl_certificate_name           = "MMWildcard2024"
  }

  probe {
    host                = "vantage-matchmakersoftware.azurewebsites.net"
    interval            = 30
    name                = "vantage-healthprobe"
    path                = "/"
    protocol            = "Https"
    timeout             = 30
    unhealthy_threshold = 3
    match {
      status_code = ["200-399"]
    }
  }

  request_routing_rule {
    backend_address_pool_name  = "vantage-backendpool"
    backend_http_settings_name = "vantage-backendsetting"
    http_listener_name         = "vantage-listenerhttps"
    name                       = "vantage-routingrule"
    priority                   = 31
    rule_type                  = "Basic"
  }
  
#end of vantage config


#find and replace nowedu-online
#merge into app-gw-core file
#start of nowedu-online config
#change the priority to a unique number

  backend_address_pool {
    fqdns = ["nowedu-online-matchmakersoftware.azurewebsites.net"]
    name  = "nowedu-online-backendpool"
  }

  backend_http_settings {
    affinity_cookie_name  = "ApplicationGatewayAffinity"
    cookie_based_affinity = "Enabled"
    name                  = "nowedu-online-backendsetting"
    port                  = 443
    probe_name            = "nowedu-online-healthprobe"
    protocol              = "Https"
    request_timeout       = 20
  }

  http_listener {
    frontend_ip_configuration_name = "appGwPublicFrontendIpIPv4"
    frontend_port_name             = "port_443"
    host_name                      = "nowedu-online.matchmakersoftware.com"
    name                           = "nowedu-online-listenerhttps"
    protocol                       = "Https"
    require_sni                    = true
    ssl_certificate_name           = "MMWildcard2024"
  }

  probe {
    host                = "nowedu-online-matchmakersoftware.azurewebsites.net"
    interval            = 30
    name                = "nowedu-online-healthprobe"
    path                = "/"
    protocol            = "Https"
    timeout             = 30
    unhealthy_threshold = 3
    match {
      status_code = ["200-399"]
    }
  }

  request_routing_rule {
    backend_address_pool_name  = "nowedu-online-backendpool"
    backend_http_settings_name = "nowedu-online-backendsetting"
    http_listener_name         = "nowedu-online-listenerhttps"
    name                       = "nowedu-online-routingrule"
    priority                   = 32
    rule_type                  = "Basic"
  }
  
#end of nowedu-online config


#find and replace nowedu
#merge into app-gw-core file
#start of nowedu config
#change the priority to a unique number

  backend_address_pool {
    fqdns = ["nowedu-matchmakersoftware.azurewebsites.net"]
    name  = "nowedu-backendpool"
  }

  backend_http_settings {
    affinity_cookie_name  = "ApplicationGatewayAffinity"
    cookie_based_affinity = "Enabled"
    name                  = "nowedu-backendsetting"
    port                  = 443
    probe_name            = "nowedu-healthprobe"
    protocol              = "Https"
    request_timeout       = 20
  }

  http_listener {
    frontend_ip_configuration_name = "appGwPublicFrontendIpIPv4"
    frontend_port_name             = "port_443"
    host_name                      = "nowedu.matchmakersoftware.com"
    name                           = "nowedu-listenerhttps"
    protocol                       = "Https"
    require_sni                    = true
    ssl_certificate_name           = "MMWildcard2024"
  }

  probe {
    host                = "nowedu-matchmakersoftware.azurewebsites.net"
    interval            = 30
    name                = "nowedu-healthprobe"
    path                = "/"
    protocol            = "Https"
    timeout             = 30
    unhealthy_threshold = 3
    match {
      status_code = ["200-399"]
    }
  }

  request_routing_rule {
    backend_address_pool_name  = "nowedu-backendpool"
    backend_http_settings_name = "nowedu-backendsetting"
    http_listener_name         = "nowedu-listenerhttps"
    name                       = "nowedu-routingrule"
    priority                   = 33
    rule_type                  = "Basic"
  }
  
#end of nowedu config


#find and replace nowedu-auriga
#merge into app-gw-core file
#start of nowedu-auriga config
#change the priority to a unique number

  backend_address_pool {
    fqdns = ["nowedu-auriga-matchmakersoftware.azurewebsites.net"]
    name  = "nowedu-auriga-backendpool"
  }

  backend_http_settings {
    affinity_cookie_name  = "ApplicationGatewayAffinity"
    cookie_based_affinity = "Enabled"
    name                  = "nowedu-auriga-backendsetting"
    port                  = 443
    probe_name            = "nowedu-auriga-healthprobe"
    protocol              = "Https"
    request_timeout       = 20
  }

  http_listener {
    frontend_ip_configuration_name = "appGwPublicFrontendIpIPv4"
    frontend_port_name             = "port_443"
    host_name                      = "nowedu-auriga.matchmakersoftware.com"
    name                           = "nowedu-auriga-listenerhttps"
    protocol                       = "Https"
    require_sni                    = true
    ssl_certificate_name           = "MMWildcard2024"
  }

  probe {
    host                = "nowedu-auriga-matchmakersoftware.azurewebsites.net"
    interval            = 30
    name                = "nowedu-auriga-healthprobe"
    path                = "/"
    protocol            = "Https"
    timeout             = 30
    unhealthy_threshold = 3
    match {
      status_code = ["200-399"]
    }
  }

  request_routing_rule {
    backend_address_pool_name  = "nowedu-auriga-backendpool"
    backend_http_settings_name = "nowedu-auriga-backendsetting"
    http_listener_name         = "nowedu-auriga-listenerhttps"
    name                       = "nowedu-auriga-routingrule"
    priority                   = 34
    rule_type                  = "Basic"
  }
  
#end of nowedu-auriga config


  depends_on = [
    azurerm_user_assigned_identity.res-3,
    azurerm_public_ip.res-8,
    azurerm_subnet.res-10,
  ]

}
