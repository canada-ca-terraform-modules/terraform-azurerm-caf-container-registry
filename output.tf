output "container-registry-object" {
  description = "Returns the entire container registry object"
  value = azurerm_container_registry.registry
}

output "id" {
  description = "Returns the ID of the container registry"
  value = azurerm_container_registry.registry.id
}

output "name" {
  description = "Returns the name of the container registry"
  value = azurerm_container_registry.registry.name
}