data "local_file" "arm_template" {
    filename = "${path.module}/managed_cassandra_datacenter.azrm.json"
}

resource "azurerm_resource_group_template_deployment" "deployment" {
  name                = uuid()
  resource_group_name = var.resource_group_name
  deployment_mode     = "Incremental"
  parameters_content = jsonencode({
    "delegatedSubnetId" = {
      value = var.delegated_subnet_id
    }
    "clusterName" = {
      value = var.cluster_name
    }
    "dataCenterName" = {
        value = var.name
    }
    "location" = {
      value = var.location
    }
    "nodeCount" = {
      value = var.node_count
    }
  })
  template_content = data.local_file.arm_template.content
}