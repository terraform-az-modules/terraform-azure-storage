provider "azurerm" {
  features {}
  storage_use_azuread = true
  subscription_id     = "1ac2caa4-336e-4daa-b8f1-0fbabe2d4b11"
}

provider "azurerm" {
  features {}
  alias           = "peer"
  subscription_id = "1ac2caa4-336e-4daa-b8f1-0fbabe2d4b11"
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
  subnet_names         = ["subnet1"]
  subnet_prefixes      = ["10.0.1.0/24"]
}

# ------------------------------------------------------------------------------
# Private DNS Zone module call
# ------------------------------------------------------------------------------
module "private_dns_zone" {
  source              = "github.com/clouddrove-sandbox/terraform-azure-private-dns-zone.git?ref=feat/private-dns-zone"
  resource_group_name = module.resource_group.resource_group_name

  private_dns_config = [
    {
      resource_type = "storage_account"
      vnet_ids      = [module.vnet.vnet_id]
    }
  ]
}

##----------------------------------------------------------------------------- 
## Storage module call.
## Here storage account will be deployed with private dns zone. 
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
  enable_private_endpoint       = true
  private_dns_zone_ids          = module.private_dns_zone.private_dns_zone_ids.storage_account
  subnet_id                     = module.subnet.default_subnet_id
  network_rules = [
    {
      default_action             = "Deny"
      ip_rules                   = ["0.0.0.0/0"]
      virtual_network_subnet_ids = []
      bypass                     = ["AzureServices"]
  }]
}