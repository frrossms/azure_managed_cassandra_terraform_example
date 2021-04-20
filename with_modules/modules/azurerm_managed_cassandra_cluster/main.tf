data "local_file" "arm_template" {
    filename = "${path.module}/managed_cassandra_cluster.azrm.json"
}

resource "azurerm_resource_group_template_deployment" "deployment" {
  name                = uuid()
  resource_group_name = var.resource_group_name
  deployment_mode     = "Incremental"
  parameters_content = jsonencode({
    "delegatedManagementSubnetId" = {
      value = var.delegated_management_subnet_id
    }
    "name" = {
      value = var.name
    }
    "location" = {
      value = var.location
    }
    "initialCassandraAdminPassword" = {
      value = var.initial_cassandra_admin_password
    }
  })
  template_content = data.local_file.arm_template.content
}