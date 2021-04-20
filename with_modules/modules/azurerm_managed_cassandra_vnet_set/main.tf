locals {
    cosmosdb_service_principal = "e5007d2c-4b13-4a74-9b6a-605d99f03501"
}

resource "azurerm_virtual_network" "vnets" {
  for_each            = var.layout
  name                = each.key
  address_space       = [each.value.cidr]
  location            = each.value.location
  resource_group_name = var.resource_group_name
  
  subnet {
      name = "default"
      address_prefix = each.value.cidr
  }
}

resource "azurerm_role_assignment" "allow_vnet_access" {
  for_each           = azurerm_virtual_network.vnets
  name               = uuidv5("dns", each.value.name)
  scope              = each.value.id
  role_definition_name = "Network Contributor"
  principal_id       = local.cosmosdb_service_principal
}

locals {
    vnet_combinations = setsubtract(
        setproduct(keys(var.layout), keys(var.layout)),
        [for v in keys(var.layout): [v, v]]
    )
    vnet_peerings = {for pair in local.vnet_combinations:
        format("peer-%s-to-%s", pair[0], pair[1]) => pair
    }
}

resource "azurerm_virtual_network_peering" "peerings" {
  for_each                  = local.vnet_peerings
  name                      = each.key
  resource_group_name       = var.resource_group_name
  virtual_network_name      = each.value[0]
  remote_virtual_network_id = azurerm_virtual_network.vnets[each.value[1]].id
}
