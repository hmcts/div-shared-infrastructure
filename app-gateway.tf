data "azurerm_key_vault_secret" "pfe_cert" {
  name      = "${var.pfe_external_cert_name}"
  vault_uri = "${var.external_cert_vault_uri}"
}

data "azurerm_key_vault_secret" "aos_cert" {
  name      = "${var.aos_external_cert_name}"
  vault_uri = "${var.external_cert_vault_uri}"
}

data "azurerm_key_vault_secret" "dn_cert" {
  name      = "${var.dn_external_cert_name}"
  vault_uri = "${var.external_cert_vault_uri}"
}

data "azurerm_key_vault_secret" "da_cert" {
  name      = "${var.da_external_cert_name}"
  vault_uri = "${var.external_cert_vault_uri}"
}

locals {
  pfe_suffix  = "${var.env != "prod" ? "-pfe" : ""}"
  dn_suffix  = "${var.env != "prod" ? "-dn" : ""}"
  aos_suffix = "${var.env != "prod" ? "-aos" : ""}"
  da_suffix = "${var.env != "prod" ? "-da" : ""}"

  pfe_internal_hostname  = "${var.product}-pfe-${var.env}.service.core-compute-${var.env}.internal"
  dn_internal_hostname  = "${var.product}-dn-${var.env}.service.core-compute-${var.env}.internal"
  rfe_internal_hostname = "${var.product}-rfe-${var.env}.service.core-compute-${var.env}.internal"
  da_internal_hostname = "${var.product}-da-${var.env}.service.core-compute-${var.env}.internal"
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
      name     = "${var.pfe_external_cert_name}${local.pfe_suffix}"
      data     = "${data.azurerm_key_vault_secret.pfe_cert.value}"
      password = ""
    },
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
    {
      name     = "${var.da_external_cert_name}${local.da_suffix}"
      data     = "${data.azurerm_key_vault_secret.da_cert.value}"
      password = ""
    }
  ]

  # Http Listeners
  httpListeners = [
    {
      name                    = "${var.product}-http-pfe-redirect-listener"
      FrontendIPConfiguration = "appGatewayFrontendIP"
      FrontendPort            = "frontendPort80"
      Protocol                = "Http"
      SslCertificate          = ""
      hostName                = "${var.pfe_external_hostname}"
    },
    {
      name                    = "${var.product}-https-pfe-listener-palo"
      FrontendIPConfiguration = "appGatewayFrontendIP"
      FrontendPort            = "frontendPort443"
      Protocol                = "Https"
      SslCertificate          = "${var.pfe_external_cert_name}${local.pfe_suffix}"
      hostName                = "${var.pfe_external_hostname}"
    },
    {
      name                    = "${var.product}-http-rfe-redirect-listener"
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
      name                    = "${var.product}-http-ni-redirect-listener"
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
      SslCertificate          = "${var.dn_external_cert_name}${local.dn_suffix}"
      hostName                = "${var.dn_external_hostname}"
    },
    {
      name                    = "${var.product}-http-da-redirect-listener"
      FrontendIPConfiguration = "appGatewayFrontendIP"
      FrontendPort            = "frontendPort80"
      Protocol                = "Http"
      SslCertificate          = ""
      hostName                = "${var.da_external_hostname}"
    },
    {
      name                    = "${var.product}-https-da-listener-ilb"
      FrontendIPConfiguration = "appGatewayFrontendIP"
      FrontendPort            = "frontendPort443"
      Protocol                = "Https"
      SslCertificate          = "${var.da_external_cert_name}${local.da_suffix}"
      hostName                = "${var.da_external_hostname}"
    }
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
          ipAddress = "${local.rfe_internal_hostname}"
        }
      ]
    },
    {
      name = "${var.product}-${var.env}-da-backend-ilb"

      backendAddresses = [
        {
          ipAddress = "${local.da_internal_hostname}"
        }
      ]
    }
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
      PickHostNameFromBackendAddress = "False"
      HostName                       = ""
    },
    {
      name                           = "backend-80-da-ilb"
      port                           = 80
      Protocol                       = "Http"
      AuthenticationCertificates     = ""
      CookieBasedAffinity            = "Disabled"
      probeEnabled                   = "True"
      probe                          = "http-probe-da-ilb"
      PickHostNameFromBackendAddress = "False"
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
      httpListener        = "${var.product}-https-listener-ilb"
      backendAddressPool  = "${var.product}-${var.env}-backend-ilb"
      backendHttpSettings = "backend-80-ilb"
    },
    {
      name                = "http-da-ilb"
      ruleType            = "Basic"
      httpListener        = "${var.product}-https-da-listener-ilb"
      backendAddressPool  = "${var.product}-${var.env}-da-backend-ilb"
      backendHttpSettings = "backend-80-da-ilb"
    }
  ]

  probes = [
    {
      name                = "http-probe-pfe-palo"
      protocol            = "Http"
      path                = "/health"
      interval            = 30
      timeout             = 30
      unhealthyThreshold  = 5
      backendHttpSettings = "backend-80-palo"
      healthyStatusCodes  = "200"
      host                = "${local.pfe_internal_hostname}"
    },
    {
      name                = "http-probe-palo"
      protocol            = "Http"
      path                = "/health"
      interval            = 30
      timeout             = 30
      unhealthyThreshold  = 5
      backendHttpSettings = "backend-80-palo"
      healthyStatusCodes  = "200"
      host                = "${local.dn_internal_hostname}"
    },
    {
      name                = "http-probe-ilb"
      protocol            = "Http"
      path                = "/health"
      interval            = 30
      timeout             = 30
      unhealthyThreshold  = 5
      backendHttpSettings = "backend-80-ilb"
      healthyStatusCodes  = "200"
      host                = "${local.rfe_internal_hostname}"
    },
    {
      name                = "http-probe-da-ilb"
      protocol            = "Http"
      path                = "/health"
      interval            = 30
      timeout             = 30
      unhealthyThreshold  = 5
      backendHttpSettings = "backend-80-da-ilb"
      healthyStatusCodes  = "200"
      host                = "${local.da_internal_hostname}"
    }
  ]
}