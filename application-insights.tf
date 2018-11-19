resource "azurerm_application_insights" "appinsights" {
  name                = "${var.product}-${var.env}"
  location            = "${var.appinsights_location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  application_type    = "${var.application_type}"
  tags                = "${merge(var.common_tags, var.local_tags)}"
}

output "appInsightsInstrumentationKey" {
  value = "${azurerm_application_insights.appinsights.instrumentation_key}"
}
