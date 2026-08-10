resource "azurerm_container_registry" "registry" {
  name                = local.container_registry-name
  resource_group_name = local.resource_group_name
  location            = var.location
  sku                 = try(var.container_registry.sku, "Premium")

  # Optional parameters
  admin_enabled                 = try(var.container_registry.admin_enabled, false)
  public_network_access_enabled = try(var.container_registry.public_network_access_enabled, false)
  quarantine_policy_enabled     = try(var.container_registry.quarantine_policy_enabled, null)
  retention_policy_in_days      = try(var.container_registry.retention_policy_in_days, 90)
  zone_redundancy_enabled       = try(var.container_registry.zone_redundancy_enabled, true)
  export_policy_enabled         = try(var.container_registry.export_policy_enabled, true)
  anonymous_pull_enabled        = try(var.container_registry.anonymous_pull_enabled, false)
  data_endpoint_enabled         = try(var.container_registry.data_endpoint_enabled, null)
  network_rule_bypass_option    = try(var.container_registry.network_rule_bypass_option, "AzureServices")
  # New in azurerm >= 5.0
  azuread_authentication_as_arm_policy_enabled = try(var.container_registry.azuread_authentication_as_arm_policy_enabled, true)
  network_rule_bypass_for_tasks_enabled        = try(var.container_registry.network_rule_bypass_for_tasks_enabled, false)
  role_assignment_mode                         = try(var.container_registry.role_assignment_mode, "LegacyRegistryPermissions")
  # `trust_policy_enabled` removed from the azurerm provider schema in v5.0 (Docker Content Trust
  # retirement) — no longer passed to the resource. Callers whose tfvars still set it inside the
  # `container_registry` object (type = any) are unaffected; the key is now silently ignored.

  network_rule_set {
    default_action = try(var.container_registry.network_rule_set.default_action, "Deny")
    dynamic "ip_rule" {
      for_each = try(var.container_registry.network_rule_set.ip_rule, {})
      content {
        action   = ip_rule.value["action"]
        ip_range = ip_rule.value["ip_range"]
      }
    }
  }

  dynamic "identity" {
    for_each = try(var.container_registry.identity, null) != null ? [1] : []
    content {
      type         = var.container_registry.identity.type
      identity_ids = try(var.container_registry.identity.identity_ids, [])
    }
  }

  dynamic "encryption" {
    for_each = try(var.container_registry.encryption, null) != null ? [1] : []
    content {
      key_vault_key_id   = var.container_registry.encryption.key_vault_key_id
      identity_client_id = var.container_registry.encryption.identity_client_id
    }
  }

  dynamic "georeplications" {
    for_each = local.georeplications
    content {
      location                        = try(georeplications.value["location"], "canadaeast")
      global_endpoint_routing_enabled = try(georeplications.value["global_endpoint_routing_enabled"], try(georeplications.value["regional_endpoint_enabled"], true))
      zone_redundancy_enabled         = try(georeplications.value["zone_redundancy_enabled"], false)
      tags                            = merge(var.tags, try(georeplications.value["tags"], {}))
    }
  }

  tags = merge(var.tags, try(var.container_registry.tags, {}))

  lifecycle {
    ignore_changes = [tags]
  }
}

module "private_endpoint" {
  source   = "github.com/canada-ca-terraform-modules/terraform-azurerm-caf-private_endpoint.git?ref=v1.2.0"
  for_each = try(var.container_registry.private_endpoint, {})

  name                           = "${local.container_registry-name}-${each.key}"
  location                       = var.location
  resource_groups                = var.resource_groups
  subnets                        = var.subnets
  private_connection_resource_id = azurerm_container_registry.registry.id
  private_endpoint               = each.value
  private_dns_zone_ids           = var.private_dns_zone_ids
  tags                           = var.tags
}

resource "azurerm_user_assigned_identity" "identity" {
  count               = try(var.container_registry.user_identity_enabled, true) ? 1 : 0
  location            = var.location
  name                = "${local.container_registry-name}-AcrPull"
  resource_group_name = local.resource_group_name
  # New in azurerm >= 5.0 — optional, no impact on existing deployments when unset
  isolation_scope = try(var.container_registry.user_identity_isolation_scope, null)
  tags            = var.tags
}


resource "azurerm_role_assignment" "name" {
  count                = try(var.container_registry.user_identity_enabled, true) ? 1 : 0
  scope                = azurerm_container_registry.registry.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.identity[0].principal_id
  # Optional: helps avoid AAD replication-lag errors when principal_id references an identity
  # created in the same apply. Defaults to false to preserve existing behaviour.
  skip_service_principal_aad_check = try(var.container_registry.skip_service_principal_aad_check, false)
}
