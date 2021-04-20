terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 2.26"
    }
  }
}

provider "azurerm" {
  features {}
}

locals {
    resource_group_name = "frross-southcentralus-test-rg"
    cluster_name = "my_cluster"
    cluster_location = "southcentralus"
    delegated_management_subnet_id = "/subscriptions/dd31ecae-4522-468e-8b27-5befd051dd53/resourceGroups/frross-southcentralus-test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/default"
    initial_cassandra_admin_password = "mypassword"
    data_centers = [
        {
            "name" = "dc1"
            "location" = "southcentralus"
            "subnet_id" = "/subscriptions/dd31ecae-4522-468e-8b27-5befd051dd53/resourceGroups/frross-southcentralus-test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/default"
            "node_count" = "3"
        },
        {
            "name" = "dc2"
            "location" = "uswest"
            "subnet_id" = "/subscriptions/dd31ecae-4522-468e-8b27-5befd051dd53/resourceGroups/frross-southcentralus-test-rg/providers/Microsoft.Network/virtualNetworks/uswest-vnet/subnets/default"
            "node_count" = "3"
        }
    ]
}

data "local_file" "arm_template" {
    filename = "${path.module}/managed_cassandra.azrm.json"
}

resource "azurerm_resource_group_template_deployment" "deployment" {
  name                = uuid()
  resource_group_name = local.resource_group_name
  deployment_mode     = "Incremental"
  template_content = data.local_file.arm_template.content
  parameters_content = jsonencode({
    "clusterName" = {
      value = local.cluster_name
    }
    "clusterLocation" = {
      value = local.cluster_location
    }
    "delegatedManagementSubnetId" = {
      value = local.delegated_management_subnet_id
    }
    "initialCassandraAdminPassword" = {
      value = local.initial_cassandra_admin_password
    }
    "dataCenters" = {
      value = local.data_centers
    }
  })
}

output "cluster_name" {
    value = jsondecode(azurerm_resource_group_template_deployment.deployment.output_content).clusterName.value
}

output "cluster_id" {
    value = jsondecode(azurerm_resource_group_template_deployment.deployment.output_content).clusterId.value
}

output "prometheus_endpoint" {
    value = jsondecode(azurerm_resource_group_template_deployment.deployment.output_content).clusterPrometheusEndpoint.value
}

output "seed_nodes" {
    value = jsondecode(azurerm_resource_group_template_deployment.deployment.output_content).seedNodes.value
}
