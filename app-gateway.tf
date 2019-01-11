data "azurerm_key_vault_secret" "cert" {
  name      = "${var.external_cert_name}"
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
      name     = "${var.external_cert_name}"
      data     = "${data.azurerm_key_vault_secret.cert.value}"
      password = ""
    },
  ]

  # Http Listeners
  httpListeners = [
    {
      name                    = "https-listener"
      FrontendIPConfiguration = "appGatewayFrontendIP"
      FrontendPort            = "frontendPort443"
      Protocol                = "Https"
      SslCertificate          = "${var.external_cert_name}"
      hostName                = "${var.external_hostname}"
    },
  ]

  # Backend address Pools
  backendAddressPools = [
    {
      name = "${var.product}-${var.env}"

      backendAddresses = "${module.palo_alto.untrusted_ips_fqdn}"
    },
  ]

  backendHttpSettingsCollection = [
    {
      name                           = "backend"
      port                           = 80
      Protocol                       = "Http"
      AuthenticationCertificates     = ""
      CookieBasedAffinity            = "Disabled"
      probeEnabled                   = "True"
      probe                          = "http-probe"
      PickHostNameFromBackendAddress = "False"
      Host                           = "${var.external_hostname}"
    },
  ]

  # Request routing rules
  requestRoutingRules = [
    {
      name                = "https"
      RuleType            = "Basic"
      httpListener        = "https-listener"
      backendAddressPool  = "${var.product}-${var.env}"
      backendHttpSettings = "backend"
    },
  ]

  probes = [
    {
      name                                = "http-probe"
      protocol                            = "Http"
      path                                = "/"
      interval                            = 30
      timeout                             = 30
      unhealthyThreshold                  = 5
      pickHostNameFromBackendHttpSettings = "false"
      backendHttpSettings                 = "backend"
      host                                = "${var.external_hostname}"
      healthyStatusCodes                  = "200-404"                  // MS returns 400 on /, allowing more codes in case they change it
    },
  ]
}
