##-----------------------------------------------------------------------------
## Storage Account
##-----------------------------------------------------------------------------
output "storage_account_id" {
  value       = try(azurerm_storage_account.storage[0].id, null)
  description = "The ID of the storage account."
}

output "storage_account_name" {
  value       = try(azurerm_storage_account.storage[0].name, null)
  description = "The name of the storage account."
}

output "storage_account_primary_location" {
  value       = try(azurerm_storage_account.storage[0].primary_location, null)
  description = "The primary location of the storage account"
}

output "storage_account_primary_web_endpoint" {
  value       = try(azurerm_storage_account.storage[0].primary_web_endpoint, null)
  description = "The endpoint URL for web storage in the primary location."
}

output "storage_account_primary_blob_endpoint" {
  value       = try(azurerm_storage_account.storage[0].primary_blob_endpoint, null)
  description = "The endpoint URL for blob storage in the primary location."
}

output "storage_account_primary_web_host" {
  value       = try(azurerm_storage_account.storage[0].primary_web_host, null)
  description = "The hostname with port if applicable for web storage in the primary location."
}

output "storage_primary_connection_string" {
  value       = try(azurerm_storage_account.storage[0].primary_connection_string, null)
  sensitive   = true
  description = "The primary connection string for the storage account"
}

output "storage_primary_access_key" {
  value       = try(azurerm_storage_account.storage[0].primary_access_key, null)
  sensitive   = true
  description = "The primary access key for the storage account"
}

output "containers" {
  value       = { for c in azurerm_storage_container.container : c.name => c.id }
  description = "Map of containers."
}

output "file_shares" {
  description = "Map of Storage SMB file shares."
  value       = { for f in azurerm_storage_share.fileshare : f.name => f.id }
}

output "tables" {
  description = "Map of Storage SMB file shares."
  value       = { for t in azurerm_storage_table.tables : t.name => t.id }
}

output "queues" {
  description = "Map of Storage SMB file shares."
  value       = { for q in azurerm_storage_queue.queues : q.name => q.id }
}

