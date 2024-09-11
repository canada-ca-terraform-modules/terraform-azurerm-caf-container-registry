containerRegistry = {
  resource_group                = "Project"
  sku                           = "Premium"
  admin_enabled                 = false
  public_network_access_enabled = false
  # user_identity_enabled = true
  # quarantine_policy_enabled = null 
  # retention_policy_in_days = 90 
  # trust_policy_enabled = false 
  # zone_redundancy_enabled = true 
  # export_policy_enabled = true 
  # anonymous_pull_enabled = false 
  # data_endpoint_enabled = null 
  # network_rule_bypass_option = "AzureServices"

  # network_rule_set = {
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
  #   identity_client_id = """
  # }

  # georeplications = {
  #   location = "canadaeast"
  #   regional_endpoint_enabled = null
  #   zone_redundancy_enabled = false 
  # }

  private_endpoint = {
    "registryTest" = {
      resource_group    = "Test"
      subnet            = "APP"
      subresource_names = ["registry"]
    }
  }
}
