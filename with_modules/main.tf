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
    cosmosdb_service_principal = "e5007d2c-4b13-4a74-9b6a-605d99f03501"
    role_assignment_guid = "df035226-7514-4414-9437-e9442df55be3"
    layout = {
      westus2_vnet = {
        location = "westus2"
        cidr = "10.0.0.0/24"
      },
      eastus2_vnet = {
        location = "eastus2"
        cidr = "10.0.1.0/24"
      }
    }
    management_uses = "westus2_vnet"
}

resource "azurerm_resource_group" "terraform_rg" {
    name = "terraform-test2-rg"
    location = "westus2"
}

module "vnets" {
  source = "./modules/azurerm_managed_cassandra_vnet_set"
  resource_group_name = azurerm_resource_group.terraform_rg.name
  layout = local.layout
}

module "cassandra_cluster" {
  source = "./modules/azurerm_managed_cassandra_cluster"
  name = "mycluster2"
  location = local.layout[local.management_uses].location
  resource_group_name = azurerm_resource_group.terraform_rg.name
  initial_cassandra_admin_password = "mypassword"
  delegated_management_subnet_id = module.vnets.subnet_ids[local.management_uses]
}

module "cassandra_data_center" {
  for_each = local.layout
  source = "./modules/azurerm_managed_cassandra_datacenter"
  name = format("%s-dc", each.value.location)
  cluster_name = module.cassandra_cluster.name
  delegated_subnet_id = module.vnets.subnet_ids[each.key]
  location = each.value.location
  resource_group_name = azurerm_resource_group.terraform_rg.name
  node_count = 3
}