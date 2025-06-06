##-----------------------------------------------------------------------------
##  Private DNS ID 
##-----------------------------------------------------------------------------
output "dns_zone_id_storage_account" {
  value = module.private_dns_zone.private_dns_zone_ids.storage_account
}
