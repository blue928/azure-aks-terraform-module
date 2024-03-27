# ---------------------------------------------------------------------------------------------------------------------
# CREATE A PRODUCTION-GRADE, AUTO-SCALING AKS KUBERNETES CLUSTER
# ---------------------------------------------------------------------------------------------------------------------

resource "azurerm_kubernetes_cluster" "k8s" {
  name                    = var.cluster_name
  location                = var.location
  resource_group_name     = var.resource_group_name
  node_resource_group     = "${var.cluster_name}-nrg"
  dns_prefix              = "${var.cluster_name}-dns-prefix"
  sku_tier                = var.sku_tier
  private_cluster_enabled = var.private_cluster_enabled

  default_node_pool {
    name = "agentpool"
    # node_count      = var.agent_count

    vm_size             = var.agents_size
    type                = "VirtualMachineScaleSets"
    enable_auto_scaling = true
    max_count           = var.agents_max_count
    min_count           = var.agents_min_count
    os_disk_size_gb     = var.os_disk_size_gb

    upgrade_settings {
      max_surge = "10%"
    }
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    load_balancer_sku = "standard"
    network_plugin    = "kubenet"
  }

}

# TODO clean this up
resource "azurerm_role_assignment" "example" {
  principal_id                     = azurerm_kubernetes_cluster.k8s.kubelet_identity[0].object_id
  role_definition_name             = "Contributor"
  scope                            = var.azurerm_container_registry_id
  skip_service_principal_aad_check = true
}
