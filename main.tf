resource "azurerm_resource_group" "rg" {
  name = "${var.product}-${var.env}"
  location = "${var.location}"

  tags {
    "Deployment Environment" = "${var.env}"
    "Team Name" = "${var.team_name}"
    "Team Contact" = "${var.team_contact}"
    "Destroy Me" = "${var.destroy_me}"
  }
}