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
output "nat_gateway_info" {
  description = "NAT网关信息"
  value = var.enable_nat_gateway ? {
    nat_gateway_id     = azurerm_nat_gateway.demo[0].id
    nat_gateway_name   = azurerm_nat_gateway.demo[0].name
    public_ip_address  = azurerm_public_ip.nat[0].ip_address
    public_ip_id       = azurerm_public_ip.nat[0].id
    associated_subnets = var.subnets_for_nat
  } : null
}

output "subnet_associations" {
  description = "子网关联状态"
  value = {
    all_subnets       = var.subnet_names
    nat_associated    = var.enable_nat_gateway ? var.subnets_for_nat : []
    route_table       = azurerm_route_table.internet[*].id
  }
}

# 为每个可能的子网创建明确输出
output "vm_subnet_id" {
  description = "VM子网的ID"
  value       = try(azurerm_subnet.subnets[index(var.subnet_names, "vm-subnet")].id, null)
}

output "app_subnet_id" {
  description = "应用子网的ID"
  value       = try(azurerm_subnet.subnets[index(var.subnet_names, "app-subnet")].id, null)
}


# output "vm_subnet_id" {
#   description = "VM子网的ID"
#   value       = azurerm_subnet.subnets[index(var.subnet_names, var.vm_subnet_name)].id
# }