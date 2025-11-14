terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.50.0"  # 确保版本支持 routing_preference
    }
  }
}

provider "azurerm" {
  features {}



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

  # NAT gateway settings
  enable_nat_gateway = var.enable_nat_gateway
  subnets_for_nat    = var.subnets_for_nat
  nat_idle_timeout   = var.nat_idle_timeout
  nat_dns_label      = var.nat_dns_label
 # ssh_source_address = var.ssh_source_address
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
module "rds" {
  source = "./rds"

  resource_group_name = azurerm_resource_group.demo.name
  location = azurerm_resource_group.demo.location
            
  subnet_id = module.networks.subnets_ids[var.subnet_names[1]]
  admin_username = var.rds_username
  admin_password = var.rds_password
}





