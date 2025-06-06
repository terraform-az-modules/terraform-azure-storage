provider "azurerm" {
  features {}
  storage_use_azuread = true
}

provider "azurerm" {
  features {}
  alias = "peer"
}

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
##-----------------------------------------------------------------------------
module "storage" {
  providers = {
    azurerm.dns_sub  = azurerm.peer,
    azurerm.main_sub = azurerm
  }
  source                   = "../.."
  name                     = "app1"
  environment              = "test"
  label_order              = ["name", "environment", "location"]
  resource_group_name      = module.resource_group.resource_group_name
  location                 = "Central India"
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "GRS"
}
