##-----------------------------------------------------------------------------
## Naming convention
##-----------------------------------------------------------------------------
variable "custom_name" {
  type        = string
  default     = null
  description = "Define your custom name to override default naming convention"
}

variable "resource_position_prefix" {
  type        = bool
  default     = true
  description = <<EOT
Controls the placement of the resource type keyword (e.g., "vnet", "ddospp") in the resource name.

- If true, the keyword is prepended: "stor-core-dev".
- If false, the keyword is appended: "core-dev-stor".

This helps maintain naming consistency based on organizational preferences.
EOT
}

##-----------------------------------------------------------------------------
## Labels
##-----------------------------------------------------------------------------
variable "name" {
  type        = string
  default     = ""
  description = "Name  (e.g. `app` or `cluster`)."
}

variable "environment" {
  type        = string
  default     = ""
  description = "Environment (e.g. `prod`, `dev`, `staging`)."
}

variable "repository" {
  type        = string
  default     = "https://github.com/terraform-az-modules/terraform-azure-storage.git"
  description = "Terraform current module repo"
}

variable "label_order" {
  type        = list(any)
  default     = ["name", "environment", "location"]
  description = "The order of labels used to construct resource names or tags. If not specified, defaults to ['name', 'environment', 'location']."
}

variable "managedby" {
  type        = string
  default     = "terraform-az-modules"
  description = "ManagedBy, eg 'terraform-az-modules'."
}

variable "extra_tags" {
  type        = map(string)
  default     = null
  description = "Additional tags (e.g. map(`BusinessUnit`,`XYZ`)."
}

variable "deployment_mode" {
  type        = string
  default     = "terraform"
  description = "Specifies how the infrastructure/resource is deployed"
}

##-----------------------------------------------------------------------------
## Storage Account
##-----------------------------------------------------------------------------
variable "enabled" {
  type        = bool
  description = "Set to false to prevent the module from creating any resources."
  default     = true
}

variable "resource_group_name" {
  type        = string
  default     = ""
  description = "A container that holds related resources for an Azure solution"
}

variable "location" {
  type        = string
  default     = "North Europe"
  description = "The location/region to keep all your network resources. To get the list of all locations with table format from azure cli, run 'az account list-locations -o table'"
}

variable "account_tier" {
  type        = string
  default     = "Standard"
  description = "Defines the Tier to use for this storage account."
}

variable "access_tier" {
  type        = string
  default     = "Hot"
  description = "Defines the access tier for BlobStorage and StorageV2 accounts. Valid options are Hot and Cool."
}

variable "account_replication_type" {
  type        = string
  default     = "GRS"
  description = "Defines the type of replication to use for this storage account. Valid options are LRS, GRS, RAGRS, ZRS, GZRS and RAGZRS."
}

variable "enable_https_traffic_only" {
  type        = bool
  default     = true
  description = " Boolean flag which forces HTTPS if enabled, see here for more information."
}

variable "account_kind" {
  type        = string
  default     = "StorageV2"
  description = "The type of storage account. Valid options are BlobStorage, BlockBlobStorage, FileStorage, Storage and StorageV2."
}

variable "min_tls_version" {
  type        = string
  default     = "TLS1_2"
  description = "The minimum supported TLS version for the storage account"
}

variable "containers_list" {
  type        = list(object({ name = string, access_type = string }))
  default     = []
  description = "List of containers to create and their access levels."
}

variable "network_rules" {
  type = list(object({
    default_action             = string
    ip_rules                   = list(string)
    virtual_network_subnet_ids = optional(list(string), [])
    bypass                     = optional(list(string), [])
  }))
  default     = []
  description = "List of objects that represent the configuration of each network rule."
}

variable "table_encryption_key_type" {
  type        = string
  default     = "Account"
  description = "The encryption type of the table service. Possible values are 'Service' and 'Account'."
}

variable "queue_encryption_key_type" {
  type        = string
  default     = "Account"
  description = "The encryption type of the queue service. Possible values are 'Service' and 'Account'."
}

variable "large_file_share_enabled" {
  type        = bool
  default     = false
  description = "Is Large File Share Enabled?"
}

variable "nfsv3_enabled" {
  type        = bool
  default     = false
  description = "Is NFSv3 protocol enabled? Changing this forces a new resource to be created."
}

