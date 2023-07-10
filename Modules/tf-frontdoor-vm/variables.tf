#############################################################################################
# data providers
#############################################################################################

variable "resource_group_name" {
  type        = string
  description = "Name of an externally managed resource group"
}

variable "resource_group_location" {
  type        = string
  description = "An existing resource group name"
}


variable "log_analytics_workpace_rg" {
  type        = string
  description = "The resource group that hosts the LAW"
}

variable "log_analytics_workpace_name" {
  type        = string
  description = "The LAW name"
}

variable "dns_zone_resource_group" {
  type        = string
  description = "reource group of DNS zone"
}

variable "dns_zone_name" {
  type        = string
  description = "Name of DNS zone to create front door records"
}


variable "dental_dns_zone_name" {
  type        = string
  description = "Name of dental DNS zone to create front door records"
  default     = "dental.mps-dev.org"
}




#############################################################################################
# resource providers
#############################################################################################


########### Profile

variable "frontdoor_name" {
  type        = string
  description = "frontdoor_name"
}

########### Origin

variable "origin_name" {
  type        = string
  description = "origin_name"
}

variable "nlb_ip" {
  type        = string
  description = "frontend IP of the NLB"
}

variable "private_link_target_id" {
  type        = string
  description = "private_link_target_id"
}
variable "endpoint_name" {
  type        = string
  description = "endpoint_name"
}

variable "host_name" {
  type = string
}

variable "host_header" {
  type = string
}

variable "dental_host_header" {
  type    = string
  default = ""
}


variable "environment_short_name" {
  type        = string
  description = "Environemnt suffix i.e. n01"
}

variable "service" {
  type        = string
  description = "service name"
}

variable "tags" {
  type        = map(any)
  description = "Tags to identify web app"
}

variable "nlb_frontend_ip" {
  type        = list(any)
  description = "frontend ip of the load balancer"
}


variable "create_dental_site" {
  type        = bool
  description = "creates the domain and routes in front door for .dental subdomain"
  default     = false
}


#############################################################################################
# WAF logging 
#############################################################################################


variable "fd_diag_logs" {
  description = "Frontdoor Monitoring Category details for Azure Diagnostic setting"
  default     = ["FrontdoorAccessLog", "FrontdoorWebApplicationFirewallLog"]
}
