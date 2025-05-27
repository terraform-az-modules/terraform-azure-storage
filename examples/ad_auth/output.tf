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

output "file_shares" {
  description = "storage SMB file shares list"
  value       = module.storage.file_shares
}

output "tables" {
  description = "storage tables list"
  value       = module.storage.tables
}

output "queues" {
  description = "storage queues list"
  value       = module.storage.queues
}