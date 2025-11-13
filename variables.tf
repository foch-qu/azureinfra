variable resource_group_name {
  type        = string
  default     = "foch-resource-rg"
  description = "Resource Group Name"
}
 variable  location {
   type        = string
   default     = "Japan East"
   description = "Rescource Area"
 }
 
 variable vnet_name {
    type        = string
    default     = "demo-vnet"
    description = "Virtual Network Name"
 }

 variable vnet_address_space {
    type = list(string)
    default     = ["10.0.0.0/16"]
    description = "Virtual Network Address Space"
 }

variable "subnet_prefixes" {
  description = "list of subnet address prefixes"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "subnet_names" {
  description = "subnet names"
  type        = list(string)
  default     = ["vm-subnet-01", "vm-subnet-02"]
}

variable "vm_count" {
  description = "vm count"
  type        = number
  default     = 1
}

variable "vm_size" {
  description = "vm type"
  type        = string
  default     = "Standard_B1s"
}

variable "admin_username" {
  description = "admin username"
  type        = string
  default     = "azureuser"
}

variable "admin_password" {
  description = "passwd"
  type        = string
  #sensitive   = true
  default = "q!1234567890"
}

variable "vm_subnet_name" {
  description = "虚拟机使用的子网名称"
  type        = string
  default     = "vm-subnet"
}