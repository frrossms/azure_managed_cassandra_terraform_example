output "subnet_ids" {
    value = {for vnet in azurerm_virtual_network.vnets: 
        vnet.name => tolist(vnet.subnet)[0].id
    }
}