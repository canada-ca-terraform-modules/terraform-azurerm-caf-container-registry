# terraform-azurerm-caf-container-registry

Deploys an Azure Container Registry (ACR), an optional user-assigned managed identity with
`AcrPull` role assignment, and optional private endpoint(s), following the SSC ESLZ CAF naming
convention.

## Usage

### ESLZ module block (`ESLZ/containerRegistry.tf`)

```hcl
variable "containerRegistry" {
  description = "Object container all the parameters for container registries"
  type        = any
  default     = {}
}

module "containerRegistry" {
  source   = "github.com/canada-ca-terraform-modules/terraform-azurerm-caf-container-registry.git?ref=v1.1.0"
  for_each = var.containerRegistry

  userDefinedString    = each.key
  env                  = var.env
  group                = var.group
  project              = var.project
  location             = var.location
  resource_groups      = local.resource_groups_all
  container_registry   = each.value
  subnets              = local.subnets
  private_dns_zone_ids = local.Project-dns-zone
  tags                 = var.tags
}
```

### ESLZ tfvars pattern (`ESLZ/containerRegistry.tfvars`)

```hcl
containerRegistry = {
  myRegistry = {
    resource_group                 = "Project"
    sku                            = "Premium"
    admin_enabled                  = false
    public_network_access_enabled  = false

    private_endpoint = {
      "registryTest" = {
        resource_group    = "Test"
        subnet            = "APP"
        subresource_names = ["registry"]
      }
    }
  }
}
```

## New arguments (azurerm >= 5.0)

### `container_registry` — new top-level keys

| Key | Type | Description |
|---|---|---|
| `azuread_authentication_as_arm_policy_enabled` | bool | Whether to use the Azure Resource Manager audience token. Default `true`. |
| `network_rule_bypass_for_tasks_enabled` | bool | Whether ACR Tasks can bypass network restrictions. Default `false`. |
| `role_assignment_mode` | string | `LegacyRegistryPermissions` (default) or `AbacRepositoryPermissions`. |
| `user_identity_isolation_scope` | string | Isolation scope for the `AcrPull` UMI. Only possible value: `Regional`. Default `null`. |
| `skip_service_principal_aad_check` | bool | Set `true` to avoid AAD replication-lag failures when the identity is created in the same apply. Default `false`. |

### `georeplications` — accepts a single object or a list

`georeplications` now accepts either a single object or a list of objects, since azurerm >= 5.0
supports one or more geo-replication locations.

```hcl
# Single object (still supported)
georeplications = {
  location                         = "eastus"
  global_endpoint_routing_enabled  = true
  zone_redundancy_enabled          = false
}

# Multiple locations (new)
georeplications = [
  { location = "eastus", global_endpoint_routing_enabled = true },
  { location = "westus", global_endpoint_routing_enabled = true },
]
```

`regional_endpoint_enabled` (legacy key name) is still accepted and mapped to the provider's
`global_endpoint_routing_enabled` argument if `global_endpoint_routing_enabled` isn't set.

## Removed arguments (azurerm >= 5.0)

- `trust_policy_enabled` — removed from the provider schema (Docker Content Trust retired). The
  module no longer passes it to the resource. Existing tfvars that still set this key are
  unaffected; the key is silently ignored.

## Testing

```bash
terraform fmt -recursive && terraform init -backend=false && terraform validate && terraform test
```

## CI

- `.github/workflows/terraform-ci.yml` runs fmt, init, validate, test, and tflint on every PR.
- `.github/workflows/documentation.yml` regenerates the Terraform docs section below on every PR.
- `.github/workflows/release.yml` creates a GitHub release on merge to `main`, tagged with the
  version pinned in `ESLZ/containerRegistry.tf`'s own `?ref=`.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 5.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_private_endpoint"></a> [private\_endpoint](#module\_private\_endpoint) | github.com/canada-ca-terraform-modules/terraform-azurerm-caf-private_endpoint.git | v1.2.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_container_registry.registry](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry) | resource |
