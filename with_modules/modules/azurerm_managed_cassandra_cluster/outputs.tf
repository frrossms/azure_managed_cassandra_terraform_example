output "name" {
    value = jsondecode(azurerm_resource_group_template_deployment.deployment.output_content).clusterName.value
}

output "id" {
    value = jsondecode(azurerm_resource_group_template_deployment.deployment.output_content).clusterId.value
}

output "prometheus_endpoint" {
    value = jsondecode(azurerm_resource_group_template_deployment.deployment.output_content).clusterPrometheusEndpoint.value
}
