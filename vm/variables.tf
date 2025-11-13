variable "resource_group_name" {
  description = "RG name"
  type        = string
}

variable "vm_count" {
    description = "Number of VM"
    type        = number
    
    }   

variable "location" {
    description = "Location"
    type        = string
}

variable "vm_size" {
    description = "VM Size"
    type        = string
}

variable "subnets_id" {
    description = "Subnet ID"
    type        = string
}
variable "admin_username" {
    description = "Admin Username"
    type        = string
}

variable "admin_password" {
    description = "Admin Password"
    type        = string
}