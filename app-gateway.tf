data "azurerm_key_vault_secret" "aos_cert" {
  name      = "${var.aos_external_cert_name}"
  vault_uri = "${var.external_cert_vault_uri}"
}

data "azurerm_key_vault_secret" "dn_cert" {
  name      = "${var.dn_external_cert_name}"
  vault_uri = "${var.external_cert_vault_uri}"
}

locals {
  dn_suffix  = "${var.env != "prod" ? "-dn" : ""}"
  aos_suffix = "${var.env != "prod" ? "-aos" : ""}"

  dn_internal_hostname = "div-dn-${var.env}.service.core-compute-${var.env}.internal"
}

module "appGw" {
  source            = "git@github.com:hmcts/cnp-module-waf?ref=master"
  env               = "${var.env}"
  subscription      = "${var.subscription}"
  location          = "${var.location}"
  wafName           = "${var.product}"
  resourcegroupname = "${azurerm_resource_group.rg.name}"
  common_tags       = "${var.common_tags}"

  # vNet connections
  gatewayIpConfigurations = [
    {
      name     = "internalNetwork"
      subnetId = "${data.azurerm_subnet.subnet_a.id}"
    },
  ]

  sslCertificates = [
    {
      name     = "${var.aos_external_cert_name}${local.aos_suffix}"
      data     = "${data.azurerm_key_vault_secret.aos_cert.value}"
      password = ""
    },
    {
      name     = "${var.dn_external_cert_name}${local.dn_suffix}"
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
      SslCertificate          = "${var.aos_external_cert_name}${local.aos_suffix}"
      hostName                = "${var.aos_external_hostname}"
    },
    {
      name                    = "${var.product}-https-listener-palo"
      FrontendIPConfiguration = "appGatewayFrontendIP"
      FrontendPort            = "frontendPort443"
      Protocol                = "Https"
      SslCertificate          = "${var.dn_external_cert_name}${local.dn_suffix}"
      hostName                = "${var.dn_external_hostname}"
    },
  ]

  backendAddressPools = [
    {
      name             = "${var.product}-${var.env}-backend-palo"
      backendAddresses = "${module.palo_alto.untrusted_ips_fqdn}"
    },
    {
      name = "${var.product}-${var.env}-backend-ilb"

      backendAddresses = [
        {
          ipAddress = "${var.product}-rfe-${var.env}.service.core-compute-${var.env}.internal"
        },
      ]
    },
  ]

  use_authentication_cert = true

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
      HostName                       = ""
    },
    {
      name                           = "backend-80-ilb"
      port                           = 80
      Protocol                       = "Http"
      AuthenticationCertificates     = ""
      CookieBasedAffinity            = "Disabled"
      probeEnabled                   = "True"
      probe                          = "http-probe-ilb"
      PickHostNameFromBackendAddress = "True"
      HostName                       = ""
    },
    {
      name                           = "backend-443-ilb"
      port                           = 443
      Protocol                       = "Https"
      AuthenticationCertificates     = "ilbCert"
      CookieBasedAffinity            = "Disabled"
      probeEnabled                   = "True"
      probe                          = "https-probe-ilb"
      PickHostNameFromBackendAddress = "True"
      HostName                       = ""
    },
  ]

  # Request routing rules
  requestRoutingRules = [
    {
      name                = "http-palo"
      ruleType            = "Basic"
      httpListener        = "${var.product}-https-listener-palo"
      backendAddressPool  = "${var.product}-${var.env}-backend-palo"
      backendHttpSettings = "backend-80-palo"
    },
    {
      name                = "http-ilb"
      ruleType            = "Basic"
      httpListener        = "${var.product}-http-listener-ilb"
      backendAddressPool  = "${var.product}-${var.env}-backend-ilb"
      backendHttpSettings = "backend-80-ilb"
    },
    {
      name                = "https-ilb"
      ruleType            = "Basic"
      httpListener        = "${var.product}-https-listener-ilb"
      backendAddressPool  = "${var.product}-${var.env}-backend-ilb"
      backendHttpSettings = "backend-443-ilb"
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

      //      host                                = "${local.dn_internal_hostname}"
      healthyStatusCodes = "200"
    },
    {
      name                                = "http-probe-ilb"
      protocol                            = "Http"
      path                                = "/"
      interval                            = 30
      timeout                             = 30
      unhealthyThreshold                  = 5
      pickHostNameFromBackendHttpSettings = "true"
      backendHttpSettings                 = "backend-80-ilb"
      healthyStatusCodes                  = "200"
    },
    {
      name                                = "https-probe-ilb"
      protocol                            = "Https"
      path                                = "/"
      interval                            = 30
      timeout                             = 30
      unhealthyThreshold                  = 5
      pickHostNameFromBackendHttpSettings = "true"
      backendHttpSettings                 = "backend-443-ilb"
      healthyStatusCodes                  = "200"
    },
  ]
}
