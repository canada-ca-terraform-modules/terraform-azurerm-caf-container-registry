locals {
  resource_group_name = strcontains(var.container_registry.resource_group, "/resourceGroups/") ? regex("[^\\/]+$", var.container_registry.resource_group) :  var.resource_groups[var.container_registry.resource_group].name
}