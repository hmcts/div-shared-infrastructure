module "div-bad-requests-alert" {
  source = "git@github.com:hmcts/cnp-module-metric-alert"
  location = "${var.location}"

  app_insights_name = "div-${var.env}"

  alert_name = "div-bad-requests"
  alert_desc = "Found HTTP requests with 400 or 422 error response codes (bad request) in div-${var.env}."
  app_insights_query = "requests | where resultCode in ('400', '422')"
  custom_email_subject = "Alert: bad requests in div-${var.env}"
  frequency_in_minutes = 5
  time_window_in_minutes = 5
  severity_level = "2"
  action_group_name = "div-support"
  trigger_threshold_operator = "GreaterThan"
  trigger_threshold = 0
  resourcegroup_name = "${azurerm_resource_group.rg.name}"
  enabled = "${var.env == "prod"}"
}

module "div-server-errors-alert" {
  source = "git@github.com:hmcts/cnp-module-metric-alert"
  location = "${var.location}"

  app_insights_name = "div-${var.env}"

  alert_name = "div-server-errors"
  alert_desc = "Found HTTP requests with 500 error response code (bad request) in div-${var.env}."
  app_insights_query = "requests | where resultCode startswith '5' | where name !contains '/health' | where datetime_diff('hour', timestamp, startofday(timestamp)) !between (1 .. 5) or url !contains '-aat'"
  custom_email_subject = "Alert: server errors in div-${var.env}"
  frequency_in_minutes = 5
  time_window_in_minutes = 5
  severity_level = "2"
  action_group_name = "div-support"
  trigger_threshold_operator = "GreaterThan"
  trigger_threshold = 20
  resourcegroup_name = "${azurerm_resource_group.rg.name}"
}

module "div-fe-performance-alert" {
  source = "git@github.com:hmcts/cnp-module-metric-alert"
  location = "${var.location}"

  app_insights_name = "div-${var.env}"

  alert_name = "div-fe-performance-alert"
  alert_desc = "Web pages took longer than 10 seconds to load in div-${var.env}."
  app_insights_query = "requests | where url !contains '/health' | where success == 'True' | where duration > 10000 | where cloud_RoleName in ('div-pfe', 'div-rfe', 'div-dn')"
  custom_email_subject = "Alert: performance errors in div-${var.env}"
  frequency_in_minutes = 5
  time_window_in_minutes = 5
  severity_level = "2"
  action_group_name = "div-support"
  trigger_threshold_operator = "GreaterThan"
  trigger_threshold = 5
  resourcegroup_name = "${azurerm_resource_group.rg.name}"
}

module "div-bulkcase-errors-alert" {
  source = "git@github.com:hmcts/cnp-module-metric-alert"
  location = "${var.location}"

  app_insights_name = "div-${var.env}"

  alert_name = "div-bulkcase-errors"
  alert_desc = "Bulk case update failed on in div-${var.env}."
  app_insights_query = "traces | where message has 'Bulk case update failed' |  where severityLevel == 3"
  custom_email_subject = "Alert: Bulk case update errors in div-${var.env}"
  frequency_in_minutes = 5
  time_window_in_minutes = 5
  severity_level = "2"
  action_group_name = "div-support"
  trigger_threshold_operator = "GreaterThan"
  trigger_threshold = 0
  resourcegroup_name = "${azurerm_resource_group.rg.name}"
}

module "div-data-extraction-alert" {
  source = "git@github.com:hmcts/cnp-module-metric-alert"
  location = "${var.location}"

  app_insights_name = "div-${var.env}"

  alert_name = "div-data-extraction-alert"
  alert_desc = "Logs indicate that daily e-mails with data extraction were not sent in div-${var.env}."
  app_insights_query = "traces | where message startswith 'Sent extracted data to' and tostring(customDimensions['LoggerName']) has 'dataextraction'"
  custom_email_subject = "Alert: Data extraction does not seem to be working in div-${var.env}"
  frequency_in_minutes = 300
  time_window_in_minutes = 1440
  severity_level = "2"
  action_group_name = "div-support"
  trigger_threshold_operator = "LessThan"
  trigger_threshold = 3
  resourcegroup_name = "${azurerm_resource_group.rg.name}"
  enabled = "${var.env == "prod" || var.env == "aat"}"
}

module "div-bulk-print-config-errors-alert" {
  source = "git@github.com:hmcts/cnp-module-metric-alert"
  location = "${var.location}"

  app_insights_name = "div-${var.env}"

  alert_name = "div-bulk-print-config-errors-alert"
  alert_desc = "Logs indicate that the bulk print task has been misconfigured in div-${var.env}."
  app_insights_query = "traces | where message startswith 'Bulk print for case ' and message has 'is misconfigured.'"
  custom_email_subject = "Alert: Bulk print task seems to be misconfigured in div-${var.env}"
  frequency_in_minutes = 720
  time_window_in_minutes = 1440
  severity_level = "2"
  action_group_name = "div-support"
  trigger_threshold_operator = "GreaterThan"
  trigger_threshold = 0
  resourcegroup_name = "${azurerm_resource_group.rg.name}"
  enabled = "${var.env == "prod" || var.env == "aat"}"
}

module "div-aos-overdue-alert" {
  source = "git@github.com:hmcts/cnp-module-metric-alert"
  location = "${var.location}"

  app_insights_name = "div-${var.env}"

  alert_name = "div-aos-overdue-alert"
  alert_desc = "Logs indicate that daily job responsible for moving eligible cases to 'AOS Overdue' state did not run in div-${var.env}."
  app_insights_query = "traces | where message == 'Running AosOverdueJob job'"
  custom_email_subject = "Alert: AOS Overdue job does not seem to be working in div-${var.env}"
  frequency_in_minutes = 300
  time_window_in_minutes = 1440
  severity_level = "2"
  action_group_name = "div-support"
  trigger_threshold_operator = "LessThan"
  trigger_threshold = 1
  resourcegroup_name = "${azurerm_resource_group.rg.name}"
  enabled = "${var.env == "prod" || var.env == "aat"}"
}