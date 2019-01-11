locals {
  ai_tags = "${merge(
        var.common_tags,
        map("Deployment Environment", var.env),
        map("Team Name", var.team_name),
        map("Team Contact", var.team_contact),
        map("Destroy Me", var.destroy_me)
    )}"
}

resource "azurerm_application_insights" "appinsights" {
  name                = "${var.product}-${var.env}"
  location            = "${var.appinsights_location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  application_type    = "${var.application_type}"
  tags                = "${local.ai_tags}"
}

output "appInsightsInstrumentationKey" {
  value = "${azurerm_application_insights.appinsights.instrumentation_key}"
}
