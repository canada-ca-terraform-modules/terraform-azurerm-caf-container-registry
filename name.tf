locals {
  # Dead locals removed: container_registry-regex, env-regex_compliant,
  # container_registry-userDefinedString-regex_compliant, group-regex_compliant,
  # project-regex_compliant were never referenced anywhere in the module.
  container_registry-name = "${var.env}CCR${var.userDefinedString}Registry"
}

