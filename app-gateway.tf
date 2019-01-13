data "azurerm_key_vault_secret" "aos_cert" {
  name      = "${var.aos_external_cert_name}"
  vault_uri = "${var.external_cert_vault_uri}"
}

data "azurerm_key_vault_secret" "dn_cert" {
  name      = "${var.dn_external_cert_name}"
  vault_uri = "${var.external_cert_vault_uri}"
}

module "appGw" {
  source            = "git@github.com:hmcts/cnp-module-waf?ref=stripDownWf"
  env               = "${var.env}"
  subscription      = "${var.subscription}"
  location          = "${var.location}"
  wafName           = "${var.product}"
  resourcegroupname = "${azurerm_resource_group.rg.name}"

  # vNet connections
  gatewayIpConfigurations = [
    {
      name     = "internalNetwork"
      subnetId = "${data.azurerm_subnet.subnet_a.id}"
    },
  ]

  sslCertificates = [
    {
      name     = "${var.aos_external_cert_name}"
      data     = "${data.azurerm_key_vault_secret.aos_cert.value}"
      password = ""
    },
    {
      name     = "${var.dn_external_cert_name}"
      data     = "${data.azurerm_key_vault_secret.dn_cert.value}"
      password = ""
    },
  ]

  # Http Listeners
  httpListeners = [
    {
      name                    = "${var.product}-http-listener-ilb"
      FrontendIPConfiguration = "appGatewayFrontendIP"
      FrontendPort            = "frontendPort80"
      Protocol                = "Http"
      SslCertificate          = ""
      hostName                = "${var.aos_external_hostname}"
    },
    {
      name                    = "${var.product}-https-listener-ilb"
      FrontendIPConfiguration = "appGatewayFrontendIP"
      FrontendPort            = "frontendPort443"
      Protocol                = "Https"
      SslCertificate          = "${var.aos_external_cert_name}"
      hostName                = "${var.aos_external_hostname}"
    },
    {
      name                    = "${var.product}-http-listener-palo"
      FrontendIPConfiguration = "appGatewayFrontendIP"
      FrontendPort            = "frontendPort80"
      Protocol                = "Http"
      SslCertificate          = ""
      hostName                = "${var.dn_external_hostname}"
    },
    {
      name                    = "${var.product}-https-listener-palo"
      FrontendIPConfiguration = "appGatewayFrontendIP"
      FrontendPort            = "frontendPort443"
      Protocol                = "Https"
      SslCertificate          = "${var.dn_external_cert_name}"
      hostName                = "${var.dn_external_hostname}"
    },
  ]

  # Backend address Pools
  backendAddressPools = [
    {
      name = "${var.product}-${var.env}-backend-palo"

      backendAddresses = "${module.palo_alto.untrusted_ips_fqdn}"
    },
    {
      name             = "${var.product}-${var.env}-backend-pool"
      backendAddresses = "${var.product}-rfe-${var.env}.service.core-compute-${var.env}.internal"
    },
  ]

  backendHttpSettingsCollection = [
    {
      name                           = "backend-80-palo"
      port                           = 80
      Protocol                       = "Http"
      AuthenticationCertificates     = ""
      CookieBasedAffinity            = "Disabled"
      probeEnabled                   = "True"
      probe                          = "http-probe-palo"
      PickHostNameFromBackendAddress = "False"
      Host                           = "${var.dn_external_hostname}"
    },
    {
      name                           = "backend-443-palo"
      port                           = 443
      Protocol                       = "Https"
      AuthenticationCertificates     = "ilbCert"
      CookieBasedAffinity            = "Disabled"
      probeEnabled                   = "True"
      probe                          = "https-probe-palo"
      PickHostNameFromBackendAddress = "False"
      Host                           = "${var.dn_external_hostname}"
    },
    {
      name                           = "backend-80-ilb"
      port                           = 80
      Protocol                       = "Http"
      AuthenticationCertificates     = ""
      CookieBasedAffinity            = "Disabled"
      probeEnabled                   = "True"
      probe                          = "http-probe-ilb"
      PickHostNameFromBackendAddress = "False"
      Host                           = "${var.aos_external_hostname}"
    },
    {
      name                           = "backend-443-ilb"
      port                           = 443
      Protocol                       = "Https"
      AuthenticationCertificates     = "ilbCert"
      CookieBasedAffinity            = "Disabled"
      probeEnabled                   = "True"
      probe                          = "https-probe-ilb"
      PickHostNameFromBackendAddress = "False"
      Host                           = "${var.aos_external_hostname}"
    },
  ]

  # Request routing rules
  requestRoutingRules = [
    {
      name                = "http-palo"
      ruleType            = "Basic"
      httpListener        = "${var.product}-http-listener-palo"
      backendAddressPool  = "${var.product}-${var.env}-backend-pool"
      backendHttpSettings = "backend-80-palo"
    },
    {
      name                = "https-backend"
      ruleType            = "Basic"
      httpListener        = "${var.product}-http-listener-palo"
      backendAddressPool  = "${var.product}-${var.env}-backend-pool"
      backendHttpSettings = "backend-443-palo"
    },
    {
      name                = "http-ilb"
      ruleType            = "Basic"
      httpListener        = "${var.product}-https-listener-ilb"
      backendAddressPool  = "${var.product}-${var.env}-backend-pool"
      backendHttpSettings = "backend-443-ilb"
    },
    {
      name                = "https-ilb"
      ruleType            = "Basic"
      httpListener        = "${var.product}-https-listener-ilb"
      backendAddressPool  = "${var.product}-${var.env}-backend-pool"
      backendHttpSettings = "backend-80-ilb"
    },
  ]

  probes = [
    {
      name                                = "http-probe-palo"
      protocol                            = "Http"
      path                                = "/"
      interval                            = 30
      timeout                             = 30
      unhealthyThreshold                  = 5
      pickHostNameFromBackendHttpSettings = "false"
      backendHttpSettings                 = "backend-80-palo"
      host                                = "${var.aos_external_hostname}"
      healthyStatusCodes                  = "200-404"                      // MS returns 400 on /, allowing more codes in case they change it
    },
    {
      name                                = "https-probe-palo"
      protocol                            = "Https"
      path                                = "/"
      interval                            = 30
      timeout                             = 30
      unhealthyThreshold                  = 5
      pickHostNameFromBackendHttpSettings = "false"
      backendHttpSettings                 = "backend-443-palo"
      host                                = "${var.dn_external_hostname}"
      healthyStatusCodes                  = "200-404"                     // MS returns 400 on /, allowing more codes in case they change it
    },
    {
      name                                = "backend-80-ilb"
      protocol                            = "Http"
      path                                = "/"
      interval                            = 30
      timeout                             = 30
      unhealthyThreshold                  = 5
      pickHostNameFromBackendHttpSettings = "false"
      backendHttpSettings                 = "backend-80-ilb"
      host                                = "${var.aos_external_hostname}"
      healthyStatusCodes                  = "200-404"                      // MS returns 400 on /, allowing more codes in case they change it
    },
    {
      name                                = "https-probe-ilb"
      protocol                            = "Https"
      path                                = "/"
      interval                            = 30
      timeout                             = 30
      unhealthyThreshold                  = 5
      pickHostNameFromBackendHttpSettings = "false"
      backendHttpSettings                 = "backend-443-ilb"
      host                                = "${var.aos_external_hostname}"
      healthyStatusCodes                  = "200-404"                      // MS returns 400 on /, allowing more codes in case they change it
    },
  ]
}
