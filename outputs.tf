output "app_configuration_endpoint" {
  value = azurerm_app_configuration.app_config.endpoint
}

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
