output "container-registry-object" {
  description = "Returns the entire container registry object"
  value       = azurerm_container_registry.registry
  sensitive   = true
}

output "id" {
  description = "Returns the ID of the container registry"
  value       = azurerm_container_registry.registry.id
}

output "name" {
  description = "Returns the name of the container registry"
  value       = azurerm_container_registry.registry.name
}

output "acr-pull-umi" {
  description = "The UMI that can be used to pull images. Should be a list of 1 object when user_identity_enabled is set to true."
  # Not sensitive: azurerm_user_assigned_identity exposes only non-secret metadata
  # (name, principal_id, client_id, tenant_id) - none of it is a credential or secret.
  value = azurerm_user_assigned_identity.identity
}
