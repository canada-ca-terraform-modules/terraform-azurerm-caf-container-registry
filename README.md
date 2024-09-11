## Requirements

No requirements.

## Providers

| Name    | Version |
| ------- | ------- |
| azurerm | n/a     |

## Inputs

| Name                    | Description                                                   | Type          | Default           | Required |
| ----------------------- | ------------------------------------------------------------- | ------------- | ----------------- | :------: |
| container\_registry     | Object container all container registry parameters            | `any`         | `{}`              |    no    |
| env                     | (Required) Env part of the name for the registry              | `string`      | n/a               |   yes    |
| group                   | (Required) Group part of the name for the registry            | `string`      | n/a               |   yes    |
| location                | Azure location where the registry will be located             | `string`      | `"canadacentral"` |    no    |
| private\_dns\_zone\_ids | Object containing private DNS zone Ids for the subscription   | `any`         | `{}`              |    no    |
| project                 | (Required) Project part of the name for the registry          | `string`      | n/a               |   yes    |
| resource\_groups        | Resource group object containing all resource groups          | `any`         | `{}`              |    no    |
| subnets                 | Object containing all subnets in the project                  | `any`         | `{}`              |    no    |
| tags                    | Tags to be applied to the registry                            | `map(string)` | `{}`              |    no    |
| userDefinedString       | (Required) UserDefinedString part of the name of the registry | `string`      | n/a               |   yes    |

## Outputs

| Name                      | Description                                  |
| ------------------------- | -------------------------------------------- |
| container-registry-object | Returns the entire container registry object |
| id                        | Returns the ID of the container registry     |
| name                      | Returns the name of the container registry   |

## User Assigned Identity

An option user_identity_enabled can be configured to create a user assigned identity with the AcrPull role assigned. This identity is used by the ACI to connect to the ACR and pull container images. 
It is enabled by default. 

## TFVARS Parameters

| Parameter Name                  | Possible Values        | Required | Default         |
| ------------------------------- | ---------------------- | -------- | --------------- |
| `name`                          | string                 | Yes      | n/a             |
| `sku`                           | Basic,Standard,Premium | No       | "Premium"       |
| `admin_enabled`                 | true,false             | No       | false           |
| `public_network_access_enabled` | true,false             | No       | false           |
| `quarantine_policy_enabled`     | true,false             | No       | null            |
| `retention_policy_in_days`      | int                    | No       | 90              |
| `trust_policy_enabled`          | true,false             | No       | false           |
| `zone_redundancy_enabled`       | true,false             | No       | true            |
| `export_policy_enabled`         | true,false             | No       | true            |
| `anonymous_pull_enabled`        | true,false             | No       | false           |
| `data_endpoint_enabled`         | true,false             | No       | null            |
| `network_rule_bypass_option`    | string                 | No       | "AzureServices" |

#### Network_rule_set Block

| Parameter Name   | Possible Values | Required | Default |
| ---------------- | --------------- | -------- | ------- |
| `default_action` | Allow,Deny      | Yes      | "Deny"  |

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

#### georeplications Block

| Parameter Name              | Possible Values | Required | Default      |
| --------------------------- | --------------- | -------- | ------------ |
| `location`                  | Azure location  | No       | "canadaeast" |
| `regional_endpoint_enabled` | true,false      | No       | null         |
| `zone_redundancy_enabled`   | true,false      | No       | false        |
| `tags`                      | map of string   | No       | {}           |
