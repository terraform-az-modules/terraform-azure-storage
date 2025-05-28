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
  source      = "clouddrove/resource-group/azure"
  version     = "1.0.2"
  name        = "app1"
  environment = "test"
  location    = "North Europe"
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
  label_order              = ["name", "environment"]
  resource_group_name      = "test-rg"
  location                 = "Central India"
  storage_account_name     = "storage7386"
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "GRS"
}
