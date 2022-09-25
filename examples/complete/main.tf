module "storage" {
  source  = "terraform-cisco-modules/policies-storage/intersight"
  version = ">= 1.0.1"

  description = "default Storage Policy."
  drive_groups = [
    {
      manual_drive_group = [
        {
          drive_array_spans = [
            {
              slots = "1,2"
            }
          ]
          name = "dg0"
        }
      ]
      name       = "Raid1"
      raid_level = "Raid1"
      virtual_drives = [
        {
          boot_drive = true
          name       = "VD0"
        }
      ]
    },
  ]
  m2_configuration = [
    {
      controller_slot = "MSTOR-RAID-1"
      enable          = true
    }
  ]
  name                     = "default"
  organization             = "default"
  unused_disks_state       = "NoChange"
  use_jbod_for_vd_creation = true
}
