##-----------------------------------------------------------------------------
## Storage Account
##-----------------------------------------------------------------------------
output "storage_account_id" {
  value       = module.storage.storage_account_id
  description = "The ID of the storage account."
}

output "storage_account_name" {
  value       = module.storage.storage_account_name
  description = "The name of the storage account."
}