variable "edge_zone" {
  type        = string
  default     = null
  description = "Specifies the Edge Zone within the Azure Region where this Storage Account should exist."
}

variable "is_hns_enabled" {
  description = "Is Hierarchical Namespace enabled? This can be used with Azure Data Lake Storage Gen 2."
  type        = bool
  default     = false
}

variable "sftp_enabled" {
  description = "Boolean, enable SFTP for the storage account"
  type        = bool
  default     = false
}

variable "enable_advanced_threat_protection" {
  description = "Boolean flag which controls if advanced threat protection is enabled."
  default     = false
  type        = bool
}

variable "file_shares" {
  description = "List of containers to create and their access levels."
  type        = list(object({ name = string, quota = number }))
  default     = []
}

variable "tables" {
  description = "List of storage tables."
  type        = list(string)
  default     = []
}

variable "queues" {
  description = "List of storages queues"
  type        = list(string)
  default     = []
}

variable "management_policy" {
  description = "Configure Azure Storage firewalls and virtual networks"
  type = list(object({
    prefix_match                                                   = set(string)
    tier_to_cool_after_days                                        = number
    tier_to_archive_after_days                                     = number
    delete_after_days                                              = number
    auto_tier_to_hot_from_cool_enabled                             = bool
    delete_after_days_since_creation_greater_than                  = number
    delete_after_days_since_last_access_time_greater_than          = number
    delete_after_days_since_modification_greater_than              = number
    tier_to_archive_after_days_since_creation_greater_than         = number
    tier_to_archive_after_days_since_last_access_time_greater_than = number
    tier_to_archive_after_days_since_last_tier_change_greater_than = number
    tier_to_archive_after_days_since_modification_greater_than     = number
    tier_to_cold_after_days_since_creation_greater_than            = number
    tier_to_cold_after_days_since_last_access_time_greater_than    = number
    tier_to_cool_after_days_since_modification_greater_than        = number
    tier_to_cool_after_days_since_creation_greater_than            = number
    tier_to_cool_after_days_since_last_access_time_greater_than    = number
    snapshot_delete_after_days                                     = number
  }))
  default = [{
    prefix_match                                                   = null
    tier_to_cool_after_days                                        = 0,
    tier_to_archive_after_days                                     = 50,
    delete_after_days                                              = 100,
    snapshot_delete_after_days                                     = 30,
    auto_tier_to_hot_from_cool_enabled                             = "true",
    delete_after_days_since_creation_greater_than                  = 60,
    delete_after_days_since_last_access_time_greater_than          = 30,
    delete_after_days_since_modification_greater_than              = 365,
    tier_to_archive_after_days_since_creation_greater_than         = 60,
    tier_to_archive_after_days_since_last_access_time_greater_than = 30,
    tier_to_archive_after_days_since_last_tier_change_greater_than = 60,
    tier_to_archive_after_days_since_modification_greater_than     = 90,
    tier_to_cold_after_days_since_creation_greater_than            = 90,
    tier_to_cold_after_days_since_last_access_time_greater_than    = 60,
    tier_to_cool_after_days_since_modification_greater_than        = 30,
    tier_to_cool_after_days_since_creation_greater_than            = 60,
    tier_to_cool_after_days_since_last_access_time_greater_than    = 60

  }]
}

##-----------------------------------------------------------------------------
## Static Website
##-----------------------------------------------------------------------------
variable "static_website_config" {
  type = object({
    index_document     = optional(string)
    error_404_document = optional(string)
  })
  default     = null
  description = "Static website configuration. Can only be set when the `account_kind` is set to `StorageV2` or `BlockBlobStorage`."
}

##-----------------------------------------------------------------------------
## Queue Property Logging
##-----------------------------------------------------------------------------
variable "queue_properties_logging" {
  description = "Logging queue properties"
  type = object({
    delete                = optional(bool)
    read                  = optional(bool)
    write                 = optional(bool)
    version               = optional(string)
    retention_policy_days = optional(number)
  })
  default = {
    delete                = true
    read                  = true
    write                 = true
    version               = "1.0"
    retention_policy_days = 7
  }
}

variable "enable_queue_properties" {
  type        = bool
  default     = true
  description = "Enable or disable the creation of the queue properties"
}

##-----------------------------------------------------------------------------
## Routing
##-----------------------------------------------------------------------------
variable "enable_routing" {
  type        = bool
  default     = false
  description = "Enable or disable the creation of the routing block."
}

