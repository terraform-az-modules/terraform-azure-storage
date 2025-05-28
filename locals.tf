locals {
  name = var.custom_name != null ? var.custom_name : module.labels.id
  create_key_vault                  = var.enabled && var.key_vault_rbac_auth_enabled == false
  create_storage_mgmt_policy        = var.enabled && var.management_policy_enable && length(var.management_policy) > 0
  create_monitor_diagnostic         = var.enabled && var.enable_diagnostic && length(var.datastorages) > 0
  create_monitor_diagnostic_nic     = var.enabled && var.enable_diagnostic && var.enable_private_endpoint
  create_advanced_threat_protection = var.enabled && var.enable_advanced_threat_protection
  create_queue_properties           = var.enabled && var.enable_queue_properties && var.queue_properties_logging != null && contains(["Storage", "StorageV2"], var.account_kind)
}
