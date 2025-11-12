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