module "storage" {
  source  = "terraform-cisco-modules/policies-storage/intersight"
  version = ">= 1.0.1"

  description      = "default Storage Policy."
drive_groups = [
  {
    manual_drive_group = [
      {
        drive_array_spans = [{ slots = "1,2" }]
        name              = "dg0"
      }
    ]
    name       = "RAID1"
    raid_level = "Raid1"
    virtual_drives = [
      {
        boot_drive          = false
        disk_cache          = "Default"
        expand_to_available = true
        name                = "VD0"
        read_policy         = "Default"
        size                = 10
        strip_size          = 64
        write_policy        = "Default"
      }
    ]
  },
]
name                     = "default"
  organization = "default"
unused_disks_state       = "NoChange"
use_jbod_for_vd_creation = true
}
