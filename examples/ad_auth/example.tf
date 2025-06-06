provider "azurerm" {
  features {}
  storage_use_azuread = true
}

provider "azurerm" {
  features {}
  alias = "peer"
}

data "azurerm_client_config" "current_client_config" {}

##----------------------------------------------------------------------------- 
## Resource Group module call
##-----------------------------------------------------------------------------
module "resource_group" {
  source      = "terraform-az-modules/resource-group/azure"
  version     = "1.0.0"
  name        = "app1"
  environment = "test"
  location    = "northeurope"
}

##----------------------------------------------------------------------------- 
## Storage module call.
## Here storage account will be deployed with Active Directory Integration. 
##-----------------------------------------------------------------------------
module "storage" {
  providers = {
    azurerm.dns_sub  = azurerm.peer,
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
      default_action             = "Deny"
      ip_rules                   = ["0.0.0.0/0"]
      virtual_network_subnet_ids = []
      bypass                     = ["AzureServices"]
  }]

  file_share_authentication = {
    directory_type                 = "AADDS"
    default_share_level_permission = "StorageFileDataSmbShareContributor"
    active_directory = {
      storage_sid         = "S-1-5-21-1234567890-1234567890-1234567890-1234"
      domain_name         = "corp.example.com"
      domain_sid          = "S-1-5-21-234567890-234567890-234567890"
      domain_guid         = "12345678-1234-1234-1234-123456789abc"
      forest_name         = "example.com"
      netbios_domain_name = "EXAMPLE"
    }
  }

  ## Storage Container
  containers_list = [
    { name = "app-test", access_type = "private" },
  ]
  tables = ["table1"]
  queues = ["queue1"]
  file_shares = [
    { name = "fileshare", quota = "10" },
  ]
}
