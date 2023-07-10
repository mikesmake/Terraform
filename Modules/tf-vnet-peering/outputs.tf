output "vnet_name" {
  value       = azurerm_virtual_network.vnet.name
  description = "The name of the vnet"
}

output "vnet_id" {
  value       = azurerm_virtual_network.vnet.id
  description = "The ID of the vnet"
}


#Dynamic output objects based on subnets created
output "subnets" {
  value = [
    for name, id in zipmap(
      sort(values(azurerm_subnet.subnet)[*]["name"]),
    sort(values(azurerm_subnet.subnet)[*]["id"])) :
    tomap({ "name" = name, "id" = id })
  ]
  description = "The name and id of the created subnets"
}