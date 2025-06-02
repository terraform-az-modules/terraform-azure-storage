##-----------------------------------------------------------------------------
## Tagging Module – Applies standard tags to all resources
##-----------------------------------------------------------------------------
module "labels" {
  source          = "terraform-az-modules/tags/azure"
  version         = "1.0.0"
  name            = var.custom_name == null ? var.name : var.custom_name
  location        = var.location
  environment     = var.environment
  managedby       = var.managedby
  label_order     = var.label_order
  repository      = var.repository
  deployment_mode = var.deployment_mode
  extra_tags      = var.extra_tags
}

##-----------------------------------------------------------------------------------------------------
## Storage Account - Create a Storage account with custormer managed key encryption and its components.  
##-----------------------------------------------------------------------------------------------------
resource "azurerm_storage_account" "storage" {
  provider                          = azurerm.main_sub
  count                             = var.enabled ? 1 : 0
  name = substr(lower(replace(replace(var.resource_position_prefix ? format("ast%s", local.name) : format("%sast", local.name), "-", ""), " ", "")), 0, 24)
  resource_group_name               = var.resource_group_name
  location                          = var.location
  account_kind                      = var.account_kind
  account_tier                      = var.account_tier
  access_tier                       = var.access_tier
  account_replication_type          = var.account_replication_type
  https_traffic_only_enabled        = var.enable_https_traffic_only
  min_tls_version                   = var.min_tls_version
  is_hns_enabled                    = var.is_hns_enabled
  sftp_enabled                      = var.sftp_enabled
  shared_access_key_enabled         = var.shared_access_key_enabled
  public_network_access_enabled     = var.public_network_access_enabled
  infrastructure_encryption_enabled = var.infrastructure_encryption_enabled
  default_to_oauth_authentication   = var.default_to_oauth_authentication
  cross_tenant_replication_enabled  = var.cross_tenant_replication_enabled
  allow_nested_items_to_be_public   = var.allow_nested_items_to_be_public
  large_file_share_enabled          = var.large_file_share_enabled
  edge_zone                         = var.edge_zone
  nfsv3_enabled                     = var.nfsv3_enabled
  table_encryption_key_type         = var.table_encryption_key_type
  queue_encryption_key_type         = var.queue_encryption_key_type
  allowed_copy_scope                = var.allowed_copy_scope
  tags                              = module.labels.tags

  dynamic "blob_properties" {
    for_each = (
      var.account_kind != "FileStorage" && (var.storage_blob_data_protection != null || var.storage_blob_cors_rule != null) ? [1] : []
    )
    content {
      change_feed_enabled      = var.nfsv3_enabled || var.sftp_enabled ? false : var.storage_blob_data_protection.change_feed_enabled
      versioning_enabled       = var.nfsv3_enabled || var.sftp_enabled ? false : var.storage_blob_data_protection.versioning_enabled
      last_access_time_enabled = var.nfsv3_enabled || var.sftp_enabled ? false : var.storage_blob_data_protection.last_access_time_enabled

      dynamic "cors_rule" {
        for_each = var.storage_blob_cors_rule != null ? [1] : []
        content {
          allowed_headers    = var.storage_blob_cors_rule.allowed_headers
          allowed_methods    = var.storage_blob_cors_rule.allowed_methods
          allowed_origins    = var.storage_blob_cors_rule.allowed_origins
          exposed_headers    = var.storage_blob_cors_rule.exposed_headers
          max_age_in_seconds = var.storage_blob_cors_rule.max_age_in_seconds
        }
      }

      dynamic "delete_retention_policy" {
        for_each = var.storage_blob_data_protection.delete_retention_policy_in_days > 0 ? [1] : []
        content {
          days = var.storage_blob_data_protection.delete_retention_policy_in_days
        }
      }

      dynamic "container_delete_retention_policy" {
        for_each = var.storage_blob_data_protection.container_delete_retention_policy_in_days > 0 ? [1] : []
        content {
          days = var.storage_blob_data_protection.container_delete_retention_policy_in_days
        }
      }

      dynamic "restore_policy" {
        for_each = var.restore_policy ? [1] : []
        content {
          days = var.storage_blob_data_protection.container_delete_retention_policy_in_days - 1
        }
      }
    }
  }

  dynamic "sas_policy" {
    for_each = var.enable_sas_policy ? var.sas_policy_settings : []
    content {
      expiration_period = sas_policy.value.expiration_period
      expiration_action = sas_policy.value.expiration_action
    }
  }

  dynamic "custom_domain" {
    for_each = var.custom_domain_name != null ? [1] : []
    content {
      name          = var.custom_domain_name
      use_subdomain = var.use_subdomain
    }
  }

  dynamic "static_website" {
    for_each = var.static_website_config != null ? [1] : []
    content {
      index_document     = var.static_website_config.index_document
      error_404_document = var.static_website_config.error_404_document
    }
  }

  dynamic "azure_files_authentication" {
    for_each = var.file_share_authentication != null ? [1] : []
    content {
      directory_type                 = var.file_share_authentication.directory_type
      default_share_level_permission = var.file_share_authentication.default_share_level_permission

      dynamic "active_directory" {
        for_each = var.file_share_authentication.directory_type == "AD" ? [var.file_share_authentication.active_directory] : []
        iterator = ad
        content {
          storage_sid         = ad.value.storage_sid
          domain_name         = ad.value.domain_name
          domain_sid          = ad.value.domain_sid
          domain_guid         = ad.value.domain_guid
          forest_name         = ad.value.forest_name
          netbios_domain_name = ad.value.netbios_domain_name
        }
      }
    }
  }

  dynamic "routing" {
    for_each = var.enable_routing ? var.routing : []
    content {
      publish_internet_endpoints  = routing.value.publish_internet_endpoints
      publish_microsoft_endpoints = routing.value.publish_microsoft_endpoints
      choice                      = routing.value.choice
    }
  }

  dynamic "share_properties" {
    for_each = var.file_share_cors_rules != null && var.file_share_retention_policy_in_days != null && var.file_share_properties_smb != null ? [1] : []
    content {
      dynamic "cors_rule" {
        for_each = var.enable_file_share_cors_rules ? var.file_share_cors_rules : []
        content {
          allowed_headers    = file_share_cors_rules.value.allowed_headers
          allowed_methods    = file_share_cors_rules.value.allowed_methods
          allowed_origins    = file_share_cors_rules.value.allowed_origins
          exposed_headers    = file_share_cors_rules.value.exposed_headers
          max_age_in_seconds = file_share_cors_rules.value.max_age_in_seconds
        }
      }

      dynamic "retention_policy" {
        for_each = var.file_share_retention_policy_in_days != null ? [1] : []
        content {
          days = var.file_share_retention_policy_in_days
        }
      }

      dynamic "smb" {
        for_each = var.file_share_properties_smb != null ? [1] : []
        content {
          authentication_types            = var.file_share_properties_smb.authentication_types
          channel_encryption_type         = var.file_share_properties_smb.channel_encryption_type
          kerberos_ticket_encryption_type = var.file_share_properties_smb.kerberos_ticket_encryption_type
          versions                        = var.file_share_properties_smb.versions
          multichannel_enabled            = var.file_share_properties_smb.multichannel_enabled
        }
      }
    }
  }

  dynamic "identity" {
    for_each = var.cmk_encryption_enabled && var.identity_type != null ? [1] : []
    content {
      type         = var.identity_type
      identity_ids = var.identity_type == "UserAssigned" ? azurerm_user_assigned_identity.identity[*].id : null
    }
  }

  dynamic "customer_managed_key" {
    for_each = var.cmk_encryption_enabled ? [1] : []
    content {
      key_vault_key_id          = var.key_vault_id != null ? azurerm_key_vault_key.kvkey[0].id : null
      user_assigned_identity_id = var.key_vault_id != null ? azurerm_user_assigned_identity.identity[0].id : null
    }
  }
}

