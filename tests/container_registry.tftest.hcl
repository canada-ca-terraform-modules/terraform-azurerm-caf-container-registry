mock_provider "azurerm" {}

variables {
  resource_groups      = { rg-test = { name = "rg-test", location = "canadacentral" } }
  subnets              = {}
  private_dns_zone_ids = {}
  env                  = "Dev"
  group                = "OPS"
  project              = "CORE"
  userDefinedString    = "test"
}

run "naming_convention" {
  command = plan
  variables {
    container_registry = {
      resource_group = "rg-test"
    }
  }
  assert {
    condition     = azurerm_container_registry.registry.name == "DevCCRtestRegistry"
    error_message = "Name must follow {env}CCR{userDefinedString}Registry convention"
  }
}

run "default_values" {
  command = plan
  variables {
    container_registry = {
      resource_group = "rg-test"
    }
  }
  assert {
    condition     = azurerm_container_registry.registry.sku == "Premium"
    error_message = "Default sku must be Premium"
  }
  assert {
    condition     = azurerm_container_registry.registry.admin_enabled == false
    error_message = "Default admin_enabled must be false"
  }
  assert {
    condition     = azurerm_container_registry.registry.network_rule_set[0].default_action == "Deny"
    error_message = "Default network_rule_set.default_action must be Deny"
  }
  assert {
    condition     = azurerm_container_registry.registry.azuread_authentication_as_arm_policy_enabled == true
    error_message = "Default azuread_authentication_as_arm_policy_enabled must be true"
  }
  assert {
    condition     = azurerm_container_registry.registry.network_rule_bypass_for_tasks_enabled == false
    error_message = "Default network_rule_bypass_for_tasks_enabled must be false"
  }
  assert {
    condition     = azurerm_container_registry.registry.role_assignment_mode == "LegacyRegistryPermissions"
    error_message = "Default role_assignment_mode must be LegacyRegistryPermissions"
  }
}

run "user_identity_created_by_default" {
  command = plan
  variables {
    container_registry = {
      resource_group = "rg-test"
    }
  }
  assert {
    condition     = length(azurerm_user_assigned_identity.identity) == 1
    error_message = "UAMI must be created by default (user_identity_enabled defaults true)"
  }
  assert {
    condition     = length(azurerm_role_assignment.name) == 1
    error_message = "AcrPull role assignment must be created by default"
  }
  assert {
    condition     = azurerm_role_assignment.name[0].skip_service_principal_aad_check == false
    error_message = "Default skip_service_principal_aad_check must be false"
  }
}

run "user_identity_disabled" {
  command = plan
  variables {
    container_registry = {
      resource_group        = "rg-test"
      user_identity_enabled = false
    }
  }
  assert {
    condition     = length(azurerm_user_assigned_identity.identity) == 0
    error_message = "UAMI must not be created when user_identity_enabled = false"
  }
  assert {
    condition     = length(azurerm_role_assignment.name) == 0
    error_message = "Role assignment must not be created when user_identity_enabled = false"
  }
}

run "single_georeplication_object" {
  command = plan
  variables {
    container_registry = {
      resource_group = "rg-test"
      georeplications = {
        location                        = "eastus"
        global_endpoint_routing_enabled = true
        zone_redundancy_enabled         = true
      }
    }
  }
  assert {
    condition     = length(azurerm_container_registry.registry.georeplications) == 1
    error_message = "A single georeplications object must be normalized to one entry"
  }
  assert {
    condition     = azurerm_container_registry.registry.georeplications[0].location == "eastus"
    error_message = "georeplications.location must be read from the location field, not .type"
  }
  assert {
    condition     = azurerm_container_registry.registry.georeplications[0].global_endpoint_routing_enabled == true
    error_message = "global_endpoint_routing_enabled must be applied"
  }
}

run "multiple_georeplications_list" {
  command = plan
  variables {
    container_registry = {
      resource_group = "rg-test"
      georeplications = [
        { location = "eastus", global_endpoint_routing_enabled = true },
        { location = "westus", global_endpoint_routing_enabled = true },
      ]
    }
  }
  assert {
    condition     = length(azurerm_container_registry.registry.georeplications) == 2
    error_message = "Multiple georeplications entries must be supported (azurerm >= 5.0 allows one or more)"
  }
}

run "georeplications_legacy_regional_endpoint_enabled" {
  command = plan
  variables {
    container_registry = {
      resource_group = "rg-test"
      georeplications = {
        location                  = "eastus"
        regional_endpoint_enabled = false
      }
    }
  }
  assert {
    condition     = azurerm_container_registry.registry.georeplications[0].global_endpoint_routing_enabled == false
    error_message = "Legacy regional_endpoint_enabled key must fall back to global_endpoint_routing_enabled"
  }
}