variable "routing" {
  type = list(object({
    publish_internet_endpoints  = bool
    publish_microsoft_endpoints = bool
    choice                      = string
  }))
  default = [
    {
      publish_internet_endpoints  = false
      publish_microsoft_endpoints = false
      choice                      = "MicrosoftRouting"
    }
  ]
}

##-----------------------------------------------------------------------------
## Share Properties
##-----------------------------------------------------------------------------
variable "enable_file_share_cors_rules" {
  type        = bool
  default     = false
  description = "Whether or not enable file share cors rules. "
}

variable "file_share_cors_rules" {
  type = list(object({
    allowed_headers    = list(string)
    allowed_methods    = list(string)
    allowed_origins    = list(string)
    exposed_headers    = list(string)
    max_age_in_seconds = number
  }))
  default     = null
  description = "Storage Account file shares CORS rule."
}

variable "file_share_retention_policy_in_days" {
  type        = number
  default     = null
  description = "Storage Account file shares retention policy in days."
}

variable "file_share_properties_smb" {
  type = object({
    versions                        = optional(list(string))
    authentication_types            = optional(list(string))
    kerberos_ticket_encryption_type = optional(list(string))
    channel_encryption_type         = optional(list(string))
    multichannel_enabled            = optional(bool)
  })
  default     = null
  description = "Storage Account file shares smb properties."
}

##-----------------------------------------------------------------------------
## Custom Domain
##-----------------------------------------------------------------------------
variable "custom_domain_name" {
  type        = string
  default     = null
  description = "The Custom Domain Name to use for the Storage Account, which will be validated by Azure."
}

variable "use_subdomain" {
  type        = bool
  default     = false
  description = "Should the Custom Domain Name be validated by using indirect CNAME validation?"
}

##-----------------------------------------------------------------------------
## Identity
##-----------------------------------------------------------------------------
variable "identity_type" {
  description = "Specifies the type of Managed Service Identity that should be configured on this Storage Account. Possible values are `SystemAssigned`, `UserAssigned`, `SystemAssigned, UserAssigned` (to enable both)."
  type        = string
  default     = "UserAssigned"
}

variable "key_vault_id" {
  type    = string
  default = ""
}

variable "expiration_date" {
  type        = string
  default     = "2034-10-22T18:29:59Z"
  description = "Expiration UTC datetime (Y-m-d'T'H:M:S'Z')"
}

variable "shared_access_key_enabled" {
  type        = bool
  default     = false
  description = " Indicates whether the storage account permits requests to be authorized with the account access key via Shared Key. If false, then all requests, including shared access signatures, must be authorized with Azure Active Directory (Azure AD). The default value is true."
}
variable "infrastructure_encryption_enabled" {
  type        = bool
  default     = true
  description = " Is infrastructure encryption enabled? Changing this forces a new resource to be created. Defaults to false."
}
variable "public_network_access_enabled" {
  type        = bool
  default     = true
  description = "Whether the public network access is enabled? Defaults to true."
}
variable "default_to_oauth_authentication" {
  type        = bool
  default     = false
  description = "Default to Azure Active Directory authorization in the Azure portal when accessing the Storage Account. The default value is false"
}
variable "cross_tenant_replication_enabled" {
  type        = bool
  default     = true
  description = "Should cross Tenant replication be enabled? Defaults to true."
}
variable "allow_nested_items_to_be_public" {
  type        = bool
  default     = false
  description = "Allow or disallow nested items within this Account to opt into being public. Defaults to true."
}

variable "allowed_copy_scope" {
  type        = string
  default     = "PrivateLink"
  description = "Restrict copy to and from Storage Accounts within an AAD tenant or with Private Links to the same VNet. Possible values are AAD and PrivateLink."
}

variable "admin_objects_ids" {
  description = "IDs of the objects that can do all operations on all keys, secrets and certificates."
  type        = list(string)
  default     = []
}

##-----------------------------------------------------------------------------
## Private Endpoints
##-----------------------------------------------------------------------------
variable "enable_private_endpoint" {
  type        = bool
  default     = false
  description = "enable or disable private endpoint to storage account"
}

variable "subnet_id" {
  type        = string
  default     = ""
  description = "The resource ID of the subnet"
}

variable "private_dns_zone_ids" {
  description = "The IDs of a private DNS zone."
  type        = string
  default     = null
}

