module "div-vault" {
  source = "git@github.com:hmcts/moj-module-key-vault?ref=master"
  name = "${var.product}-${var.env}"
  product = "${var.product}"
  env = "${var.env}"
  tenant_id = "${var.tenant_id}"
  object_id = "${var.jenkins_AAD_objectId}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  product_group_object_id = "1c4f0704-a29e-403d-b719-b90c34ef14c9"
}

output "vaultName" {
  value = "${module.div-vault.key_vault_name}"
}