##----------------------------------------------------------------------------- 
## Queue Properties - Create a queue properties for storage account .
##-----------------------------------------------------------------------------
resource "azurerm_storage_account_queue_properties" "queue_properties" {
  count              = local.create_queue_properties ? 1 : 0
  storage_account_id = azurerm_storage_account.storage[0].id

  dynamic "logging" {
    for_each = var.queue_properties_logging != null && contains(["Storage", "StorageV2"], var.account_kind) ? [1] : []
    content {
      delete                = var.queue_properties_logging.delete
      read                  = var.queue_properties_logging.read
      write                 = var.queue_properties_logging.write
      version               = var.queue_properties_logging.version
      retention_policy_days = var.queue_properties_logging.retention_policy_days
    }
  }

  dynamic "hour_metrics" {
    for_each = var.enable_hour_metrics ? var.hour_metrics : {}
    content {
      include_apis          = hour_metrics.value.include_apis
      version               = hour_metrics.value.version
      retention_policy_days = hour_metrics.value.retention_policy_days
    }
  }

  dynamic "minute_metrics" {
    for_each = var.enable_minute_metrics ? toset(var.minute_metrics) : []
    content {
      version               = minute_metrics.value.version
      include_apis          = minute_metrics.value.include_apis
      retention_policy_days = minute_metrics.value.retention_policy_days
    }
  }
}

