terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
}

provider "azurerm" {
  features {}


  subscription_id = "7a04a24c-df7a-4830-9f44-548548293c9c"
  client_id       = "ea7e9870-c952-4dbc-b5d2-2ce0f72a19db"
  client_secret   = "zN08Q~.hn01HosBVDSclO1QtvLpHK~nQuIW1mdcn"
  tenant_id       = "e71e6328-70e2-417b-86c6-8e72cde210af"
}

# resource group
resource "azurerm_resource_group" "demo" {
  name     = var.resource_group_name
  location = var.location

}

# network module
module "networks" {
  source = "./networks"

  resource_group_name = azurerm_resource_group.demo.name
  location            = azurerm_resource_group.demo.location
  vnet_name = var.vnet_name
  vnet_address_space = var.vnet_address_space
  subnet_names       = var.subnet_names
  subnet_prefixes    = var.subnet_prefixes



}

module "vm" {
  source = "./vm"

  resource_group_name = azurerm_resource_group.demo.name
  location = azurerm_resource_group.demo.location
            
  subnets_id = module.networks.subnets_ids[var.subnet_names[0]]
  vm_count = var.vm_count
  vm_size = var.vm_size
  admin_username = var.admin_username
  admin_password = var.admin_password


}





