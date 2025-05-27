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
  enable_rbac_authorization   = true
  enabled_for_disk_encryption = false
  enable_private_endpoint     = false

}

##----------------------------------------------------------------------------- 
## Storage module call.
## Here storage account will be deployed with CMK encryption. 
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
      default_action             = "Allow"
      ip_rules                   = ["0.0.0.0/0"]
      virtual_network_subnet_ids = []
      bypass                     = ["AzureServices"]
  }]

  ###customer_managed_key can only be set when the account_kind is set to StorageV2 or account_tier set to Premium, and the identity type is UserAssigned.
  cmk_encryption_enabled            = true
  key_vault_id                      = module.vault.id
  enable_queue_properties           = false
  enable_advanced_threat_protection = true
}
