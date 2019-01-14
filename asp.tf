locals {
  ase_name = "core-compute-${var.env}"
}

module "appServicePlan-1" {
  source              = "git@github.com:hmcts/cnp-module-app-service-plan?ref=master"
  location            = "${var.location}"
  env                 = "${var.env}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  asp_capacity        = "${var.asp_capacity}"
  asp_name            = "${var.product}-1"
  ase_name            = "${local.ase_name}"
  tag_list            = "${var.common_tags}"
}

module "appServicePlan-2" {
  source              = "git@github.com:hmcts/cnp-module-app-service-plan?ref=master"
  location            = "${var.location}"
  env                 = "${var.env}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  asp_capacity        = "${var.asp_capacity}"
  asp_name            = "${var.product}-2"
  ase_name            = "${local.ase_name}"
  tag_list            = "${var.common_tags}"
}
