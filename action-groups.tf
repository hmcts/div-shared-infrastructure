// Divorce Alerts Action Groups

data "azurerm_key_vault_secret" "divorce_support_email_secret" {
  name      = "divorce-support-email"
  vault_uri = "${data.azurerm_key_vault.div_key_vault.vault_uri}"
}

module "divorce-action-group" {
  source   = "git@github.com:hmcts/cnp-module-action-group"
  location = "global"
  env      = "${var.env}"

  resourcegroup_name     = "${azurerm_resource_group.rg.name}"
  action_group_name      = "div-support"
  short_name             = "div-support"
  email_receiver_name    = "Divorce Support Mailing List"
  email_receiver_address = "${data.azurerm_key_vault_secret.divorce_support_email_secret.value}"
}