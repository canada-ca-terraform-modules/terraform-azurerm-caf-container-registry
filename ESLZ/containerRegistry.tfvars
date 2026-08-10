containerRegistry = {
  resource_group                = "Project"
  sku                           = "Premium"
  admin_enabled                 = false
  public_network_access_enabled = false
  # user_identity_enabled = true
  # quarantine_policy_enabled = null
  # retention_policy_in_days = 90
  # zone_redundancy_enabled = true
  # export_policy_enabled = true
  # anonymous_pull_enabled = false
  # data_endpoint_enabled = null
  # network_rule_bypass_option = "AzureServices"
  # trust_policy_enabled removed in azurerm >= 5.0 (Docker Content Trust retired) — no longer honored

  # --- New in azurerm >= 5.0 ---
  # azuread_authentication_as_arm_policy_enabled = true
  # network_rule_bypass_for_tasks_enabled = false
  # role_assignment_mode = "LegacyRegistryPermissions" # or "AbacRepositoryPermissions"
  # user_identity_isolation_scope = "Regional" # optional isolation scope for the AcrPull UMI
  # skip_service_principal_aad_check = false # set true to avoid AAD replication-lag errors

  # network_rule_set = {
  #   default_action = "Deny"
  #   ip_rule = {
  #     "rule1" = {
  #       action = "Allow"
  #       ip_range = "203.0.113.0/24"
  #     },
  #     # Add more IP rules as needed
  #   }
  # }

  # identity = {
  #   type = "SystemAssigned" # Example identity type
  #   identity_ids = [] # Example identity IDs
  # }

  # encryption = {
  #   key_vault_key_id = ""
  #   identity_client_id = ""
  # }

  # georeplications accepts a single object OR a list of objects (azurerm >= 5.0 supports
  # multiple georeplications blocks)
  # georeplications = {
  #   location = "canadaeast"
  #   global_endpoint_routing_enabled = true
  #   zone_redundancy_enabled = false
  # }
  # georeplications = [
  #   { location = "canadaeast", global_endpoint_routing_enabled = true, zone_redundancy_enabled = false },
  #   { location = "eastus",     global_endpoint_routing_enabled = true, zone_redundancy_enabled = false },
  # ]

  private_endpoint = {
    "registryTest" = {
      resource_group    = "Test"
      subnet            = "APP"
      subresource_names = ["registry"]
    }
  }
}
