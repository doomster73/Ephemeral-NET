# Azure App Configuration
resource "azurerm_app_configuration" "app_config" {
  name                = var.app_config_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  sku = "standard" # Adjust as needed

  tags = {
    environment = "ephemeral"
  }
}

# Store outputs in Azure App Configuration
resource "azurerm_app_configuration_key" "resource_group_id" {
  configuration_store_id = azurerm_app_configuration.app_config.id
  key                    = "resource_group_id"
  value                  = azurerm_resource_group.rg.id
  label                  = "v1" # Optional: Use labels to version or segment your keys
}

resource "azurerm_app_configuration_key" "vnet_id" {
  configuration_store_id = azurerm_app_configuration.app_config.id
  key                    = "vnet_id"
  value                  = azurerm_virtual_network.vnet.id
  label                  = "v1"
}

resource "azurerm_app_configuration_key" "subnet_vm_id" {
  configuration_store_id = azurerm_app_configuration.app_config.id
  key                    = "subnet_vm_id"
  value                  = azurerm_subnet.subnet_vm.id
  label                  = "v1"
}

resource "azurerm_app_configuration_key" "subnet_aks_id" {
  configuration_store_id = azurerm_app_configuration.app_config.id
  key                    = "subnet_aks_id"
  value                  = azurerm_subnet.subnet_aks.id
  label                  = "v1"
}

resource "azurerm_app_configuration_key" "vm_id" {
  configuration_store_id = azurerm_app_configuration.app_config.id
  key                    = "vm_id"
  value                  = azurerm_windows_virtual_machine.spot_vm.id
  label                  = "v1"
}

resource "azurerm_app_configuration_key" "aks_cluster_id" {
  configuration_store_id = azurerm_app_configuration.app_config.id
  key                    = "aks_cluster_id"
  value                  = azurerm_kubernetes_cluster.aks_cluster.id
  label                  = "v1"
}

resource "azurerm_app_configuration_key" "windows_node_pool_id" {
  configuration_store_id = azurerm_app_configuration.app_config.id
  key                    = "windows_node_pool_id"
  value                  = azurerm_kubernetes_cluster_node_pool.windows_node_pool.id
  label                  = "v1"
}
