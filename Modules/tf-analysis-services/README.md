# Analysis Services
##Purpose 
This Terraform module is to manage an Azure Analysis Services Server. 

##Usage
Use this module to manage an instance of Azure Analysis Services Server

##Examples
```
module "azurerm_analysis_services_server" {
  source = "./tf-analysis-services"

  analysis_server_name  = "${var.analysis_server_name}${lower(terraform.workspace)}"
  resource_group_name   = azurerm_resource_group.rg.name
  analysis_server_sku   = var.analysis_server_sku
  analysis_server_admin = var.analysis_server_admin
  tags                  = local.common_tags

  depends_on = [
    azurerm_resource_group.rg, module.sql-server-module
  ]
}
``` 
##variables
```
variable "analysis_server_name" {
  type        = string
  description = "The analysis services name"
}

variable "analysis_server_sku" {
  type        = string
  description = "The analysis services sku"
}

variable "analysis_server_admin" {
  type        = string
  description = "The analysis services admin username"
}
```

##tfvars
```
analysis_server_name  = "asdatawarehouseexp"
analysis_server_sku   = "B1"
```

##External Dependencies
1.  An Azure resource Group
2.  An Azure SQL Server