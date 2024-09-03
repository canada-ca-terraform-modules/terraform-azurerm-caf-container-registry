locals {
  container_registry-regex                             = "/[^0-9a-z]/"
  env-regex_compliant                                  = replace(var.env, local.container_registry-regex, "")
  container_registry-userDefinedString-regex_compliant = replace(var.userDefinedString, local.container_registry-regex, "")
  group-regex_compliant                                = replace(var.group, local.container_registry-regex, "")
  project-regex_compliant                              = replace(var.project, local.container_registry-regex, "")
  container_registry-name                              = "${var.env}CCR${var.userDefinedString}Registry"
}
