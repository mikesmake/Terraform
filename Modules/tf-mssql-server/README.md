#mssql-server
##Purpose
This module is to manage an Azure SQL Server and single DB

##Usage
Use this module to manage an Azure SQL Server as part of a larger composition.
An audit can be added by using the _enable_audit_ boolean input.

###Examples

####SQL Server with DB

```
module "sql-server-module" {
  source = "./tf-mssql-server"

  resource_group_name                  = azurerm_resource_group.rg.name
  sql_server_name                      = "testsqlserverformynewthing"
  key_vault_name                       = "kv-Service-dev"
  enable_audit                         = false
  allow_azure_access_to_sql            = true
  sql_database_name                    = "testDB01"
  audit_storage_account                = "sabicepdev01"
  audit_storage_account_resource_group = "rg-test-nee"

  depends_on = [azurerm_resource_group.rg]
}
```

##External Dependencies

1. An Azure Resource Group
2. An Azure Key Vault under which to store the admin credentials
