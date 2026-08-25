# config/container_registry.tfvars
# One representative real-usage fixture - a plain Premium registry with the
# default AcrPull user-assigned identity, no for_each fan-out. Deploys into
# its own throwaway resource group (see test_dependencies.tf).
#
# Maintained by whoever adds a new optional input to the module: update this
# file in the same PR if you want live coverage of it, same discipline as
# updating tests/container_registry.tftest.hcl.

env = "livetest"

container_registry = {
  resource_group                = "live_test"
  sku                           = "Premium"
  admin_enabled                 = false
  public_network_access_enabled = false
}
