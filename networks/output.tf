output "vnet_id" {
  description = "虚拟网络ID"
  value       = azurerm_virtual_network.demo.id
}

output "subnets_ids" {
  description = "子网ID映射"
  value       = { for i, subnet in azurerm_subnet.subnets : var.subnet_names[i] => subnet.id }
}

output "nsg_id" {
  description = "网络安全组ID"
  value       = azurerm_network_security_group.demo.id
}



# output "vm_subnet_id" {
#   description = "VM子网的ID"
#   value       = azurerm_subnet.subnets[index(var.subnet_names, var.vm_subnet_name)].id
# }