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

# resource "azurerm_subnet_route_table_association" "demo" {
#   subnet_id      = azurerm_subnet.subnets[0].id  # 关联到第一个子网
#   route_table_id = azurerm_route_table.demo.id
# }

#nat gateway
# NAT网关提供出站互联网连接
# resource "azurerm_nat_gateway" "demo" {
#   name                = "nat-gateway-demo"
#   location            = var.location
#   resource_group_name = var.resource_group_name
#   sku_name            = "Standard"
#   idle_timeout_in_minutes = 10


# }
# NAT网关
resource "azurerm_nat_gateway" "demo" {
  count = var.enable_nat_gateway ? 1 : 0
  #如果 var.enable_nat_gateway 为 true，则 count = 1（创建1个NAT网关）

  #如果 var.enable_nat_gateway 为 false，则 count = 0（不创建NAT网关）

  name                = "nat-gateway-${var.vnet_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "Standard"
  
  # 空闲超时设置（分钟）
  idle_timeout_in_minutes = var.nat_idle_timeout
  
  # 可选：区域冗余
  # zones = ["1", "2", "3"]

  tags = {
    environment = "demo"
    purpose     = "outbound-internet"
  }
}



# resource "azurerm_public_ip" "nat" {
#   name                = "pip-nat-gateway"
#   location            = var.location
#   resource_group_name = var.resource_group_name
#   allocation_method   = "Static"
#   sku                 = "Standard"


# }

# 标准SKU公共IP地址，路由首选项为Microsoft网络
resource "azurerm_public_ip" "nat" {
  count = var.enable_nat_gateway ? 1 : 0

  name                = "pub-ip-nat-gateway"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  
  # 路由首选项设置为Microsoft网络
  #routing_preference = "Microsoft"
  
  # 可选：IP版本设置
  ip_version = "IPv4"
  
  # 可选：DNS标签
  domain_name_label = var.nat_dns_label

  tags = {
    environment = "demo"
    purpose     = "nat-gateway"
  }

  lifecycle {
    create_before_destroy = true
  }
}



# resource "azurerm_nat_gateway_public_ip_association" "demo" {
#   nat_gateway_id       = azurerm_nat_gateway.demo.id
#   public_ip_address_id = azurerm_public_ip.nat.id
# }
# 将公共IP关联到NAT网关
resource "azurerm_nat_gateway_public_ip_association" "demo" {
  count = var.enable_nat_gateway ? 1 : 0

  nat_gateway_id       = azurerm_nat_gateway.demo[0].id
  public_ip_address_id = azurerm_public_ip.nat[0].id

  depends_on = [
    azurerm_public_ip.nat,
    azurerm_nat_gateway.demo
  ]
}


# 创建子网名称到ID的映射
locals {
  subnet_map = { for i, name in var.subnet_names : name => azurerm_subnet.subnets[i] }
}

# 将子网关联到NAT网关
resource "azurerm_subnet_nat_gateway_association" "demo" {
  for_each = var.enable_nat_gateway ? { 
    for name in var.subnets_for_nat : name => local.subnet_map[name] 
    if contains(var.subnet_names, name)
  } : {}

  subnet_id      = each.value.id
  nat_gateway_id = azurerm_nat_gateway.demo[0].id

  depends_on = [
    azurerm_nat_gateway.demo
  ]
}


# 路由表 - 确保出站流量正确路由
resource "azurerm_route_table" "internet" {
  count = var.enable_nat_gateway ? 1 : 0

  name                = "route-internet-${var.vnet_name}"
  location            = var.location
  resource_group_name = var.resource_group_name

  route {
    name           = "demo-internet"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "Internet"
  }

  tags = {
    environment = "demo"
    purpose     = "internet-routing"
  }
}

# 关联路由表到子网
resource "azurerm_subnet_route_table_association" "demo" {
  for_each = var.enable_nat_gateway ? { 
    for name in var.subnets_for_nat : name => local.subnet_map[name] 
    if contains(var.subnet_names, name)
  } : {}

  subnet_id      = each.value.id
  route_table_id = azurerm_route_table.internet[0].id

  depends_on = [
    azurerm_route_table.internet
  ]
}


# resource "azurerm_subnet_nat_gateway_association" "demo" {
#   subnet_id      = azurerm_subnet.subnets[index(var.subnet_names, "vm-subnet")].id
#   nat_gateway_id = azurerm_nat_gateway.demo.id
# }
# resource "azurerm_subnet_nat_gateway_association" "demo" {
#   subnet_id      = local.subnet_map[var.subnet_names].id
#   nat_gateway_id = azurerm_nat_gateway.demo.id
# }