output "name" {
    value = var.name
}

output "id" {
    value = jsondecode(azurerm_resource_group_template_deployment.deployment.output_content).id.value
}