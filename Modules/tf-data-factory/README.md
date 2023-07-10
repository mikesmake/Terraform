# data-factory
##Purpose 
This Terraform module is to build and manage an Azure Data Factory.

##Usage
Use this module to manage an Azure Data Factory (v2).

##Examples
```
module "data-factory-module" {
  source = "./tf-data-factory"

  data_factory_name   = "${var.data_factory_name}-${lower(terraform.workspace)}"
  resource_group_name = azurerm_resource_group.rg.name
  tags                = local.common_tags

  depends_on = [
    azurerm_resource_group.rg, module.storage
  ]
}
```
##variables
```
variable "data_factory_name" {
  type        = string
  description = "The data factory name"
}
```
##tfvars
```
data_factory_name = "df-datawarehouseexp"
```
##External Dependencies
1.  An Azure Resource Group
2.  An Azure Storage Account