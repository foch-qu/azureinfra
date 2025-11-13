# public IP
# resource "azurerm_public_ip" "demo" {
#     count               = var.vm_count
#     name                = "public-ip-vm-${count.index}"
#     location            = var.location
#     resource_group_name = var.resource_group_name
#     allocation_method   = "Dynamic"
# }

# network interface
resource "azurerm_network_interface" "demo" {
    count               = var.vm_count
    name                = "nic-vm-${count.index}"
    location            = var.location
    resource_group_name = var.resource_group_name

    ip_configuration {
        name                          = "ipconfig-vm-${count.index}"
        subnet_id                     = var.subnets_id
        private_ip_address_allocation = "Dynamic"
        # public_ip_address_id          = azurerm_public_ip.demo[count.index].id
    }
}

# virtual machine
resource "azurerm_linux_virtual_machine" "demo" {
    count               = var.vm_count
    name                = "vm-${count.index}"
    location            = var.location
    resource_group_name = var.resource_group_name
    size                = var.vm_size
    admin_username      = var.admin_username
    admin_password      = var.admin_password
    disable_password_authentication = false 
    network_interface_ids = [
        azurerm_network_interface.demo[count.index].id,
    ]

    os_disk {
        caching              = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }

    source_image_reference {
        publisher = "Canonical"
        offer     = "0001-com-ubuntu-server-jammy"
        sku       = "22_04-lts"
        version   = "latest"
    }
}