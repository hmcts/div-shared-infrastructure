locals {
  tags = "${merge(var.common_tags,
    map("Team Contact", "#div-dev")
    )}"
}

resource "azurerm_resource_group" "rg" {
  name = "${var.product}-${var.env}"
  location = "${var.location}"

  tags = "${local.tags}"
}
