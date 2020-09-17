provider "azurerm" {
  features {}
}

locals {
  tags = "${merge(
    var.common_tags,
    map("Deployment Environment", var.env),
    map("Team Name", var.team_name),
    map("Destroy Me", var.destroy_me)
  )}"
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.product}-${var.env}"
  location = var.location

  tags = local.tags
}
