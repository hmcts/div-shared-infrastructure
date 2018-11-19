locals {
  tags = "${merge(var.common_tags, var.local_tags)}"
}

resource "azurerm_resource_group" "rg" {
  name = "${var.product}-${var.env}"
  location = "${var.location}"

  tags = "${local.tags}"
}
