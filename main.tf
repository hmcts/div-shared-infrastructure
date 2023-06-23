provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.product}-${var.env}"
  location = var.location

  tags = var.common_tags
}

module "redis-cache" {
  source      = "git@github.com:hmcts/cnp-module-redis?ref=master"
  product     = var.product
  location    = var.location
  env         = var.env
  private_endpoint_enabled = true
  redis_version = "6"
  business_area = "cft"
  public_network_access_enabled = false
  common_tags = var.common_tags
}

resource "azurerm_key_vault_secret" "redis_connection_string" {
  name         = "redis-connection-string"
  value        = "redis://ignore:${urlencode(module.redis-cache.access_key)}@${module.redis-cache.host_name}:${module.redis-cache.redis_port}?tls=true"
  key_vault_id = data.azurerm_key_vault.div_key_vault.id
}