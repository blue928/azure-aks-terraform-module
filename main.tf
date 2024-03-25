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

    # Let Azure manage the API version automatically
    # orchestrator_version = data.azurerm_kubernetes_service_versions.current.latest_version
    vm_size = var.agents_size
    # todo remove as of 3.0 availability_zones  = [1, 2, 3]
    type                = "VirtualMachineScaleSets"
    enable_auto_scaling = true
    max_count           = var.agents_max_count
    min_count           = var.agents_min_count
    os_disk_size_gb     = var.os_disk_size_gb

    node_taints = []
    tags        = {}
  }

  identity {
    type = "SystemAssigned"
  }

  # todo remove as of 3.0
  #role_based_access_control {
  #  enabled = false
  #}


 # oms_agent {
 #   log_analytics_workspace_id = var.log_analytics_workspace_id
 # }

  network_profile {
    load_balancer_sku = "standard"
    network_plugin    = "kubenet"
  }

  tags = {
    #environment = var.environment
  }
}

# TODO clean this up
resource "azurerm_role_assignment" "example" {
  principal_id                     = azurerm_kubernetes_cluster.k8s.kubelet_identity[0].object_id
  role_definition_name             = "Contributor"
  scope                            = var.azurerm_container_registry_id
  skip_service_principal_aad_check = true
}
