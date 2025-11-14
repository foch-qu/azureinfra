variable "resource_group_name" {
  description = "资源组名称"
  type        = string
}

variable "location" {
  description = "Azure 区域"
  type        = string
}

variable "vnet_name" {
  description = "虚拟网络名称"
  type        = string
}

variable "vnet_address_space" {
  description = "虚拟网络地址空间"
  type        = list(string)
}

variable "subnet_prefixes" {
  description = "子网地址前缀"
  type        = list(string)
}

variable "subnet_names" {
  description = "子网名称"
  type        = list(string)
}

variable "enable_nat_gateway" {
  description = "是否启用NAT网关"
  type        = bool
  default     = true
}


variable "subnets_for_nat" {
  description = "需要关联NAT网关的子网名称列表"
  type        = list(string)
  default     = []
}

variable "nat_idle_timeout" {
  description = "NAT网关空闲超时时间（分钟）"
  type        = number
  default     = 10
}

variable "nat_dns_label" {
  description = "NAT网关公共IP的DNS标签"
  type        = string
  default     = null
}

variable "ssh_source_address" {
  description = "允许SSH访问的源IP地址"
  type        = string
  default     = "*"
}