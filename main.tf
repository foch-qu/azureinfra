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


  subscription_id = "7
  client_id       = "e
  client_   = 
  tenant_id       = "e
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