##-----------------------------------------------------------------------------
## Data Protection 
##-----------------------------------------------------------------------------
variable "storage_blob_data_protection" {
  description = "Storage account blob Data protection parameters."
  type = object({
    change_feed_enabled                       = optional(bool, false)
    versioning_enabled                        = optional(bool, false)
    last_access_time_enabled                  = optional(bool, false)
    delete_retention_policy_in_days           = optional(number, 0)
    container_delete_retention_policy_in_days = optional(number, 0)
    container_point_in_time_restore           = optional(bool, false)
  })
  default = {
    change_feed_enabled                       = false
    last_access_time_enabled                  = false
    versioning_enabled                        = false
    delete_retention_policy_in_days           = 7
    container_delete_retention_policy_in_days = 7
  }
}

variable "storage_blob_cors_rule" {
  description = "Storage Account blob CORS rule. Please refer to the [documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account#cors_rule) for more information."
  type = object({
    allowed_headers    = list(string)
    allowed_methods    = list(string)
    allowed_origins    = list(string)
    exposed_headers    = list(string)
    max_age_in_seconds = number
  })
  default = null
}

variable "restore_policy" {
  type        = bool
  default     = false
  description = "Wheteher or not create restore policy"
}

# Minute Metrics
variable "enable_minute_metrics" {
  type        = bool
  default     = false
  description = "Enable or disable the creation of the minute_metrics block."
}

variable "minute_metrics" {
  type = list(object({
    enabled               = bool
    version               = string
    include_apis          = bool
    retention_policy_days = number
  }))
  default = [
    {
      enabled               = false
      version               = ""
      include_apis          = false
      retention_policy_days = 7
    }
  ]
}

variable "enable_hour_metrics" {
  type        = bool
  default     = false
  description = "Enable or disable the creation of the hour_metrics block."
}

variable "hour_metrics" {
  type = object({
    enabled               = bool
    version               = string
    include_apis          = bool
    retention_policy_days = number
  })
  default = {
    enabled               = false
    version               = ""
    include_apis          = false
    retention_policy_days = 7
  }
}

##-----------------------------------------------------------------------------
## File Share Authentication
##-----------------------------------------------------------------------------
variable "file_share_authentication" {
  description = "Storage Account file shares authentication configuration."
  type = object({
    directory_type                 = string
    default_share_level_permission = optional(string, "None")
    active_directory = optional(object({
      storage_sid         = optional(string)
      domain_name         = string
      domain_sid          = optional(string)
      domain_guid         = optional(string)
      forest_name         = optional(string)
      netbios_domain_name = optional(string)
    }))
  })
  default = null

  validation {
    condition = var.file_share_authentication == null || (
      contains(["AADDS", "AD", ""], try(var.file_share_authentication.directory_type, ""))
    )
    error_message = "`file_share_authentication.directory_type` can only be `AADDS` or `AD`."
  }
  validation {
    condition = var.file_share_authentication == null || (
      try(var.file_share_authentication.directory_type, null) == "AADDS" || (
        try(var.file_share_authentication.directory_type, null) == "AD" &&
        try(var.file_share_authentication.active_directory, null) != null
      )
    )
    error_message = "`file_share_authentication.active_directory` block is required when `file_share_authentication.directory_type` is set to `AD`."
  }
}

##-----------------------------------------------------------------------------
## Private Link Access
##-----------------------------------------------------------------------------
variable "enable_private_link_access" {
  type        = bool
  default     = false
  description = "Enable or disable the creation of the private_link_access."
}

variable "private_link_access" {
  description = "List of Privatelink objects to allow access from."
  type = list(object({
    endpoint_resource_id = string
    endpoint_tenant_id   = string
  }))
  default = []
}

##-----------------------------------------------------------------------------
## SAS Policy
##-----------------------------------------------------------------------------
variable "enable_sas_policy" {
  description = "Enable or disable the creation of the sas_policy block."
  type        = bool
  default     = false
}

variable "sas_policy_settings" {
  type = list(object({
    expiration_period = string
    expiration_action = string
  }))
  default = [
    {
      expiration_period = "7.00:00:00"
      expiration_action = "Log"
    }
  ]
}

##-----------------------------------------------------------------------------
## Diagnosis Settings Enable
##-----------------------------------------------------------------------------
variable "enable_diagnostic" {
  type        = bool
  default     = false
  description = "Set to false to prevent the module from creating the diagnosys setting for the NSG Resource.."
}

