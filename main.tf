provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

# Variables
variable "resource_group_name" {
  default = "ephemeral-env-rg"
}

variable "location" {
  default = "ukwest"
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

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "null_resource" "pause" {
  provisioner "local-exec" {
    command = "sleep 10"
  }
  depends_on = [azurerm_resource_group.rg]
}

# Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  tags = {
    environment = "ephemeral"
  }
}

# Subnet for VM
resource "azurerm_subnet" "subnet_vm" {
  name                 = var.subnet_vm_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Subnet for AKS
resource "azurerm_subnet" "subnet_aks" {
  name                 = var.subnet_aks_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Network Interface for VM
resource "azurerm_network_interface" "nic" {
  name                = "${var.vm_name}-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet_vm.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Spot Virtual Machine
resource "azurerm_windows_virtual_machine" "spot_vm" {
  name                  = var.vm_name
  resource_group_name   = azurerm_resource_group.rg.name
  location              = var.location
  size                  = var.vm_size
  admin_username        = "adminuser"
  admin_password        = "P@ssw0rd1234!"
  network_interface_ids = [azurerm_network_interface.nic.id]

  priority        = "Spot"
  eviction_policy = "Deallocate"
  max_bid_price   = -1 # Use -1 for the spot instance max bid price to be set at the on-demand price

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  computer_name = "ephemspotvm" # Explicitly set to ensure <= 15 characters
}

# AKS Cluster
resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = var.aks_cluster_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "ephemeralaks"

  # Default (Linux) Node Pool
  default_node_pool {
    name           = "linuxpool"
    node_count     = 1
    vm_size        = "Standard_DS2_v2"
    vnet_subnet_id = azurerm_subnet.subnet_aks.id
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
    outbound_type     = "loadBalancer"
    service_cidr      = "10.1.0.0/16" # Updated to avoid overlap with subnet CIDR
    dns_service_ip    = "10.1.0.10"
  }

  tags = {
    environment = "ephemeral"
  }
}

# Additional Spot Linux Node Pool
resource "azurerm_kubernetes_cluster_node_pool" "spot_linux_node_pool" {
  name                  = "splin1"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks_cluster.id
  vm_size               = "Standard_DS2_v2"
  node_count            = 1
  os_type               = "Linux"
  vnet_subnet_id        = azurerm_subnet.subnet_aks.id
  max_pods              = 30
  priority              = "Spot" # Use Spot VMs for this node pool

  tags = {
    environment = "ephemeral"
  }
}

# Additional Windows Node Pool
resource "azurerm_kubernetes_cluster_node_pool" "windows_node_pool" {
  name                  = "winpl1"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks_cluster.id
  vm_size               = "Standard_DS2_v2"
  node_count            = 1
  os_type               = "Windows"
  vnet_subnet_id        = azurerm_subnet.subnet_aks.id
  max_pods              = 30
  node_labels = {
    "os" = "windows"
  }
  priority = "Spot" # Use Spot VMs for this node pool

  tags = {
    environment = "ephemeral"
  }
}

# Output IDs
output "resource_group_id" {
  value = azurerm_resource_group.rg.id
}

output "vnet_id" {
  value = azurerm_virtual_network.vnet.id
}

output "subnet_vm_id" {
  value = azurerm_subnet.subnet_vm.id
}

output "subnet_aks_id" {
  value = azurerm_subnet.subnet_aks.id
}

output "vm_id" {
  value = azurerm_windows_virtual_machine.spot_vm.id
}

output "aks_cluster_id" {
  value = azurerm_kubernetes_cluster.aks_cluster.id
}

output "windows_node_pool_id" {
  value = azurerm_kubernetes_cluster_node_pool.windows_node_pool.id
}
