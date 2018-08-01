module "div-vault" {
  source = "git@github.com:contino/moj-module-key-vault?ref=master"
  name = "${var.product}-${var.env}"
  product = "${var.product}"
  env = "${var.env}"
  tenant_id = "${var.tenant_id}"
  object_id = "${var.jenkins_AAD_objectId}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  product_group_object_id = "a04a7237-ebfb-420a-9927-5f0b829bf1f5"
}

output "vaultName" {
  value = "${module.div-vault.key_vault_name}"
}
