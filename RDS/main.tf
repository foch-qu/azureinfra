resource "azurerm_mysql_flexible_server" "demo" {
  name                = "mysql-flexible-server-demo"
  location            = var.location
  resource_group_name = var.resource_group_name
  administrator_login = var.admin_username
  administrator_password = var.admin_password
  sku_name            = "Standard_B1ms"
  version             = "5.7"
  storage_mb         = 32768
  backup_retention_days = 7
  geo_redundant_backup = "Disabled"
  delegated_subnet_id  = var.subnet_id

  high_availability {
    mode = "Disabled"
  }

  tags = {
    environment = "demo"
    purpose     = "mysql-flexible-server"
  }
}