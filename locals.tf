locals {
  resource_group_name = strcontains(var.container_registry.resource_group, "/resourceGroups/") ? regex("[^/]+$", var.container_registry.resource_group) : var.resource_groups[var.container_registry.resource_group].name

  # georeplications accepts either a single object or a list of objects — normalize to a list.
  # azurerm >= 5.0 supports "one or more" georeplications blocks; the pre-upgrade code only
  # ever emitted a single block regardless of caller input.
  _georeplications_raw = try(var.container_registry.georeplications, [])
  _georeplications_list = try(
    tolist(local._georeplications_raw),
    [local._georeplications_raw]
  )
  # Guard against an empty object (georeplications = {}) normalizing to a single element
  # ([{}]) that would otherwise render one georeplications block full of defaults
  # (location "canadaeast", global_endpoint_routing_enabled = true) that the caller never
  # asked for. An empty list (georeplications = []) already correctly produces no blocks.
  georeplications = [for g in local._georeplications_list : g if length(g) > 0]
}
