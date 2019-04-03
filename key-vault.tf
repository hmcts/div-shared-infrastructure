module "div-vault" {
  source                  = "git@github.com:hmcts/moj-module-key-vault?ref=master"
  name                    = "${var.product}-${var.env}"
  product                 = "${var.product}"
  env                     = "${var.env}"
  tenant_id               = "${var.tenant_id}"
  object_id               = "${var.jenkins_AAD_objectId}"
  resource_group_name     = "${azurerm_resource_group.rg.name}"
  product_group_object_id = "3450807e-5248-4053-944f-9df59dda50b9"
  common_tags             = "${var.common_tags}"
}

output "vaultName" {
  value = "${module.div-vault.key_vault_name}"
}

data "azurerm_key_vault" "div_key_vault" {
  name                = "div-${var.env}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
}
