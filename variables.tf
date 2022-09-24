#____________________________________________________________
#
# Storage Policy Variables Section.
#____________________________________________________________

variable "description" {
  default     = ""
  description = "Description for the Policy."
  type        = string
}

variable "drive_groups" {
  default     = []
  description = <<-EOT
    Drive Group(s) to Assign to the Storage Policy.
    * automatic_drive_group - This drive group is created using automatic drive selection.  This complex property has following sub-properties:
      - drive_type - Type of drive that should be used for this RAID group.
        * Any: (default) - Any type of drive can be used for virtual drive creation.
        * HDD - Hard disk drives should be used for virtual drive creation.
        * SSD - Solid state drives should be used for virtual drive creation.
      - drives_per_span - Number of drives within this span group. The minimum number of disks needed in a span group varies based on RAID level. RAID0 requires at least one disk. RAID1 and RAID10 requires at least 2 and in multiples of . RAID5 and RAID50 require at least 3 disks in a span group. RAID6 and RAID60 require atleast 4 disks in a span.
      - minimum_drive_size - Minimum size of the drive to be used for creating this RAID group.
      - num_dedicated_hot_spares - Number of dedicated hot spare disks for this RAID group. Allowed value is a comma or hyphen separated number range.
      - number_of_spans - Number of span groups to be created for this RAID group. Non-nested RAID levels have a single span.
      - use_remaining_drives - This flag enables the drive group to use all the remaining drives on the server.
    * manual_drive_group - This drive group is created by specifying the drive slots to be used. This complex property has following sub-properties:
      - dedicated_hot_spares:(string) A collection of drives to be used as hot spares for this Drive Group.
      - slots:(string) Collection of local disks that are part of this span group. Allowed value is a comma or hyphen separated number range. The minimum number of disks needed in a span group varies based on RAID level.
        * RAID0 requires at least one disk,
        * RAID1 and RAID10 requires at least 2 and in multiples of 2,
        * RAID5 RAID50 RAID6 and RAID60 require at least 3 disks in a span group.
        * Enable - Enables IO caching on the drive.
        * NoChange - Drive cache policy is unchanged.
    * raid_level - The supported RAID level for the disk group.
      - Raid0 - RAID 0 Stripe Raid Level.
      - Raid1: (default) - RAID 1 Mirror Raid Level.
      - Raid5 - RAID 5 Mirror Raid Level.
      - Raid6 - RAID 6 Mirror Raid Level.
      - Raid10 - RAID 10 Mirror Raid Level.
      - Raid50 - RAID 50 Mirror Raid Level.
      - Raid60 - RAID 60 Mirror Raid Level.
    * tags - List of Tag Attributes to Assign to the Policy.
    * virtual_drives - This complex property has following sub-properties:
      - boot_drive:(bool) This flag enables this virtual drive to be used as a boot drive.
      - expand_to_available:(bool) This flag enables the virtual drive to use all the space available in the disk group. When this flag is enabled, the size property is ignored.
      - name:(string) The name of the virtual drive. The name can be between 1 and 15 alphanumeric characters. Spaces or any special characters other than - (hyphen), _ (underscore), : (colon), and . (period) are not allowed.
      - size:(int) Virtual drive size in MebiBytes. Size is mandatory field except when the Expand to Available option is enabled.
      - access_policy:(string) Access policy that host has on this virtual drive.
        * Default: (default) - Use platform default access mode.
        * ReadWrite - Enables host to perform read-write on the VD.
        * ReadOnly - Host can only read from the VD.
        * Blocked - Host can neither read nor write to the VD.
      - drive_cache:(string) Disk cache policy for the virtual drive.
        * Default: (default) - Use platform default drive cache mode.
        * NoChange - Drive cache policy is unchanged.
        * Enable - Enables IO caching on the drive.
        * Disable - Disables IO caching on the drive.
      - read_policy:(string) Read ahead mode to be used to read data from this virtual drive.
        * Default: (default) - Use platform default read ahead mode.
        * ReadAhead - Use read ahead mode for the policy.
        * NoReadAhead - Do not use read ahead mode for the policy.
      - strip_size:(int) Desired strip size - Allowed values are 64, 128, 256, 512, 1024.
        * 64: (default) - Number of bytes in a strip is 64 Kibibytes.
        * 128 - Number of bytes in a strip is 128 Kibibytes.
        * 256 - Number of bytes in a strip is 256 Kibibytes.
        * 512 - Number of bytes in a strip is 512 Kibibytes.
        * 1024 - Number of bytes in a strip is 1024 Kibibytes or 1 Mebibyte.
      - write_policy:(string) Write mode to be used to write data to this virtual drive.
        * Default: (default) - Use platform default write mode.
        * WriteThrough - Data is written through the cache and to the physical drives. Performance is improved, because subsequent reads of that data can be satisfied from the cache.
        * WriteBackGoodBbu - Data is stored in the cache, and is only written to the physical drives when space in the cache is needed. Virtual drives requesting this policy fall back to Write Through caching when the battery backup unit (BBU) cannot guarantee the safety of the cache in the event of a power failure.
        * AlwaysWriteBack - With this policy, write caching remains Write Back even if the battery backup unit is defective or discharged.
  EOT
  type = list(object(
    {
      automatic_drive_group = optional(list(object(
        {
          drives_per_span          = number
          drive_type               = optional(string, "Any")
          minimum_drive_size       = optional(number, 50)
          num_dedicated_hot_spares = optional(list(number), [])
          number_of_spans          = optional(number)
          use_remaining_drives     = optional(bool, false)
        }
      )), [])
      manual_drive_group = optional(list(object(
        {
          dedicated_hot_spares = optional(string, "")
          drive_array_spans = list(object(
            {
              slots = string
            }
          ))
          name = string
        }
      )), [])
      name       = string
      raid_level = optional(string, "Raid1")
      virtual_drives = optional(list(object(
        {
          access_policy       = optional(string, "Default")
          boot_drive          = optional(bool, false)
          disk_cache          = optional(string, "Default")
          name                = string
          expand_to_available = optional(bool, true)
          read_policy         = optional(string, "Default")
          size                = optional(number, 50)
          strip_size          = optional(number, 64)
          write_policy        = optional(string, "Default")
        }
      )), [])
    }
  ))
}

