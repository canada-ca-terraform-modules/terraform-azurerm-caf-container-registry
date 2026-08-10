# Changelog

All notable changes to this module are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [1.1.0] - 2026-08-10

### Changed

- Upgraded target provider to `azurerm ~> 5.0` (added `providers.tf` — none existed before).
- `georeplications.regional_endpoint_enabled` migrated to `global_endpoint_routing_enabled`
  (renamed and made Required by the provider in the 5.0 major). Legacy `regional_endpoint_enabled`
  key is still accepted in `container_registry.georeplications` and mapped across; defaults to
  `true` when neither key is set.
- `georeplications` now accepts a single object **or** a list of objects, so multiple
  geo-replication locations can be configured (azurerm >= 5.0 supports "one or more"
  `georeplications` blocks; the module previously only ever emitted one).
- `network_rule_set.default_action` is now overridable via
  `container_registry.network_rule_set.default_action` (previously hardcoded to `"Deny"`;
  default unchanged).
- `network_rule_set` block is now a `dynamic` block rendered only when `sku = "Premium"`
  (the default). Basic and Standard SKUs no longer receive a `network_rule_set` block that
  the Azure API would reject.
- `export_policy_enabled` now defaults to `false` when `public_network_access_enabled` is
  `false` (the module default), satisfying the Azure API constraint that the two flags must
  match. Callers who set `public_network_access_enabled = true` will continue to receive
  `export_policy_enabled = true` unless they override it.

### Fixed

- **Bug:** `georeplications.location` incorrectly read `var.container_registry.georeplications.type`
  instead of `.location`, so every geo-replication silently ignored the caller's intended location
  and always fell back to `"canadaeast"`. Now reads `.location` correctly.
- **Bug:** `georeplications.tags` incorrectly re-read the top-level `var.container_registry.tags`
  instead of the per-georeplication `tags` field. Now reads `georeplications.tags` correctly.
- **Bug:** `identity.identity_ids` incorrectly read a sibling `var.container_registry.identity_ids`
  key instead of the nested `var.container_registry.identity.identity_ids`. Now reads the
  correctly-nested field.
- **Bug:** invalid regex escape `[^\/]` in `locals.tf` (`\/` is not a valid Terraform/RE2 escape).
  Changed to `[^/]`.
- **Bug:** an empty `georeplications = {}` object normalized to a single list entry (`[{}]`),
  silently rendering one `georeplications` block full of defaults (`location = "canadaeast"`,
  `global_endpoint_routing_enabled = true`) the caller never asked for. Empty objects are now
  filtered out of the normalized list; an empty `georeplications = []` or `= {}` both correctly
  produce zero blocks.
- Removed dead locals in `name.tf` (`container_registry-regex`, `env-regex_compliant`,
  `container_registry-userDefinedString-regex_compliant`, `group-regex_compliant`,
  `project-regex_compliant`) — never referenced anywhere in the module.

### Removed

- `trust_policy_enabled` is no longer passed to `azurerm_container_registry` — the argument
  was removed from the azurerm provider schema in the 5.0 major (Docker Content Trust
  retirement). Callers whose `container_registry` object still sets this key are unaffected
  (the object is `type = any`; the key is now silently ignored) — this is a no-op going forward,
  not a plan error.

### Added

- `azuread_authentication_as_arm_policy_enabled` (default `true`, matches provider default).
- `network_rule_bypass_for_tasks_enabled` (default `false`, matches provider default).
- `role_assignment_mode` (default `"LegacyRegistryPermissions"`, matches provider default).
- `user_identity_isolation_scope` — maps to the new `azurerm_user_assigned_identity.isolation_scope`
  argument (azurerm >= 5.0), default `null`.
- `skip_service_principal_aad_check` on the `AcrPull` role assignment — helps avoid AAD
  replication-lag errors when the identity was created in the same apply. Default `false`
  (unchanged behaviour).
- `sensitive = true` added to `container-registry-object` — exposes a full resource object
  including `admin_password` when admin is enabled. `acr-pull-umi` is deliberately **not**
  marked sensitive: `azurerm_user_assigned_identity` only exposes non-secret metadata (name,
  principal_id, client_id, tenant_id).
- `providers.tf`, `.tflint.hcl`, `.gitignore`, `.gitattributes`, `tests/container_registry.tftest.hcl`,
  `tests/upgrade_compat.tftest.hcl`, `.github/workflows/{documentation,terraform-ci,release}.yml` —
  none of these existed before this upgrade.

### Upgrade Notes / Known Drift

The following azurerm >= 5.0 arguments are newly exposed with module-level defaults that match
the *provider's own default for newly-created resources* — they do **not** necessarily match what
an **existing** registry (deployed under the old provider, where these arguments didn't exist) is
currently set to. Applying this upgrade against an existing registry may therefore show an
in-place `~ update`, not just "no changes":

- `azuread_authentication_as_arm_policy_enabled` (module default `true`) — some existing
  registries may have relied on this being unset/off under azurerm < 5.0.
- `role_assignment_mode` (module default `"LegacyRegistryPermissions"`) — an existing registry
  already migrated to `"AbacRepositoryPermissions"` outside Terraform would be silently reverted
  unless the caller explicitly sets `role_assignment_mode = "AbacRepositoryPermissions"` in
  `container_registry`.
- `network_rule_bypass_for_tasks_enabled` (module default `false`) — may conflict with an
  existing registry's in-use ACR Tasks configuration.

**Action for existing callers:** run `terraform plan` after upgrading and review any diff on
these three arguments before applying; set them explicitly in `container_registry` to pin the
current real value if the default doesn't match.

### Known trade-offs

- `.tflint.hcl` sets `call_module_type = "local"`, so `tflint` does not validate the remote
  `private_endpoint` child module call. This is intentional (avoids requiring network access /
  a full remote-module fetch in CI just to lint), but means tflint will not catch schema drift
  in that child module — `terraform validate`/`terraform test` remain the source of truth for it.

### Known blockers

- None. Child module `terraform-azurerm-caf-private_endpoint` bumped from `v1.0.1` to `v1.2.0`
  (latest release) — its own `providers.tf` already pins `azurerm ~> 5.0`, no conflict.
