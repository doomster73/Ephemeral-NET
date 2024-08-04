variable "resource_group_name" {
  default = "ephemeral-env-rg"
}

variable "location" {
  default = "ukwest" # Change to another region if needed
}

variable "vnet_name" {
  default = "ephemeral-vnet"
}

variable "subnet_vm_name" {
  default = "vm-subnet"
}

variable "subnet_aks_name" {
  default = "aks-subnet"
}

variable "vm_name" {
  default = "ephem-spot-vm" # Ensure the computer name length is <= 15 characters
}

variable "vm_size" {
  default = "Standard_DS1_v2"
}

variable "aks_cluster_name" {
  default = "ephemeral-aks-cluster"
}

variable "app_config_name" {
  default = "ephemeral-app-config"
}