# ##----------------------------------------------------------------------------- 
# ## Key Vault - Creates a key vault that will be used for encryption.  
# ##-----------------------------------------------------------------------------
resource "azurerm_key_vault_key" "kvkey" {
  provider        = azurerm.main_sub
  depends_on      = [azurerm_role_assignment.identity_assigned, azurerm_role_assignment.rbac_keyvault_crypto_officer]
  count           = var.enabled && var.cmk_encryption_enabled ? 1 : 0
  name            = var.resource_position_prefix ? format("kvk-%s", local.name) : format("%s-kvk", local.name)
  expiration_date = var.expiration_date
  key_vault_id    = var.key_vault_id
  key_type        = "RSA-HSM"
  key_size        = 2048
  tags            = module.labels.tags
  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]

  dynamic "rotation_policy" {
    for_each = var.rotation_policy_enabled ? var.rotation_policy : {}
    content {
      automatic {
        time_before_expiry = rotation_policy.value.time_before_expiry
      }

      expire_after         = rotation_policy.value.expire_after
      notify_before_expiry = rotation_policy.value.notify_before_expiry
    }
  }
}

##--------------------------------------------------------------------------------------
## Network Rules - Creates network rules for controlling access and enhancing security.  
##--------------------------------------------------------------------------------------
resource "azurerm_storage_account_network_rules" "network-rules" {
  provider                   = azurerm.main_sub
  for_each                   = var.enabled ? { for rule in var.network_rules : rule.default_action => rule } : {}
  storage_account_id         = azurerm_storage_account.storage[0].id
  default_action             = lookup(each.value, "default_action", "Deny")
  ip_rules                   = lookup(each.value, "ip_rules", null)
  virtual_network_subnet_ids = lookup(each.value, "virtual_network_subnet_ids", null)
  bypass                     = lookup(each.value, "bypass", null)

  dynamic "private_link_access" {
    for_each = var.enable_private_link_access ? var.private_link_access : []
    content {
      endpoint_resource_id = private_link_access.value.endpoint_resource_id
      endpoint_tenant_id   = coalesce(private_link_access.value.endpoint_tenant_id, data.azuread_tenant.current_client_config.tenant_id)
    }
  }
}

##---------------------------------------------------------------------------------------------------------------------------
## Threat Protection - Create threat protection to detect and respond to suspicious or potentially malicious activities. 
##---------------------------------------------------------------------------------------------------------------------------
resource "azurerm_advanced_threat_protection" "atp" {
  provider           = azurerm.main_sub
  count              = local.create_advanced_threat_protection ? 1 : 0
  target_resource_id = azurerm_storage_account.storage[0].id
  enabled            = var.enable_advanced_threat_protection
}

##------------------------------------------------------------------------------------------------------------------------------------------
## Storage Container - Defines a container within the storage account to store blobs (objects) such as logs, data files, or media.
##------------------------------------------------------------------------------------------------------------------------------------------
resource "azurerm_storage_container" "container" {
  provider              = azurerm.main_sub
  count                 = var.enabled ? length(var.containers_list) : 0
  name                  = var.resource_position_prefix ? format("sc-%s", local.name) : format("%s-sc", local.name)
  storage_account_id    = azurerm_storage_account.storage[0].id
  container_access_type = var.containers_list[count.index].access_type
}

