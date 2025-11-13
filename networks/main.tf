locals {
  # 创建子网名称到资源的映射
  subnet_map = { for i, subnet in azurerm_subnet.subnets : var.subnet_names[i] => subnet }
}
# 虚拟网络
resource "azurerm_virtual_network" "demo" {
  name                = var.vnet_name
  address_space       = var.vnet_address_space
  location            = var.location
  resource_group_name = var.resource_group_name
}

# 子网
resource "azurerm_subnet" "subnets" {
  count = length(var.subnet_names)

  name                 = var.subnet_names[count.index]
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.demo.name
  address_prefixes     = [var.subnet_prefixes[count.index]]
}

# 网络安全组
resource "azurerm_network_security_group" "demo" {
  name                = "nsg-demo"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTPS"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

    security_rule {
    name                       = "AllowAllOutbound"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}





# 子网与网络安全组关联
resource "azurerm_subnet_network_security_group_association" "subnet_nsg" {
  count = length(var.subnet_names)

  subnet_id                 = azurerm_subnet.subnets[count.index].id
  network_security_group_id = azurerm_network_security_group.demo.id
}


# 路由表
resource "azurerm_route_table" "demo" {
  name                = "route-default"
  location            = var.location
  resource_group_name = var.resource_group_name

  route {
    name           = "demo"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "Internet"
  }
}

resource "azurerm_subnet_route_table_association" "demo" {
  subnet_id      = azurerm_subnet.subnets[0].id  # 关联到第一个子网
  route_table_id = azurerm_route_table.demo.id
}

#nat gateway
# NAT网关提供出站互联网连接
resource "azurerm_nat_gateway" "demo" {
  name                = "nat-gateway-demo"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "Standard"
  idle_timeout_in_minutes = 10


}

resource "azurerm_public_ip" "nat" {
  name                = "pip-nat-gateway"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"


}

resource "azurerm_nat_gateway_public_ip_association" "demo" {
  nat_gateway_id       = azurerm_nat_gateway.demo.id
  public_ip_address_id = azurerm_public_ip.nat.id
}

# resource "azurerm_subnet_nat_gateway_association" "demo" {
#   subnet_id      = azurerm_subnet.subnets[index(var.subnet_names, "vm-subnet")].id
#   nat_gateway_id = azurerm_nat_gateway.demo.id
# }
resource "azurerm_subnet_nat_gateway_association" "demo" {
  subnet_id      = local.subnet_map[var.subnet_names].id
  nat_gateway_id = azurerm_nat_gateway.demo.id
}