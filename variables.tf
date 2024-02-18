variable "azurerm_resource_group" {
  type = string
}

variable "location" {
  type = string
}

variable "azurerm_virtual_network" {
  type = string
}

variable "address_space" {
  type = list 
}

variable "subnet1" {
  type = string
}

variable "address_prefixes1" {
  type = list 
}

variable "subnet2" {
  type = string
}

variable "address_prefixes2" {
  type = list 
}

variable "nsg" {
  type = string
}

variable "Dev-nic" {
  type = string
}

variable "Dev-vm" {
  type = string
}