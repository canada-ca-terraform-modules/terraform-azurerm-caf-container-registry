variable "containerRegistry" {
  description = "Object container all the parameters for container registries"
  type = any
  default = {}
}

module "containerRegistry" {
  source = "/home/max/devops/modules/terraform-azurerm-caf-container-registry"
  for_each = var.containerRegistry

  userDefinedString = each.key
  env = var.env
  group = var.group
  project = var.project
  location = var.location
  resource_groups = local.resource_groups_all
  container_registry = each.value
  subnets = local.subnets
  private_dns_zone_ids = local.Project-dns-zone
  tags = var.tags
}