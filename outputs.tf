#____________________________________________________________
#
# Collect the moid of the Storage Policy as an Output
#____________________________________________________________

output "moid" {
  description = "Storage Policy Managed Object ID (moid)."
  value       = intersight_storage_storage_policy.storage.moid
}

#___________________________________________________________________
#
# Collect the moid of the Storage Policy - Drive Group as an Output
#___________________________________________________________________

output "drive_groups" {
  description = "Storage Policy - Drive Group(s) Managed Object ID(s) (moids)."
  value = { for v in sort(
    keys(intersight_storage_drive_group.drive_groups)
  ) : v => intersight_storage_drive_group.drive_groups[v].moid }
}
