module "div-vault" {
  source                  = "git@github.com:hmcts/cnp-module-key-vault?ref=master"
  name                    = "${var.product}-${var.env}"
  product                 = var.product
  env                     = var.env
  tenant_id               = var.tenant_id
  object_id               = var.jenkins_AAD_objectId
  resource_group_name     = azurerm_resource_group.rg.name
  product_group_name      = "dcd_divorce"
  common_tags             = var.common_tags
  create_managed_identity = true
}

output "vaultName" {
  value = module.div-vault.key_vault_name
}

data "azurerm_key_vault" "div_key_vault" {
  name                = "div-${var.env}"
  resource_group_name = azurerm_resource_group.rg.name
}