run "georeplications_tags" {
  command = plan
  variables {
    container_registry = {
      resource_group = "rg-test"
      georeplications = {
        location = "eastus"
        tags     = { replica = "true" }
      }
    }
  }
  assert {
    condition     = azurerm_container_registry.registry.georeplications[0].tags["replica"] == "true"
    error_message = "georeplications.tags must be read from the georeplications object, not the top-level container_registry.tags"
  }
}

run "identity_block" {
  command = plan
  variables {
    container_registry = {
      resource_group = "rg-test"
      identity = {
        type         = "UserAssigned"
        identity_ids = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.ManagedIdentity/userAssignedIdentities/mid"]
      }
    }
  }
  assert {
    condition     = length(azurerm_container_registry.registry.identity[0].identity_ids) == 1
    error_message = "identity.identity_ids must be read from the nested identity object, not a sibling key"
  }
}

run "encryption_block" {
  command = plan
  variables {
    container_registry = {
      resource_group = "rg-test"
      encryption = {
        key_vault_key_id   = "https://example.vault.azure.net/keys/example/000"
        identity_client_id = "00000000-0000-0000-0000-000000000000"
      }
    }
  }
  assert {
    condition     = azurerm_container_registry.registry.encryption[0].key_vault_key_id == "https://example.vault.azure.net/keys/example/000"
    error_message = "encryption.key_vault_key_id must be applied"
  }
}

run "network_rule_set_ip_rule" {
  command = plan
  variables {
    container_registry = {
      resource_group = "rg-test"
      network_rule_set = {
        default_action = "Allow"
        ip_rule = {
          rule1 = { action = "Allow", ip_range = "203.0.113.0/24" }
        }
      }
    }
  }
  assert {
    condition     = azurerm_container_registry.registry.network_rule_set[0].default_action == "Allow"
    error_message = "network_rule_set.default_action override must be applied"
  }
  assert {
    condition     = length(azurerm_container_registry.registry.network_rule_set[0].ip_rule) == 1
    error_message = "ip_rule must be applied"
  }
}

run "new_azurerm_5_arguments" {
  command = plan
  variables {
    container_registry = {
      resource_group                               = "rg-test"
      azuread_authentication_as_arm_policy_enabled = false
      network_rule_bypass_for_tasks_enabled        = true
      role_assignment_mode                         = "AbacRepositoryPermissions"
    }
  }
  assert {
    condition     = azurerm_container_registry.registry.azuread_authentication_as_arm_policy_enabled == false
    error_message = "azuread_authentication_as_arm_policy_enabled must be applied"
  }
  assert {
    condition     = azurerm_container_registry.registry.network_rule_bypass_for_tasks_enabled == true
    error_message = "network_rule_bypass_for_tasks_enabled must be applied"
  }
  assert {
    condition     = azurerm_container_registry.registry.role_assignment_mode == "AbacRepositoryPermissions"
    error_message = "role_assignment_mode must be applied"
  }
}

run "skip_service_principal_aad_check" {
  command = plan
  variables {
    container_registry = {
      resource_group                   = "rg-test"
      skip_service_principal_aad_check = true
    }
  }
  assert {
    condition     = azurerm_role_assignment.name[0].skip_service_principal_aad_check == true
    error_message = "skip_service_principal_aad_check must be applied"
  }
}

run "user_identity_isolation_scope" {
  command = plan
  variables {
    container_registry = {
      resource_group                = "rg-test"
      user_identity_isolation_scope = "Regional"
    }
  }
  assert {
    condition     = azurerm_user_assigned_identity.identity[0].isolation_scope == "Regional"
    error_message = "user_identity_isolation_scope must be applied"
  }
}

run "trust_policy_enabled_ignored" {
  command = plan
  variables {
    container_registry = {
      resource_group       = "rg-test"
      trust_policy_enabled = true
    }
  }
  assert {
    condition     = azurerm_container_registry.registry.sku == "Premium"
    error_message = "Legacy trust_policy_enabled key must be silently ignored (removed from azurerm >= 5.0), plan must still succeed"
  }
}

run "basic_sku_no_network_rule_set" {
  command = plan
  variables {
    container_registry = {
      resource_group = "rg-test"
      sku            = "Basic"
    }
  }
  assert {
    condition     = length(azurerm_container_registry.registry.network_rule_set) == 0
    error_message = "network_rule_set must not be rendered for non-Premium SKUs (Basic/Standard)"
  }
}

run "export_policy_defaults_match_public_network" {
  command = plan
  variables {
    container_registry = {
      resource_group = "rg-test"
      # public_network_access_enabled defaults to false; export_policy_enabled must also
      # default to false to avoid the API constraint that requires them to match.
    }
  }
  assert {
    condition     = azurerm_container_registry.registry.export_policy_enabled == false
    error_message = "export_policy_enabled must default to false when public_network_access_enabled defaults to false"
  }
}