variable "storage_account_id" {
  type        = string
  default     = null
  description = "Storage account id to pass it to destination details of diagnosys setting of NSG."
}

variable "eventhub_name" {
  type        = string
  default     = null
  description = "Eventhub Name to pass it to destination details of diagnosys setting of NSG."
}

variable "eventhub_authorization_rule_id" {
  type        = string
  default     = null
  description = "Eventhub authorization rule id to pass it to destination details of diagnosys setting of NSG."
}

variable "log_analytics_workspace_id" {
  type        = string
  default     = null
  description = "log analytics workspace id to pass it to destination details of diagnosys setting of NSG."
}

variable "metrics" {
  type    = list(string)
  default = ["Transaction", "Capacity"]
}

variable "metrics_enabled" {
  type    = list(bool)
  default = [true, true]
}

variable "logs" {
  type    = list(string)
  default = ["StorageWrite", "StorageRead", "StorageDelete"]
}

variable "datastorages" {
  type    = list(string)
  default = ["blob", "queue", "table", "file"]
}

variable "alias_sub" {
  type    = string
  default = null
}

variable "management_policy_enable" {
  type    = bool
  default = false
}

variable "log_analytics_destination_type" {
  type        = string
  default     = "AzureDiagnostics"
  description = "Possible values are AzureDiagnostics and Dedicated, default to AzureDiagnostics. When set to Dedicated, logs sent to a Log Analytics workspace will go into resource specific tables, instead of the legacy AzureDiagnostics table."
}

variable "Metric_enable" {
  type        = bool
  default     = true
  description = "Is this Diagnostic Metric enabled? Defaults to true."
}

variable "key_vault_rbac_auth_enabled" {
  type        = bool
  default     = true
  description = "Specifies whether Role-Based Access Control (RBAC) is enabled for the Key Vault."
}

variable "cmk_encryption_enabled" {
  type        = bool
  default     = false
  description = "Whether to create CMK or not"
}

variable "rotation_policy_enabled" {
  type        = bool
  default     = false
  description = "Whether or not to enable rotation policy"
}

variable "rotation_policy" {
  type = map(object({
    time_before_expiry   = string
    expire_after         = string
    notify_before_expiry = string
  }))
  default = null
}

##-----------------------------------------------------------------------------
## Diagnostic Settings for Individual Storage Services
##-----------------------------------------------------------------------------
# Enable flags per service
variable "enable_blob_diagnostics" {
  type        = bool
  default     = false
  description = "Enable diagnostic settings for Blob service."
}

variable "enable_table_diagnostics" {
  type        = bool
  default     = false
  description = "Enable diagnostic settings for Table service."
}

variable "enable_queue_diagnostics" {
  type        = bool
  default     = false
  description = "Enable diagnostic settings for Queue service."
}

variable "enable_file_diagnostics" {
  type        = bool
  default     = false
  description = "Enable diagnostic settings for File service."
}

# Log categories per service
variable "blob_logs" {
  type        = list(string)
  default     = ["StorageRead", "StorageWrite", "StorageDelete"]
  description = "Log categories for Blob service diagnostics."
}

variable "table_logs" {
  type        = list(string)
  default     = ["StorageRead", "StorageWrite", "StorageDelete"]
  description = "Log categories for Table service diagnostics."
}

variable "queue_logs" {
  type        = list(string)
  default     = ["StorageRead", "StorageWrite", "StorageDelete"]
  description = "Log categories for Queue service diagnostics."
}

variable "file_logs" {
  type        = list(string)
  default     = ["StorageRead", "StorageWrite", "StorageDelete"]
  description = "Log categories for File service diagnostics."
}

# Metric categories per service
variable "blob_metrics" {
  type        = list(string)
  default     = ["Transaction", "Capacity"]
  description = "Metric categories for Blob service diagnostics."
}

variable "table_metrics" {
  type        = list(string)
  default     = ["Transaction", "Capacity"]
  description = "Metric categories for Table service diagnostics."
}

variable "queue_metrics" {
  type        = list(string)
  default     = ["Transaction", "Capacity"]
  description = "Metric categories for Queue service diagnostics."
}

variable "file_metrics" {
  type        = list(string)
  default     = ["Transaction", "Capacity"]
  description = "Metric categories for File service diagnostics."
}
