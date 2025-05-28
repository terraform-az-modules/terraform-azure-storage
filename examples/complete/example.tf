provider "azurerm" {
  features {}
  storage_use_azuread = true
}

provider "azurerm" {
  features {}
  alias           = "peer"
}

data "azurerm_client_config" "current_client_config" {}

##----------------------------------------------------------------------------- 
## Resource Group module call
##-----------------------------------------------------------------------------
module "resource_group" {
  source      = "clouddrove/resource-group/azure"
  version     = "1.0.2"
  name        = "app1"
  environment = "test"
  location    = "North Europe"
}

##----------------------------------------------------------------------------- 
## Virtual Network module call.
##-----------------------------------------------------------------------------
module "vnet" {
  source              = "clouddrove/vnet/azure"
  version             = "1.0.4"
  name                = "app1"
  environment         = "test"
  label_order         = ["name", "environment"]
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  address_spaces      = ["10.0.0.0/16"]
}

##----------------------------------------------------------------------------- 
## Subnet module call.
##-----------------------------------------------------------------------------
module "subnet" {
  source               = "clouddrove/subnet/azure"
  version              = "1.2.0"
  name                 = "app1"
  environment          = "test"
  label_order          = ["name", "environment"]
  resource_group_name  = module.resource_group.resource_group_name
  location             = module.resource_group.resource_group_location
  virtual_network_name = module.vnet.vnet_name
  service_endpoints    = ["Microsoft.Storage"]
  subnet_names    = ["subnet1"]
  subnet_prefixes = ["10.0.1.0/24"]
}

##----------------------------------------------------------------------------- 
## Log Analytics module call.
##-----------------------------------------------------------------------------
module "log-analytics" {
  source                           = "clouddrove/log-analytics/azure"
  version                          = "2.0.0"
  name                             = "app1"
  environment                      = "test"
  label_order                      = ["name", "environment"]
  create_log_analytics_workspace   = true # Set  it 'false' if you don't want resource log-analytics workspace to be created
  log_analytics_workspace_sku      = "PerGB2018"
  daily_quota_gb                   = "-1"
  internet_ingestion_enabled       = true
  internet_query_enabled           = true
  resource_group_name              = module.resource_group.resource_group_name
  log_analytics_workspace_location = module.resource_group.resource_group_location
  storage_account_id               = module.storage.storage_account_id
  diagnostic_setting_enable        = true # Set it 'true' if you want azurerm_monitor_diagnostic_setting to be enabled

}

##----------------------------------------------------------------------------- 
## Key Vault module call.
##-----------------------------------------------------------------------------
module "vault" {
  providers = {
    azurerm.main_sub = azurerm
    azurerm.dns_sub  = azurerm.peer
  }

  source                      = "github.com/clouddrove/terraform-azure-key-vault.git?ref=master"
  name                        = "vae59605811"
  environment                 = "test"
  label_order                 = ["name", "environment"]
  resource_group_name         = module.resource_group.resource_group_name
  location                    = module.resource_group.resource_group_location
  admin_objects_ids           = [data.azurerm_client_config.current_client_config.object_id]
  virtual_network_id          = module.vnet.vnet_id
  subnet_id                   = module.subnet.default_subnet_id[0]
  enable_rbac_authorization   = true
  enabled_for_disk_encryption = false

  ## Private endpoint
  enable_private_endpoint = true
  network_acls            = null

  ## enable diagnostic setting
  diagnostic_setting_enable  = true
  log_analytics_workspace_id = module.log-analytics.workspace_id
}

##----------------------------------------------------------------------------- 
## Storage module call.
##-----------------------------------------------------------------------------
module "storage" {
  providers = {
    azurerm.main_sub = azurerm
  }
  source                        = "../.."
  name                          = "core"
  environment                   = "dev"
  label_order                   = ["name", "environment", "location"]
  resource_group_name           = module.resource_group.resource_group_name
  location                      = module.resource_group.resource_group_location
  public_network_access_enabled = true
  account_kind                  = "StorageV2"
  account_tier                  = "Standard"
  admin_objects_ids             = [data.azurerm_client_config.current_client_config.object_id]
  network_rules = [
    {
      default_action             = "Allow"
      ip_rules                   = ["0.0.0.0/0"]
      virtual_network_subnet_ids = []
      bypass                     = ["AzureServices"]
  }]

  ## customer_managed_key can only be set when the account_kind is set to StorageV2 or account_tier set to Premium, and the identity type is UserAssigned.
  cmk_encryption_enabled       = true
  key_vault_id                 = module.vault.id
  management_policy_enable     = true

  ##   Storage Container
  containers_list = [
    { name = "app-test", access_type = "private" },
  ]
  tables = ["table1"]
  queues = ["queue1"]
  file_shares = [
    { name = "fileshare", quota = "10" },
  ]

  log_analytics_workspace_id = module.log-analytics.workspace_id
}