##---------------------------------------------------------------------------------------------------------
## Storage Share - Creates an Azure File Share within the storage account to support file-level storage 
## for lift-and-shift applications, legacy workloads, or shared storage needs.
##---------------------------------------------------------------------------------------------------------
resource "azurerm_storage_share" "fileshare" {
  provider           = azurerm.main_sub
  count              = var.enabled ? length(var.file_shares) : 0
  name               = var.resource_position_prefix ? format("ssf-%s", local.name) : format("%s-ssf", local.name)
  storage_account_id = azurerm_storage_account.storage[0].id
  quota              = var.file_shares[count.index].quota
}

##------------------------------------------------------------------------------------------------------ 
## Storage Table -  Creates an Azure Table within the storage account to provide a NoSQL key-value 
## store for structured, non-relational data.  
##------------------------------------------------------------------------------------------------------
resource "azurerm_storage_table" "tables" {
  provider             = azurerm.main_sub
  count                = var.enabled ? length(var.tables) : 0
  name                 = var.resource_position_prefix ? format("sta%s", replace(local.name, "-", "")) : format("%ssta", replace(local.name, "-", ""))
  storage_account_name = azurerm_storage_account.storage[0].name
}

##--------------------------------------------------------------------------------------------------------- 
## Storage Queue - Creates an Azure Storage Queue within the storage account to support asynchronous 
## message-based communication between application components.
##---------------------------------------------------------------------------------------------------------
resource "azurerm_storage_queue" "queues" {
  provider             = azurerm.main_sub
  count                = var.enabled ? length(var.queues) : 0
  name                 = var.resource_position_prefix ? format("sq-%s", local.name) : format("%s-sq", local.name)
  storage_account_name = azurerm_storage_account.storage[0].name
}

##-------------------------------------------------------------------------------------------------------
## Storage Management Policy - Defines lifecycle management rules for blob data within the storage 
## account, helping automate data retention, cost optimization, and compliance.  
##-------------------------------------------------------------------------------------------------------
resource "azurerm_storage_management_policy" "lifecycle_management" {
  provider           = azurerm.main_sub
  count              = local.create_storage_mgmt_policy ? length(var.management_policy) : 0
  storage_account_id = azurerm_storage_account.storage[0].id

  dynamic "rule" {
    for_each = var.management_policy
    iterator = it
    content {
      name    = "rule${it.key}"
      enabled = true
      filters {
        prefix_match = it.value.prefix_match
        blob_types   = ["blockBlob"]
      }
      actions {
        base_blob {
          tier_to_cool_after_days_since_modification_greater_than        = it.value.tier_to_cool_after_days
          tier_to_archive_after_days_since_modification_greater_than     = it.value.tier_to_archive_after_days
          delete_after_days_since_modification_greater_than              = it.value.delete_after_days
          auto_tier_to_hot_from_cool_enabled                             = it.value.auto_tier_to_hot_from_cool_enabled
          delete_after_days_since_creation_greater_than                  = it.value.delete_after_days_since_creation_greater_than
          delete_after_days_since_last_access_time_greater_than          = it.value.delete_after_days_since_last_access_time_greater_than
          tier_to_archive_after_days_since_creation_greater_than         = it.value.tier_to_archive_after_days_since_creation_greater_than
          tier_to_archive_after_days_since_last_tier_change_greater_than = it.value.tier_to_archive_after_days_since_last_tier_change_greater_than
          tier_to_archive_after_days_since_last_access_time_greater_than = it.value.tier_to_archive_after_days_since_last_access_time_greater_than
          tier_to_cold_after_days_since_creation_greater_than            = it.value.tier_to_cold_after_days_since_creation_greater_than
          tier_to_cold_after_days_since_last_access_time_greater_than    = it.value.tier_to_cold_after_days_since_last_access_time_greater_than
          tier_to_cool_after_days_since_creation_greater_than            = it.value.tier_to_cool_after_days_since_creation_greater_than
          tier_to_cool_after_days_since_last_access_time_greater_than    = it.value.tier_to_cool_after_days_since_last_access_time_greater_than

        }
        snapshot {
          delete_after_days_since_creation_greater_than                  = it.value.snapshot_delete_after_days
          tier_to_archive_after_days_since_last_tier_change_greater_than = it.value.tier_to_archive_after_days_since_last_tier_change_greater_than
          tier_to_cold_after_days_since_creation_greater_than            = it.value.tier_to_cold_after_days_since_creation_greater_than
        }
      }
    }
  }
}

