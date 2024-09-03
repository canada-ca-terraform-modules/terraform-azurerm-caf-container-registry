variable "tags" {
  description = "Tags to be applied to the registry"
  type = map(string)
  default = {}
}

variable "userDefinedString" {
  description = "(Required) UserDefinedString part of the name of the registry"
  type = string
}

variable "env" {
  description = "(Required) Env part of the name for the registry"
  type = string
}

variable "group" {
  description = "(Required) Group part of the name for the registry"
  type = string
}

variable "project" {
  description = "(Required) Project part of the name for the registry"
  type = string
}

variable "location" {
  description = "Azure location where the registry will be located"
  type = string
  default = "canadacentral"
}

variable "resource_groups" {
  description = "Resource group object containing all resource groups"
  type = any
  default = {}
}

variable "container_registry" {
  description = "Object container all container registry parameters"
  type = any
  default = {}
}

variable "subnets" {
  description = "Object containing all subnets in the project"
  type = any
  default = {}  
}

variable "private_dns_zone_ids" {
  description = "Object containing private DNS zone Ids for the subscription"
  type = any
  default = {}
}