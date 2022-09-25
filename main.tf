#____________________________________________________________
#
# Intersight Organization Data Source
# GUI Location: Settings > Settings > Organizations > {Name}
#____________________________________________________________

data "intersight_organization_organization" "org_moid" {
  for_each = {
    for v in [var.organization] : v => v if length(
      regexall("[[:xdigit:]]{24}", var.organization)
    ) == 0
  }
  name = each.value
}

#____________________________________________________________
#
# Intersight UCS Server Profile(s) Data Source
# GUI Location: Profiles > UCS Server Profiles > {Name}
#____________________________________________________________

data "intersight_server_profile" "profiles" {
  for_each = { for v in var.profiles : v.name => v if v.object_type == "server.Profile" }
  name     = each.value.name
}

#__________________________________________________________________
#
# Intersight UCS Server Profile Template(s) Data Source
# GUI Location: Templates > UCS Server Profile Templates > {Name}
#__________________________________________________________________

data "intersight_server_profile_template" "templates" {
  for_each = { for v in var.profiles : v.name => v if v.object_type == "server.ProfileTemplate" }
  name     = each.value.name
}

#__________________________________________________________________
#
# Intersight Storage Policy
# GUI Location: Policies > Create Policy > Storage
#__________________________________________________________________

resource "intersight_storage_storage_policy" "storage" {
  depends_on = [
    data.intersight_server_profile.profiles,
    data.intersight_server_profile_template.templates,
    data.intersight_organization_organization.org_moid
  ]
  description              = var.description != "" ? var.description : "${var.name} Storage Policy."
  global_hot_spares        = var.global_hot_spares
  name                     = var.name
  unused_disks_state       = var.unused_disks_state
  use_jbod_for_vd_creation = var.use_jbod_for_vd_creation
  # retain_policy_virtual_drives = var.retain_policy
  organization {
    moid = length(
      regexall("[[:xdigit:]]{24}", var.organization)
      ) > 0 ? var.organization : data.intersight_organization_organization.org_moid[
      var.organization].results[0
    ].moid
    object_type = "organization.Organization"
  }
  dynamic "m2_virtual_drive" {
    for_each = var.m2_configuration
    content {
      controller_slot = m2_virtual_drive.value.controller_slot
      enable          = m2_virtual_drive.value.enable
      # additional_properties = ""
      # object_type           = "storage.DiskGroupPolicy"
    }
  }
  dynamic "profiles" {
    for_each = { for v in var.profiles : v.name => v }
    content {
      moid = length(regexall("server.ProfileTemplate", profiles.value.object_type)
        ) > 0 ? data.intersight_server_profile_template.templates[profiles.value.name].results[0
      ].moid : data.intersight_server_profile.profiles[profiles.value.name].results[0].moid
      object_type = profiles.value.object_type
    }
  }
  dynamic "raid0_drive" {
    for_each = toset(var.single_drive_raid_configuration)
    content {
      drive_slots = raid0_drive.value.drive_slots
      enable      = raid0_drive.value.enable
      object_type = "server.Profile"
      virtual_drive_policy = [
        {
          additional_properties = ""
          access_policy         = raid0_drive.value.access_policy
          class_id              = "storage.VirtualDriveConfig"
          drive_cache           = raid0_drive.value.drive_cache
          object_type           = "storage.VirtualDriveConfig"
          read_policy           = raid0_drive.value.read_policy
          strip_size            = raid0_drive.value.strip_size
          write_policy          = raid0_drive.value.write_policy
        }
      ]
    }
  }
  dynamic "tags" {
    for_each = var.tags
    content {
      key   = tags.value.key
      value = tags.value.value
    }
  }
}

#__________________________________________________________________
#
# Intersight Storage Policy > Drive Group
# GUI Location: Policies > Create Policy > Storage: Drive Group
#__________________________________________________________________

resource "intersight_storage_drive_group" "drive_groups" {
  depends_on = [
    intersight_storage_storage_policy.storage
  ]
  for_each   = { for v in var.drive_groups : v.name => v }
  name       = each.value.name
  raid_level = each.value.raid_level
  storage_policy {
    moid = intersight_storage_storage_policy.storage.moid
    # object_type = "organization.Organization"
  }
  dynamic "automatic_drive_group" {
    for_each = toset(each.value.automatic_drive_group)
    content {
      class_id                 = "storage.ManualDriveGroup"
      drives_per_span          = automatic_drive_group.value.drives_per_span
      drive_type               = automatic_drive_group.value.drive_type
      minimum_drive_size       = automatic_drive_group.value.minimum_drive_size
      num_dedicated_hot_spares = automatic_drive_group.value.num_dedicated_hot_spares
      number_of_spans          = automatic_drive_group.value.number_of_spans
      object_type              = "storage.ManualDriveGroup"
      use_remaining_drives     = automatic_drive_group.value.use_remaining_drives
    }
  }
  dynamic "manual_drive_group" {
    for_each = { for v in each.value.manual_drive_group : v.name => v }
    content {
      class_id             = "storage.ManualDriveGroup"
      dedicated_hot_spares = manual_drive_group.value.dedicated_hot_spares
      object_type          = "storage.ManualDriveGroup"
      span_groups = [
        for sg in manual_drive_group.value.drive_array_spans : {
          additional_properties = ""
          class_id              = "storage.SpanDrives"
          object_type           = "storage.SpanDrives"
          slots                 = sg.slots
        }
      ]
    }
  }
  dynamic "tags" {
    for_each = var.tags
    content {
      key   = tags.value.key
      value = tags.value.value
    }
  }
  dynamic "virtual_drives" {
    for_each = { for v in each.value.virtual_drives : v.name => v }
    content {
      additional_properties = ""
      boot_drive            = virtual_drives.value.boot_drive
      class_id              = "storage.VirtualDriveConfiguration"
      expand_to_available   = virtual_drives.value.expand_to_available
      name                  = virtual_drives.key
      object_type           = "storage.VirtualDriveConfiguration"
      size                  = virtual_drives.value.size
      virtual_drive_policy = [
        {
          additional_properties = ""
          access_policy         = virtual_drives.value.access_policy
          class_id              = "storage.VirtualDrivePolicy"
          drive_cache           = virtual_drives.value.disk_cache
          object_type           = "storage.VirtualDrivePolicy"
          read_policy           = virtual_drives.value.read_policy
          strip_size            = virtual_drives.value.strip_size
          write_policy          = virtual_drives.value.write_policy
        }
      ]
    }
  }
}
