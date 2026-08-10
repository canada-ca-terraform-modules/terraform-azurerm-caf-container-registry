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

# Step 1: simulate a currently-deployed registry using pre-upgrade-style inputs
# (no new azurerm >= 5.0 arguments set).
run "baseline_apply" {
  command = apply

  # azurerm_role_assignment.name.scope reads azurerm_container_registry.registry.id, which
  # requires a realistic ARM-ID-formatted value to parse — mock_provider's default generated
  # id fails ARM ID validation. Override it on the run that creates the registry.
  override_resource {
    target = azurerm_container_registry.registry
    values = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.ContainerRegistry/registries/DevCCRtestRegistry"
    }
  }

  variables {
    container_registry = {
      resource_group = "rg-test"
      sku            = "Premium"
      admin_enabled  = false
    }
  }
  assert {
    condition     = azurerm_container_registry.registry.name == "DevCCRtestRegistry"
    error_message = "Baseline apply: unexpected resource name"
  }
}

# Step 2: plan the upgraded module code against that state, adding only new
# optional azurerm >= 5.0 arguments. No resource address change and no
# unexpected replacement should appear.
run "upgrade_plan_no_replacement" {
  command = plan
  variables {
    container_registry = {
      resource_group                        = "rg-test"
      sku                                   = "Premium"
      admin_enabled                         = false
      network_rule_bypass_for_tasks_enabled = true
    }
  }
  assert {
    condition     = azurerm_container_registry.registry.name == "DevCCRtestRegistry"
    error_message = "Resource name must be unchanged after upgrade"
  }
  assert {
    condition     = azurerm_container_registry.registry.network_rule_bypass_for_tasks_enabled == true
    error_message = "New argument must be applied without affecting existing resource identity"
  }
}
