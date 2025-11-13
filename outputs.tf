output "resource_group_name" {
  description = "资源组名称"
  value       = azurerm_resource_group.demo.name
}

output "vnet_id" {
  description = "虚拟网络ID"
  value       = module.networks.vnet_id
}

# output "vm_public_ips" {
#   description = "虚拟机公网IP地址"
#   value       = module.vm.vm_public_ips
# }

# output "vm_private_ips" {
#   description = "虚拟机内网IP地址"
#   value       = module.vm.vm_private_ips
# }

