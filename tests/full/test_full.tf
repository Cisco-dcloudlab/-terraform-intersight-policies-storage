module "main" {
  source      = "../.."
  description = "${var.name} Storage Policy."
  drive_groups = [
    {
      manual_drive_group = [
        {
          drive_array_spans = [
            {
              slots = "1,2"
            }
          ]
          name = var.name
        }
      ]
      name       = var.name
      raid_level = "Raid1"
      virtual_drives = [
        {
          boot_drive = true
          name       = var.name
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
  name                     = var.name
  organization             = "terratest"
  unused_disks_state       = "NoChange"
  use_jbod_for_vd_creation = true
}

output "drive_group" {
  value = module.main.drive_groups[var.name].moid
}