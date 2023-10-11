// Divorce Alerts Action Groups

data "azurerm_key_vault_secret" "divorce_support_email2_secret" {
  name         = "divorce-support-email2"
  key_vault_id = module.div-vault.key_vault_id
}

data "azurerm_key_vault_secret" "divorce_support_email_secret" {
  name         = "divorce-support-email"
  key_vault_id = module.div-vault.key_vault_id
}

module "divorce-action-group" {
  source   = "git@github.com:hmcts/cnp-module-action-group"
  location = "global"
  env      = var.env

  resourcegroup_name     = azurerm_resource_group.rg.name
  action_group_name      = "div-support"
  short_name             = "div-support"
  email_receiver_name    = "Divorce Support Mailing List"
  email_receiver_address = data.azurerm_key_vault_secret.divorce_support_email_secret.value
}

module "divorce-action-group2" {
  source   = "git@github.com:hmcts/cnp-module-action-group"
  location = "global"
  env      = var.env

  resourcegroup_name     = azurerm_resource_group.rg.name
  action_group_name      = "div-support2"
  short_name             = "div-support2"
  email_receiver_name    = "Divorce Support Mailing List2"
  email_receiver_address = data.azurerm_key_vault_secret.divorce_support_email_secret.value
}
