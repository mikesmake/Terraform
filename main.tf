provider "azurerm" {
  subscription_id = "efe79a37-ff86-4032-983f-db866c14fbc3"
  client_id       = "44438841-bb71-400d-9a8a-096f3048dd18"
  client_secret   = "Wh4QVg8Co9xSHDEQPpFuq9mkKN3_god3sx"
  tenant_id       = "51de095e-2389-4a95-8abd-985d1e93bf79"
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "${var.prefix}-resources"
  location = "${var.location}"
}

resource "azurerm_sql_server" "example" {
  name                         = "${var.prefix}-sqlsvr"
  resource_group_name          = "${azurerm_resource_group.example.name}"
  location                     = "${azurerm_resource_group.example.location}"
  version                      = "12.0"
  administrator_login          = "4dm1n157r470r"
  administrator_login_password = "4-v3ry-53cr37-p455w0rd"
}

resource "azurerm_sql_database" "example" {
  name                             = "${var.prefix}-db"
  resource_group_name              = "${azurerm_resource_group.example.name}"
  location                         = "${azurerm_resource_group.example.location}"
  server_name                      = "${azurerm_sql_server.example.name}"
  edition                          = "Basic"
  collation                        = "SQL_Latin1_General_CP1_CI_AS"
  create_mode                      = "Default"
  requested_service_objective_name = "Basic"
}

# Enables the "Allow Access to Azure services" box as described in the API docs
# https://docs.microsoft.com/en-us/rest/api/sql/firewallrules/createorupdate
resource "azurerm_sql_firewall_rule" "example" {
  name                = "allow-azure-services"
  resource_group_name = "${azurerm_resource_group.example.name}"
  server_name         = "${azurerm_sql_server.example.name}"
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}