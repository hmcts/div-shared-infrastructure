module "div-${var.env}-alert" {
  source = "git@github.com:hmcts/cnp-module-metric-alert"
  location = "${var.location}"

  app_insights_name = "div-${var.env}"

  alert_name = "Bad requests (400 error code) in div-${var.env}"
  alert_desc = "Found HTTP requests with 400 error response code (bad request) in div-${var.env}."
  app_insights_query = "requests | where resultCode == \"400\""
  custom_email_subject = "Alert: bad requests in div-${var.env}"
  frequency_in_minutes = 5
  time_window_in_minutes = 5
  severity_level = "2"
  action_group_name = "Divroce Support"
  trigger_threshold_operator = "GreaterThan"
  trigger_threshold = 5
  resourcegroup_name = "${azurerm_resource_group.rg.name}"
}
