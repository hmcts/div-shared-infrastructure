variable "product" {
  default = "div"
}

variable "location" {
  default = "UK South"
}

// as of now, UK South is unavailable for Application Insights
variable "appinsights_location" {
  default     = "West Europe"
  description = "Location for Application Insights"
}

variable "env" {}

variable "application_type" {
  default     = "web"
  description = "Type of Application Insights (Web/Other)"
}

variable "tenant_id" {
  description = "(Required) The Azure Active Directory tenant ID that should be used for authenticating requests to the key vault. This is usually sourced from environemnt variables and not normally required to be specified."
}

variable "jenkins_AAD_objectId" {
  description = "(Required) The Azure AD object ID of a user, service principal or security group in the Azure Active Directory tenant for the vault. The object ID must be unique for the list of access policies."
}


// TAG SPECIFIC VARIABLES
variable "team_name" {
  description = "The name of your team"
  default     = "Divorce"
}

variable "team_contact" {
  description = "The name of your Slack channel people can use to contact your team about your infrastructure"
  default     = "#div-dev"
}

variable "destroy_me" {
  description = "Here be dragons! In the future if this is set to Yes then automation will delete this resource on a schedule. Please set to No unless you know what you are doing"
  default     = "No"
}

variable "common_tags" {
  type = map(string)
}

variable "product_group_object_id" {
  default = "3450807e-5248-4053-944f-9df59dda50b9"
}

variable "ilbIp" {
  default = ""
}

variable "subscription" {}

variable "family" {
  default     = "C"
  description = "The SKU family/pricing group to use. Valid values are `C` (for Basic/Standard SKU family) and `P` (for Premium). Use P for higher availability, but beware it costs a lot more."
}

variable "sku_name" {
  default     = "Basic"
  description = "The SKU of Redis to use. Possible values are `Basic`, `Standard` and `Premium`."
}

variable "capacity" {
  default     = "1"
  description = "The size of the Redis cache to deploy. Valid values are 1, 2, 3, 4, 5"
}