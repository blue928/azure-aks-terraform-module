# ---------------------------------------------------------------------------------------------------------------------
# CREATE A PRODUCTION-GRADE, AUTO-SCALING AKS KUBERNETES CLUSTER
# ---------------------------------------------------------------------------------------------------------------------

resource "azurerm_kubernetes_cluster" "k8s" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  node_resource_group = "${var.cluster_name}-nrg"
  dns_prefix          = "${var.cluster_name}-dns-prefix"
  sku_tier                = var.sku_tier
  private_cluster_enabled = var.private_cluster_enabled

  default_node_pool {
    name = "agentpool"
    # node_count      = var.agent_count

    # Let Azure manage the API version automatically
    # orchestrator_version = data.azurerm_kubernetes_service_versions.current.latest_version
    vm_size                = var.agents_size
    availability_zones  = [1, 2, 3]
    type                = "VirtualMachineScaleSets"
    enable_auto_scaling = true
      max_count              = var.agents_max_count
      min_count              = var.agents_min_count
    os_disk_size_gb        = var.os_disk_size_gb

    node_taints = []
    tags        = {}
  }

  identity {
    type = "SystemAssigned"
  }

  role_based_access_control {
    enabled = false
  }

#christ, learn how to do a fucking dynamic already TODO
# This fucking container insight bullshit is really starting to piss me off
  #oms_agent {
  #log_analytics_workspace_id = var.log_analytics_workspace_id
  #}

  network_profile {
    load_balancer_sku = "Standard"
    network_plugin    = "kubenet"
  }

  tags = {
    #environment = var.environment
  }
}