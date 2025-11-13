output "vm_ids" {
  description = "VM ID list"
  value       = [for vm in azurerm_linux_virtual_machine.demo : vm.id]
}

# output "public_ip_addresses" {
#     description = "Public IP addresses of the virtual machines"
#     value       = [for ip in azurerm_public_ip.demo : ip.ip_address]
#     }

output "private_ip_addresses" {
    description = "Private IP addresses of the virtual machines"
    value       = [for nic in azurerm_network_interface.demo : nic.ip_configuration[0].private_ip_address]
    }

output "network_interface_ids" {
    description = "Network Interface IDs of the virtual machines"
    value       = [for nic in azurerm_network_interface.demo : nic.id]
    }