| [azurerm_role_assignment.name](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_user_assigned_identity.identity](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_container_registry"></a> [container\_registry](#input\_container\_registry) | Object container all container registry parameters | `any` | `{}` | no |
| <a name="input_env"></a> [env](#input\_env) | (Required) Env part of the name for the registry | `string` | n/a | yes |
| <a name="input_group"></a> [group](#input\_group) | (Required) Group part of the name for the registry. Not used in the naming formula; retained because ESLZ/containerRegistry.tf passes it through as part of the L2 caller contract. | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Azure location where the registry will be located | `string` | `"canadacentral"` | no |
| <a name="input_private_dns_zone_ids"></a> [private\_dns\_zone\_ids](#input\_private\_dns\_zone\_ids) | Object containing private DNS zone Ids for the subscription | `any` | `{}` | no |
| <a name="input_project"></a> [project](#input\_project) | (Required) Project part of the name for the registry. Not used in the naming formula; retained because ESLZ/containerRegistry.tf passes it through as part of the L2 caller contract. | `string` | n/a | yes |
| <a name="input_resource_groups"></a> [resource\_groups](#input\_resource\_groups) | Resource group object containing all resource groups | `any` | `{}` | no |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | Object containing all subnets in the project | `any` | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to be applied to the registry | `map(string)` | `{}` | no |
| <a name="input_userDefinedString"></a> [userDefinedString](#input\_userDefinedString) | (Required) UserDefinedString part of the name of the registry | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_acr-pull-umi"></a> [acr-pull-umi](#output\_acr-pull-umi) | The UMI that can be used to pull images. Should be a list of 1 object when user\_identity\_enabled is set to true. |
| <a name="output_container-registry-object"></a> [container-registry-object](#output\_container-registry-object) | Returns the entire container registry object |
| <a name="output_id"></a> [id](#output\_id) | Returns the ID of the container registry |
| <a name="output_name"></a> [name](#output\_name) | Returns the name of the container registry |
<!-- END_TF_DOCS -->

## User Assigned Identity

An option user_identity_enabled can be configured to create a user assigned identity with the AcrPull role assigned. This identity is used by the ACI to connect to the ACR and pull container images. 
It is enabled by default. 

## TFVARS Parameters

| Parameter Name                                 | Possible Values                                     | Required | Default                      |
| ------------------------------------------------ | ----------------------------------------------------- | -------- | ------------------------------ |
| `name`                                            | string                                                 | Yes      | n/a                            |
| `sku`                                             | Basic,Standard,Premium                                 | No       | "Premium"                      |
| `admin_enabled`                                   | true,false                                             | No       | false                          |
| `public_network_access_enabled`                   | true,false                                             | No       | false                          |
| `user_identity_enabled`                           | true,false                                             | No       | true                           |
| `quarantine_policy_enabled`                       | true,false                                             | No       | null                           |
| `retention_policy_in_days`                        | int                                                     | No       | 90                             |
| `zone_redundancy_enabled`                         | true,false                                             | No       | true                           |
| `export_policy_enabled`                           | true,false                                             | No       | true                           |
| `anonymous_pull_enabled`                          | true,false                                             | No       | false                          |
| `data_endpoint_enabled`                           | true,false                                             | No       | null                           |
| `network_rule_bypass_option`                      | string                                                  | No       | "AzureServices"                |
| `azuread_authentication_as_arm_policy_enabled`     | true,false                                             | No       | true                           |
| `network_rule_bypass_for_tasks_enabled`            | true,false                                             | No       | false                          |
| `role_assignment_mode`                             | LegacyRegistryPermissions,AbacRepositoryPermissions    | No       | "LegacyRegistryPermissions"    |
| `user_identity_isolation_scope`                    | "Regional"                                             | No       | null                           |
| `skip_service_principal_aad_check`                 | true,false                                             | No       | false                          |

> `trust_policy_enabled` was removed in azurerm >= 5.0 (Docker Content Trust retired) and is no longer honored if present in tfvars.

#### Network_rule_set Block

| Parameter Name   | Possible Values | Required | Default |
| ---------------- | --------------- | -------- | ------- |
| `default_action` | Allow,Deny      | No       | "Deny"  |

#### ip_rule Block (within network_rule_set)

| Parameter Name | Possible Values | Required | Default |
| -------------- | --------------- | -------- | ------- |
| `action`       | Allow           | Yes      | n/a     |
| `ip_range`     | CIDR block      | Yes      | n/a     |

#### identity Block

| Parameter Name | Possible Values             | Required | Default |
| -------------- | --------------------------- | -------- | ------- |
| `type`         | SystemAssigned,UserAssigned | Yes      | n/a     |
| `identity_ids` | list of ID                  | No       | []      |

#### Encryption Block

| Parameter Name       | Possible Values | Required | Default |
| -------------------- | --------------- | -------- | ------- |
| `key_vault_key_id`   | ID              | Yes      | n/a     |
| `identity_client_id` | ID              | Yes      | n/a     |

#### georeplications Block (single object or list of objects)

| Parameter Name                     | Possible Values | Required | Default      |
| ------------------------------------ | --------------- | -------- | ------------ |
| `location`                           | Azure location  | No       | "canadaeast" |
| `global_endpoint_routing_enabled`    | true,false      | No       | true (falls back to legacy `regional_endpoint_enabled` if set) |
| `zone_redundancy_enabled`            | true,false      | No       | false        |
| `tags`                               | map of string   | No       | {}           |
