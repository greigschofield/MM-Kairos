
#find and replace create-online
#merge into app-gw-core file
#start of create-online config
#change the priority to a unique number

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
    priority                   = 6
    rule_type                  = "Basic"
  }
  
#end of create-online config