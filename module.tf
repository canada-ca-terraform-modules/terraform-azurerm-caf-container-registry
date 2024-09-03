resource "azurerm_container_registry" "registry" {
  name = local.container_registry-name
  resource_group_name = local.resource_group_name
  location = var.location
  sku = try(var.container_registry.sku, "Premium")

  # Optional parameters
  admin_enabled = try(var.container_registry.admin_enabled, false)
  public_network_access_enabled = try(var.container_registry.public_network_access_enabled, false)
  quarantine_policy_enabled = try(var.container_registry.quarantine_policy_enabled, null)
  retention_policy_in_days = try(var.container_registry.retention_policy_in_days, 90)
  trust_policy_enabled = try(var.container_registry.trust_policy_enabled, false)
  zone_redundancy_enabled = try(var.container_registry.zone_redundancy_enabled, true)
  export_policy_enabled = try(var.container_registry.export_policy_enabled, true)
  anonymous_pull_enabled = try(var.container_registry.anonymous_pull_enabled, false)
  data_endpoint_enabled = try(var.container_registry.data_endpoint_enabled, null)
  network_rule_bypass_option = try(var.container_registry.network_rule_bypass_option, "AzureServices")


  network_rule_set {
    default_action = "Deny"
    dynamic "ip_rule" {
      for_each = try(var.container_registry.network_rule_set.ip_rule, {})
      content {
        action = ip_rule.value["action"]
        ip_range = ip_rule.value["ip_range"]
      }
    }
  }

  dynamic "identity" {
    for_each = try(var.container_registry.identity, null) != null ? [1] : []
    content {
      type = var.container_registry.identity.type
      identity_ids = try(var.container_registry.identity_ids, [])
    }
  }

  dynamic "encryption" {
    for_each = try(var.container_registry.encryption, null) != null ? [1] : []
    content {
      key_vault_key_id = var.container_registry.encryption.key_vault_key_id
      identity_client_id = var.container_registry.encryption.identity_client_id
    }
  }

  dynamic "georeplications" {
    for_each = try(var.container_registry.georeplications, null) != null ? [1] : []
    content {
      location = try(var.container_registry.georeplications.type, "canadaeast")
      regional_endpoint_enabled = try(var.container_registry.georeplications.regional_endpoint_enabled, null)
      zone_redundancy_enabled = try(var.container_registry.georeplications.zone_redundancy_enabled, false)
      tags = merge(var.tags, try(var.container_registry.tags, {}))
    }
  }

  tags = merge(var.tags, try(var.container_registry.tags, {}))

  lifecycle {
    ignore_changes = [ tags, ]
  }
}

module "private_endpoint" {
  source = "github.com/canada-ca-terraform-modules/terraform-azurerm-caf-private_endpoint.git?ref=v1.0.1"
  for_each =  try(var.container_registry.private_endpoint, {}) 

  name = "${local.container_registry-name}-${each.key}"
  location = var.location
  resource_groups = var.resource_groups
  subnets = var.subnets
  private_connection_resource_id = azurerm_container_registry.registry.id
  private_endpoint = each.value
  private_dns_zone_ids = var.private_dns_zone_ids
  tags = var.tags
}