variable "global_hot_spares" {
  default     = ""
  description = "A collection of disks that is to be used as hot spares, globally, for all the RAID groups. Allowed value is a number range separated by a comma or a hyphen."
  type        = string
}

variable "m2_configuration" {
  default     = []
  description = <<-EOT
    Virtual Drive configuration for M.2 RAID controller. This complex property has following sub-properties:
    * controller_slot - Select the M.2 RAID controller slot on which the virtual drive is to be created. For example:
      - MSTOR-RAID-1: (default) - Virtual drive will be created on the M.2 RAID controller in the first slot.
      - MSTOR-RAID-2 - Virtual drive will be created on the M.2 RAID controller in the second slot, if available.
      - MSTOR-RAID-1,MSTOR-RAID-2 - Virtual drive will be created on the M.2 RAID controller in both the slots, if available.
    * enable: (default is true) - If enabled, this will create a virtual drive on the M.2 RAID controller.
  EOT
  type = list(object(
    {
      controller_slot = optional(string, "MSTOR-RAID-1")
      enable          = optional(bool, true)
    }
  ))
}

variable "name" {
  default     = "default"
  description = "Name for the Policy."
  type        = string
}

variable "organization" {
  default     = "default"
  description = "Intersight Organization Name to Apply Policy to.  https://intersight.com/an/settings/organizations/."
  type        = string
}

variable "profiles" {
  default     = []
  description = <<-EOT
    List of Profiles to Assign to the Policy.
    * name - Name of the Profile to Assign.
    * object_type - Object Type to Assign in the Profile Configuration.
      - server.Profile - For UCS Server Profiles.
      - server.ProfileTemplate - For UCS Server Profile Templates.
  EOT
  type = list(object(
    {
      name        = string
      object_type = optional(string, "server.Profile")
    }
  ))
}

variable "single_drive_raid_configuration" {
  default     = []
  description = <<-EOT
    This complex property has following sub-properties:
    * access_policy - Access policy that host has on this virtual drive.
      - Default: (default) - Use platform default access mode.
      - Blocked - Host can neither read nor write to the VD.
      - ReadOnly - Host can only read from the VD.
      - ReadWrite - Enables host to perform read-write on the VD.
    * drive_cache - Disk cache policy for the virtual drive.
      - Default: (default) - Use platform default drive cache mode.
      - Disable - Disables IO caching on the drive.
      - Enable - Enables IO caching on the drive.
      - NoChange - Drive cache policy is unchanged.
    * drive_slots - The set of drive slots where RAID0 virtual drives must be created.
    * enable - If enabled, this will create a RAID0 virtual drive per disk and encompassing the whole disk.
    * read_policy - Read ahead mode to be used to read data from this virtual drive.
      - Default: (default) - Use platform default read ahead mode.
      - NoReadAhead - Do not use read ahead mode for the policy.
      - ReadAhead - Use read ahead mode for the policy.
    * strip_size - Desired strip size - Allowed values are 64KiB, 128KiB, 256KiB, 512KiB, 1024KiB.
      - 64: (defualt) -   Number of bytes in a strip is 64 Kibibytes.
      - 128 - Number of bytes in a strip is 128 Kibibytes.
      - 256 - Number of bytes in a strip is 256 Kibibytes.
      - 512 - Number of bytes in a strip is 512 Kibibytes.
      - 1024 - Number of bytes in a strip is 1024 Kibibytes or 1 Mebibyte.
    * write_policy:(string) Write mode to be used to write data to this virtual drive.
      - Default: (default) - Use platform default write mode.
      - AlwaysWriteBack - With this policy, write caching remains Write Back even if the battery backup unit is defective or discharged.
      - WriteBackGoodBbu - Data is stored in the cache, and is only written to the physical drives when space in the cache is needed. Virtual drives requesting this policy fall back to Write Through caching when the battery backup unit (BBU) cannot guarantee the safety of the cache in the event of a power failure.
      - WriteThrough - Data is written through the cache and to the physical drives. Performance is improved, because subsequent reads of that data can be satisfied from the cache.
  EOT
  type = list(object(
    {
      access_policy = optional(string, "Default")
      drive_cache   = optional(string, "Default")
      drive_slots   = string
      enable        = optional(bool, true)
      read_policy   = optional(string, "Default")
      strip_size    = optional(number, 64)
      write_policy  = optional(string, "Default")
    }
  ))
}

variable "tags" {
  default     = []
  description = "List of Tag Attributes to Assign to the Policy."
  type        = list(map(string))
}

variable "unused_disks_state" {
  default     = "NoChange"
  description = <<-EOT
    State to which disks, not used in this policy, are to be moved.
    * Jbod - JBOD state where the disks start showing up to Host OS.
    * NoChange - (Default) Drive state will not be modified by Storage Policy.
    * UnconfiguredGood - Unconfigured good state -ready to be added in a RAID group.
  EOT
  type        = string
}

variable "use_jbod_for_vd_creation" {
  default     = false
  description = "Disks in JBOD State are used to create virtual drives."
  type        = bool
}
