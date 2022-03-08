# As a module, it's expected that a resource group will have already been created by the parent (root)
# caller. We get that resource group's data here which will be reused to populate the required data
# for the cluster.
data "azurerm_resource_group" "k8s" {
  name = var.resource_group_name
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE A PRODUCTION-GRADE, AUTO-SCALING AKS KUBERNETES CLUSTER
# ---------------------------------------------------------------------------------------------------------------------

resource "azurerm_kubernetes_cluster" "k8s" {
  name                = var.cluster_name
  location            = data.azurerm_resource_group.k8s.location
  resource_group_name = data.azurerm_resource_group.k8s.name
  node_resource_group = "${var.cluster_name}-nrg"
  dns_prefix          = "${var.cluster_name}-dns-prefix"
  sku_tier                = var.sku_tier
  private_cluster_enabled = var.private_cluster_enabled

  default_node_pool {
    name = "agentpool"
    # node_count      = var.agent_count

    # Let Azure manage the API version automatically
    # orchestrator_version = data.azurerm_kubernetes_service_versions.current.latest_version
    vm_size             = var.cluster_default_node_pool_vm_size
    availability_zones  = [1, 2, 3]
    type                = "VirtualMachineScaleSets"
    enable_auto_scaling = true
    max_count           = var.cluster_default_node_pool_max_count
    min_count           = var.cluster_default_node_pool_min_count
    os_disk_size_gb     = var.cluster_default_node_pool_os_disk_size_gb

    node_taints = []
    tags        = {}
  }

  identity {
    type = "SystemAssigned"
  }

  role_based_access_control {
    enabled = false
  }

  oms_agent {
  log_analytics_workspace_id = var.log_analytics_workspace_id
  }

  network_profile {
    load_balancer_sku = "Standard"
    network_plugin    = "kubenet"
  }

  tags = {
    #environment = var.environment
  }
}