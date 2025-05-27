##-------------------------------------------------------------------------------------
## User Assigned Identity - Create user assigned identity in your azure environment.     
##-------------------------------------------------------------------------------------
resource "azurerm_user_assigned_identity" "identity" {
  provider            = azurerm.main_sub
  count               = var.enabled && var.cmk_encryption_enabled ? 1 : 0
  location            = var.location
  name                = var.resource_position_prefix ? format("uai-%s", local.name) : format("%s-uai", local.name)
  resource_group_name = var.resource_group_name
  tags                = module.labels.tags
}

##-----------------------------------------------------------------------------------------------------------------------
## Below resource will assign 'Key Vault Crypto Service Encryption User' role to user assigned identity created above. 
##-----------------------------------------------------------------------------------------------------------------------
resource "azurerm_role_assignment" "identity_assigned" {
  provider             = azurerm.main_sub
  depends_on           = [azurerm_user_assigned_identity.identity]
  count                = var.enabled && var.cmk_encryption_enabled && var.key_vault_rbac_auth_enabled ? 1 : 0
  principal_id         = azurerm_user_assigned_identity.identity[0].principal_id
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Crypto Service Encryption User"
}

##-------------------------------------------------------------------------------------------------------------
## Below resource will provide user access on key vault based on role base access in azure environment.
## if rbac is enabled then below resource will create. 
##-------------------------------------------------------------------------------------------------------------
resource "azurerm_role_assignment" "rbac_keyvault_crypto_officer" {
  provider = azurerm.main_sub
  for_each = toset(var.key_vault_rbac_auth_enabled && var.enabled && var.cmk_encryption_enabled ? var.admin_objects_ids : [])

  scope                = var.key_vault_id
  role_definition_name = "Key Vault Crypto Officer"
  principal_id         = each.value
}

##-------------------------------------------------------------------------------------------------
## Key Vault Access Policy - Create access policy for user whose object id will be mentioned. 
##-------------------------------------------------------------------------------------------------
resource "azurerm_key_vault_access_policy" "keyvault-access-policy" {
  provider     = azurerm.main_sub
  count        = local.create_key_vault ? 1 : 0
  key_vault_id = var.key_vault_id
  tenant_id    = data.azurerm_client_config.current_client_config.tenant_id
  object_id    = azurerm_user_assigned_identity.identity[0].principal_id

  key_permissions = [
    "Create",
    "Delete",
    "Get",
    "Purge",
    "Recover",
    "Update",
    "Get",
    "WrapKey",
    "UnwrapKey",
    "List",
    "Decrypt",
    "Sign",
    "Encrypt"
  ]
  secret_permissions = [
    "Get",
    "List",
    "Set",
    "Delete",
    "Recover",
    "Backup",
    "Restore",
    "Purge",
  ]
  storage_permissions = [
    "Get",
    "List",
  ]
}
