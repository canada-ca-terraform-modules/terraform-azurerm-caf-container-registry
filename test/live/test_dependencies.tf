# test_dependencies.tf
# Self-contained dependency resources, owned entirely by this harness.
#
# Deliberately NOT reusing any shared/production resource group: writing into
# a shared RG usually requires elevated, non-sandbox permissions. A dedicated
# throwaway RG here needs only Contributor on the sandbox subscription and
# can never collide with or affect any production resource.
#
# terraform-azurerm-caf-container-registry's optional `private_endpoint`
# sub-module (which would also need a vnet/subnet) is out of scope here - no
# vnet dependency is created.

resource "azurerm_resource_group" "live_test" {
  # PR-number suffix keeps two concurrently open PRs against this module from
  # colliding on the same sandbox resource group.
  name     = "${var.env}-caf-container-registry-live-test-${var.pr_number}-rg"
  location = var.location

  # pr-number tag (ticket 13): lets the nightly orphan sweeper find this RG
  # by tag and match it back to a PR, independent of naming convention.
  tags = {
    "pr-number" = var.pr_number
  }
}

locals {
  # terraform-azurerm-caf-container-registry expects resource_groups as a
  # keyed map: var.resource_groups[var.container_registry.resource_group].name
  resource_groups = {
    live_test = { name = azurerm_resource_group.live_test.name }
  }
}
