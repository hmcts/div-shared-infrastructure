module "div-bad-requests-alert" {
  source = "git@github.com:hmcts/cnp-module-metric-alert"
  location = "${var.location}"

  app_insights_name = "div-${var.env}"

  alert_name = "div-bad-requests"
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

module "div-server-errors-alert" {
  source = "git@github.com:hmcts/cnp-module-metric-alert"
  location = "${var.location}"

  app_insights_name = "div-${var.env}"

  alert_name = "div-server-errors"
  alert_desc = "Found HTTP requests with 400 error response code (bad request) in div-${var.env}."
  app_insights_query = "requests | where resultCode startswith \"5\"  | where name !contains \"/health\""
  custom_email_subject = "Alert: server errors in div-${var.env}"
  frequency_in_minutes = 5
  time_window_in_minutes = 5
  severity_level = "2"
  action_group_name = "Divroce Support"
  trigger_threshold_operator = "GreaterThan"
  trigger_threshold = 5
  resourcegroup_name = "${azurerm_resource_group.rg.name}"
}

module "div-fe-performance-alert" {
  source = "git@github.com:hmcts/cnp-module-metric-alert"
  location = "${var.location}"

  app_insights_name = "div-${var.env}"

  alert_name = "div-fe-performance-alert"
  alert_desc = "Web pages took longer than 10 seconds to load in div-${var.env}."
  app_insights_query = "requests | where url !contains \"/health\" | where success == \"True\" | where duration > 10000 | where cloud_RoleName in (\"div-pfe\", \"div-rfe\", \"div-dn\")"
  custom_email_subject = "Alert: performance errors in div-${var.env}"
  frequency_in_minutes = 5
  time_window_in_minutes = 5
  severity_level = "2"
  action_group_name = "Divroce Support"
  trigger_threshold_operator = "GreaterThan"
  trigger_threshold = 5
  resourcegroup_name = "${azurerm_resource_group.rg.name}"
}
