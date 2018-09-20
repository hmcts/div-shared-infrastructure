resource "azurerm_resource_group" "shared_resource_group" {
  name = "${var.product}-shared-infrastructure-${var.env}"
  location = "${var.location}"
  tags {
        "Deployment Environment" = "${var.env}"
        "Team Name" = "${var.team_name}"
        "Team Contact" = "${var.team_contact}"
        "Destroy Me" = "${var.destroy_me}"
  }
}