##------------------------------------------------------------------------------------------------------------------------------------------
## Provider block
## To be used only when there is existing private dns zone in different subscription. Mention other subscription id in 'var.alias_sub'. 
##------------------------------------------------------------------------------------------------------------------------------------------
provider "azurerm" {
  alias = "peer"
  features {}
  subscription_id = var.alias_sub
}

##----------------------------------------------------------------------------- 
## Private Endpoint - Create private endpoint for storage account. 
##-----------------------------------------------------------------------------
resource "azurerm_private_endpoint" "pep" {
  provider            = azurerm.main_sub
  count               = var.enabled && var.enable_private_endpoint ? 1 : 0
  name                = var.resource_position_prefix ? format("pe-%s", local.name) : format("%s-pe", local.name)
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id
  tags                = module.labels.tags

  private_dns_zone_group {
    name                 = var.resource_position_prefix ? format("pdz-%s", local.name) : format("%s-pdz", local.name)
    private_dns_zone_ids = [var.private_dns_zone_ids]
  }

  private_service_connection {
    name                           = var.resource_position_prefix ? format("psc-%s", local.name) : format("%s-psc", local.name)
    is_manual_connection           = false
    private_connection_resource_id = azurerm_storage_account.storage[0].id
    subresource_names              = ["blob"]
  }
  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

##-----------------------------------------------------------------------------------------------------------------
## Monitor Diagnostic Setting - Configures diagnostic logging and monitoring for the Storage Account, sending
## logs and metrics to an Azure Monitor Log Analytics workspace, Event Hub, or Storage Account.
##-----------------------------------------------------------------------------------------------------------------
resource "azurerm_monitor_diagnostic_setting" "storage" {
  provider                       = azurerm.main_sub
  count                          = var.enabled && var.enable_diagnostic ? 1 : 0
  name                           = var.resource_position_prefix ? format("amds-%s", local.name) : format("%s-amds", local.name)
  target_resource_id             = azurerm_storage_account.storage[0].id
  storage_account_id             = var.storage_account_id
  eventhub_name                  = var.eventhub_name
  eventhub_authorization_rule_id = var.eventhub_authorization_rule_id
  log_analytics_workspace_id     = var.log_analytics_workspace_id

  dynamic "metric" {
    for_each = var.metrics
    content {
      category = metric.value
      enabled  = var.metrics_enabled[count.index]
    }
  }
}

##----------------------------------------------------------------------------- 
## Monitor Diagnostic Setting - Create diagnostic setting for storage Data. 
##-----------------------------------------------------------------------------
resource "azurerm_monitor_diagnostic_setting" "datastorage" {
  provider                       = azurerm.main_sub
  depends_on                     = [azurerm_storage_account.storage]
  count                          = local.create_monitor_diagnostic ? length(var.datastorages) : 0
  name                           = var.resource_position_prefix ? format("mdsd-%s", local.name) : format("%s-mdsd", local.name)
  storage_account_id             = var.storage_account_id
  target_resource_id             = "${azurerm_storage_account.storage[0].id}/${var.datastorages[count.index]}Services/default"
  eventhub_name                  = var.eventhub_name
  eventhub_authorization_rule_id = var.eventhub_authorization_rule_id
  log_analytics_workspace_id     = var.log_analytics_workspace_id

  dynamic "enabled_log" {
    for_each = var.logs
    content {
      category = enabled_log.value
    }
  }

  dynamic "metric" {
    for_each = var.metrics
    content {
      category = metric.value
      enabled  = true
    }
  }

}

##----------------------------------------------------------------------------- 
## Monitor Diagnostic Setting - Create diagnostic setting for storage-nic. 
##-----------------------------------------------------------------------------
resource "azurerm_monitor_diagnostic_setting" "storage-nic" {
  provider                       = azurerm.main_sub
  depends_on                     = [azurerm_private_endpoint.pep]
  count                          = local.create_monitor_diagnostic_nic ? 1 : 0
  name                           = var.resource_position_prefix ? format("mds-%s", local.name) : format("%s-mds", local.name)
  target_resource_id             = element(azurerm_private_endpoint.pep[count.index].network_interface[*].id, count.index)
  storage_account_id             = var.storage_account_id
  eventhub_name                  = var.eventhub_name
  eventhub_authorization_rule_id = var.eventhub_authorization_rule_id
  log_analytics_workspace_id     = var.log_analytics_workspace_id
  log_analytics_destination_type = var.log_analytics_destination_type
  metric {
    category = "AllMetrics"
    enabled  = var.Metric_enable
  }
  lifecycle {
    ignore_changes = [log_analytics_destination_type]
  }
}

##----------------------------------------------------------------------------- 
## Monitor Diagnostic Setting - Create diagnostic setting for storage blob. 
##-----------------------------------------------------------------------------
resource "azurerm_monitor_diagnostic_setting" "storage_blob" {
  provider                       = azurerm.main_sub
  count                          = var.enable_blob_diagnostics ? 1 : 0
  name                           = format("%s-blob-diagnostics", local.name)
  target_resource_id             = "${azurerm_storage_account.storage[0].id}/blobServices/default"
  storage_account_id             = var.storage_account_id
  eventhub_name                  = var.eventhub_name
  eventhub_authorization_rule_id = var.eventhub_authorization_rule_id
  log_analytics_workspace_id     = var.log_analytics_workspace_id

  dynamic "enabled_log" {
    for_each = var.blob_logs
    content {
      category = enabled_log.value
    }
  }

  dynamic "metric" {
    for_each = var.blob_metrics
    content {
      category = metric.value
      enabled  = true
    }
  }
}

##----------------------------------------------------------------------------- 
## Monitor Diagnostic Setting - Create diagnostic setting for storage table. 
##-----------------------------------------------------------------------------
resource "azurerm_monitor_diagnostic_setting" "storage_table" {
  provider                       = azurerm.main_sub
  count                          = var.enable_table_diagnostics ? 1 : 0
  name                           = format("%s-table-diagnostics", local.name)
  target_resource_id             = "${azurerm_storage_account.storage[0].id}/tableServices/default"
  storage_account_id             = var.storage_account_id
  eventhub_name                  = var.eventhub_name
  eventhub_authorization_rule_id = var.eventhub_authorization_rule_id
  log_analytics_workspace_id     = var.log_analytics_workspace_id

  dynamic "enabled_log" {
    for_each = var.table_logs
    content {
      category = enabled_log.value
    }
  }

  dynamic "metric" {
    for_each = var.table_metrics
    content {
      category = metric.value
      enabled  = true
    }
  }
}

##----------------------------------------------------------------------------- 
## Monitor Diagnostic Setting - Create diagnostic setting for storage queue. 
##-----------------------------------------------------------------------------
resource "azurerm_monitor_diagnostic_setting" "storage_queue" {
  provider                       = azurerm.main_sub
  count                          = var.enable_queue_diagnostics ? 1 : 0
  name                           = format("%s-queue-diagnostics", local.name)
  target_resource_id             = "${azurerm_storage_account.storage[0].id}/queueServices/default"
  storage_account_id             = var.storage_account_id
  eventhub_name                  = var.eventhub_name
  eventhub_authorization_rule_id = var.eventhub_authorization_rule_id
  log_analytics_workspace_id     = var.log_analytics_workspace_id

  dynamic "enabled_log" {
    for_each = var.queue_logs
    content {
      category = enabled_log.value
    }
  }

  dynamic "metric" {
    for_each = var.queue_metrics
    content {
      category = metric.value
      enabled  = true
    }
  }
}

##----------------------------------------------------------------------------- 
## Monitor Diagnostic Setting - Create diagnostic setting for storage file. 
##-----------------------------------------------------------------------------
resource "azurerm_monitor_diagnostic_setting" "storage_file" {
  provider                       = azurerm.main_sub
  count                          = var.enable_file_diagnostics ? 1 : 0
  name                           = format("%s-file-diagnostics", local.name)
  target_resource_id             = "${azurerm_storage_account.storage[0].id}/fileServices/default"
  storage_account_id             = var.storage_account_id
  eventhub_name                  = var.eventhub_name
  eventhub_authorization_rule_id = var.eventhub_authorization_rule_id
  log_analytics_workspace_id     = var.log_analytics_workspace_id

  dynamic "enabled_log" {
    for_each = var.file_logs
    content {
      category = enabled_log.value
    }
  }

  dynamic "metric" {
    for_each = var.file_metrics
    content {
      category = metric.value
      enabled  = true
    }
  }
}
