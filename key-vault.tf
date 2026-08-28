data "azurerm_user_assigned_identity" "jenkins" {
  name                = "jenkins-${var.env}-mi"
  resource_group_name = "managed-identities-${var.env}-rg"
}

module "div-vault" {
  source = "git@github.com:hmcts/cnp-module-key-vault?ref=DTSPO-31965/remove-jenkins-ptl-access"
  name                    = "${var.product}-${var.env}"
  product                 = var.product
  env                     = var.env
  tenant_id               = var.tenant_id
  object_id               = var.jenkins_AAD_objectId
  jenkins_object_id       = data.azurerm_user_assigned_identity.jenkins.principal_id
  resource_group_name     = azurerm_resource_group.rg.name
  product_group_name      = "dcd_divorce"
  common_tags             = var.common_tags
  create_managed_identity = true
  grant_preview_jenkins_access = var.env == "aat"
}

output "vaultName" {
  value = module.div-vault.key_vault_name
}

data "azurerm_key_vault" "div_key_vault" {
  name                = "div-${var.env}"
  resource_group_name = azurerm_resource_group.rg.name
}
