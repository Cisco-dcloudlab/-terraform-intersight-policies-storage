<!-- BEGIN_TF_DOCS -->
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Developed by: Cisco](https://img.shields.io/badge/Developed%20by-Cisco-blue)](https://developer.cisco.com)
[![Tests](https://github.com/terraform-cisco-modules/terraform-intersight-policies-storage/actions/workflows/terratest.yml/badge.svg)](https://github.com/terraform-cisco-modules/terraform-intersight-policies-storage/actions/workflows/terratest.yml)

# Terraform Intersight Policies - Storage
Manages Intersight Storage Policies

Location in GUI:
`Policies` » `Create Policy` » `Storage`

## Easy IMM

[*Easy IMM - Comprehensive Example*](https://github.com/terraform-cisco-modules/easy-imm-comprehensive-example) - A comprehensive example for policies, pools, and profiles.

## Example

### main.tf
```hcl
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
```

### provider.tf
```hcl
terraform {
  required_providers {
    intersight = {
      source  = "CiscoDevNet/intersight"
      version = ">=1.0.32"
    }
  }
  required_version = ">=1.3.0"
}

provider "intersight" {
  apikey    = var.apikey
  endpoint  = var.endpoint
  secretkey = fileexists(var.secretkeyfile) ? file(var.secretkeyfile) : var.secretkey
}
```

### variables.tf
```hcl
variable "apikey" {
  description = "Intersight API Key."
  sensitive   = true
  type        = string
}

variable "endpoint" {
  default     = "https://intersight.com"
  description = "Intersight URL."
  type        = string
}

variable "secretkey" {
  default     = ""
  description = "Intersight Secret Key Content."
  sensitive   = true
  type        = string
}

variable "secretkeyfile" {
  default     = "blah.txt"
  description = "Intersight Secret Key File Location."
  sensitive   = true
  type        = string
}
```

## Environment Variables

### Terraform Cloud/Enterprise - Workspace Variables
- Add variable apikey with the value of [your-api-key]
- Add variable secretkey with the value of [your-secret-file-content]

### Linux and Windows
```bash
export TF_VAR_apikey="<your-api-key>"
export TF_VAR_secretkeyfile="<secret-key-file-location>"
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.3.0 |
| <a name="requirement_intersight"></a> [intersight](#requirement\_intersight) | >=1.0.32 |
## Providers

| Name | Version |
|------|---------|
| <a name="provider_intersight"></a> [intersight](#provider\_intersight) | 1.0.32 |
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_apikey"></a> [apikey](#input\_apikey) | Intersight API Key. | `string` | n/a | yes |
| <a name="input_endpoint"></a> [endpoint](#input\_endpoint) | Intersight URL. | `string` | `"https://intersight.com"` | no |
| <a name="input_secretkey"></a> [secretkey](#input\_secretkey) | Intersight Secret Key. | `string` | n/a | yes |
| <a name="input_description"></a> [description](#input\_description) | Description for the Policy. | `string` | `""` | no |
| <a name="input_drive_groups"></a> [drive\_groups](#input\_drive\_groups) | Drive Group(s) to Assign to the Storage Policy.<br>* automatic\_drive\_group - This drive group is created using automatic drive selection.  This complex property has following sub-properties:<br>  - drive\_type - Type of drive that should be used for this RAID group.<br>    * Any: (default) - Any type of drive can be used for virtual drive creation.<br>    * HDD - Hard disk drives should be used for virtual drive creation.<br>    * SSD - Solid state drives should be used for virtual drive creation.<br>  - drives\_per\_span - Number of drives within this span group. The minimum number of disks needed in a span group varies based on RAID level. RAID0 requires at least one disk. RAID1 and RAID10 requires at least 2 and in multiples of . RAID5 and RAID50 require at least 3 disks in a span group. RAID6 and RAID60 require atleast 4 disks in a span.<br>  - minimum\_drive\_size - Minimum size of the drive to be used for creating this RAID group.<br>  - num\_dedicated\_hot\_spares - Number of dedicated hot spare disks for this RAID group. Allowed value is a comma or hyphen separated number range.<br>  - number\_of\_spans - Number of span groups to be created for this RAID group. Non-nested RAID levels have a single span.<br>  - use\_remaining\_drives - This flag enables the drive group to use all the remaining drives on the server.<br>* manual\_drive\_group - This drive group is created by specifying the drive slots to be used. This complex property has following sub-properties:<br>  - dedicated\_hot\_spares:(string) A collection of drives to be used as hot spares for this Drive Group.<br>  - slots:(string) Collection of local disks that are part of this span group. Allowed value is a comma or hyphen separated number range. The minimum number of disks needed in a span group varies based on RAID level.<br>    * RAID0 requires at least one disk,<br>    * RAID1 and RAID10 requires at least 2 and in multiples of 2,<br>    * RAID5 RAID50 RAID6 and RAID60 require at least 3 disks in a span group.<br>    * Enable - Enables IO caching on the drive.<br>    * NoChange - Drive cache policy is unchanged.<br>* raid\_level - The supported RAID level for the disk group.<br>  - Raid0 - RAID 0 Stripe Raid Level.<br>  - Raid1: (default) - RAID 1 Mirror Raid Level.<br>  - Raid5 - RAID 5 Mirror Raid Level.<br>  - Raid6 - RAID 6 Mirror Raid Level.<br>  - Raid10 - RAID 10 Mirror Raid Level.<br>  - Raid50 - RAID 50 Mirror Raid Level.<br>  - Raid60 - RAID 60 Mirror Raid Level.<br>* tags - List of Tag Attributes to Assign to the Policy.<br>* virtual\_drives - This complex property has following sub-properties:<br>  - boot\_drive:(bool) This flag enables this virtual drive to be used as a boot drive.<br>  - expand\_to\_available:(bool) This flag enables the virtual drive to use all the space available in the disk group. When this flag is enabled, the size property is ignored.<br>  - name:(string) The name of the virtual drive. The name can be between 1 and 15 alphanumeric characters. Spaces or any special characters other than - (hyphen), \_ (underscore), : (colon), and . (period) are not allowed.<br>  - size:(int) Virtual drive size in MebiBytes. Size is mandatory field except when the Expand to Available option is enabled.<br>  - access\_policy:(string) Access policy that host has on this virtual drive.<br>    * Default: (default) - Use platform default access mode.<br>    * ReadWrite - Enables host to perform read-write on the VD.<br>    * ReadOnly - Host can only read from the VD.<br>    * Blocked - Host can neither read nor write to the VD.<br>  - drive\_cache:(string) Disk cache policy for the virtual drive.<br>    * Default: (default) - Use platform default drive cache mode.<br>    * NoChange - Drive cache policy is unchanged.<br>    * Enable - Enables IO caching on the drive.<br>    * Disable - Disables IO caching on the drive.<br>  - read\_policy:(string) Read ahead mode to be used to read data from this virtual drive.<br>    * Default: (default) - Use platform default read ahead mode.<br>    * ReadAhead - Use read ahead mode for the policy.<br>    * NoReadAhead - Do not use read ahead mode for the policy.<br>  - strip\_size:(int) Desired strip size - Allowed values are 64, 128, 256, 512, 1024.<br>    * 64: (default) - Number of bytes in a strip is 64 Kibibytes.<br>    * 128 - Number of bytes in a strip is 128 Kibibytes.<br>    * 256 - Number of bytes in a strip is 256 Kibibytes.<br>    * 512 - Number of bytes in a strip is 512 Kibibytes.<br>    * 1024 - Number of bytes in a strip is 1024 Kibibytes or 1 Mebibyte.<br>  - write\_policy:(string) Write mode to be used to write data to this virtual drive.<br>    * Default: (default) - Use platform default write mode.<br>    * WriteThrough - Data is written through the cache and to the physical drives. Performance is improved, because subsequent reads of that data can be satisfied from the cache.<br>    * WriteBackGoodBbu - Data is stored in the cache, and is only written to the physical drives when space in the cache is needed. Virtual drives requesting this policy fall back to Write Through caching when the battery backup unit (BBU) cannot guarantee the safety of the cache in the event of a power failure.<br>    * AlwaysWriteBack - With this policy, write caching remains Write Back even if the battery backup unit is defective or discharged. | <pre>list(object(<br>    {<br>      automatic_drive_group = optional(list(object(<br>        {<br>          drives_per_span          = number<br>          drive_type               = optional(string, "Any")<br>          minimum_drive_size       = optional(number, 50)<br>          num_dedicated_hot_spares = optional(list(number), [])<br>          number_of_spans          = optional(number)<br>          use_remaining_drives     = optional(bool, false)<br>        }<br>      )), [])<br>      manual_drive_group = optional(list(object(<br>        {<br>          dedicated_hot_spares = optional(string, "")<br>          drive_array_spans = list(object(<br>            {<br>              slots = string<br>            }<br>          ))<br>          name = string<br>        }<br>      )), [])<br>      name       = string<br>      raid_level = optional(string, "Raid1")<br>      virtual_drives = optional(list(object(<br>        {<br>          access_policy       = optional(string, "Default")<br>          boot_drive          = optional(bool, false)<br>          disk_cache          = optional(string, "Default")<br>          name                = string<br>          expand_to_available = optional(bool, true)<br>          read_policy         = optional(string, "Default")<br>          size                = optional(number, 50)<br>          strip_size          = optional(number, 64)<br>          write_policy        = optional(string, "Default")<br>        }<br>      )), [])<br>    }<br>  ))</pre> | `[]` | no |
| <a name="input_global_hot_spares"></a> [global\_hot\_spares](#input\_global\_hot\_spares) | A collection of disks that is to be used as hot spares, globally, for all the RAID groups. Allowed value is a number range separated by a comma or a hyphen. | `string` | `""` | no |
| <a name="input_m2_configuration"></a> [m2\_configuration](#input\_m2\_configuration) | Virtual Drive configuration for M.2 RAID controller. This complex property has following sub-properties:<br>* controller\_slot - Select the M.2 RAID controller slot on which the virtual drive is to be created. For example:<br>  - MSTOR-RAID-1: (default) - Virtual drive will be created on the M.2 RAID controller in the first slot.<br>  - MSTOR-RAID-2 - Virtual drive will be created on the M.2 RAID controller in the second slot, if available.<br>  - MSTOR-RAID-1,MSTOR-RAID-2 - Virtual drive will be created on the M.2 RAID controller in both the slots, if available.<br>* enable: (default is true) - If enabled, this will create a virtual drive on the M.2 RAID controller. | <pre>list(object(<br>    {<br>      controller_slot = optional(string, "MSTOR-RAID-1")<br>      enable          = optional(bool, true)<br>    }<br>  ))</pre> | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | Name for the Policy. | `string` | `"default"` | no |
| <a name="input_organization"></a> [organization](#input\_organization) | Intersight Organization Name to Apply Policy to.  https://intersight.com/an/settings/organizations/. | `string` | `"default"` | no |
| <a name="input_profiles"></a> [profiles](#input\_profiles) | List of Profiles to Assign to the Policy.<br>* name - Name of the Profile to Assign.<br>* object\_type - Object Type to Assign in the Profile Configuration.<br>  - server.Profile - For UCS Server Profiles.<br>  - server.ProfileTemplate - For UCS Server Profile Templates. | <pre>list(object(<br>    {<br>      name        = string<br>      object_type = optional(string, "server.Profile")<br>    }<br>  ))</pre> | `[]` | no |
| <a name="input_single_drive_raid_configuration"></a> [single\_drive\_raid\_configuration](#input\_single\_drive\_raid\_configuration) | This complex property has following sub-properties:<br>* access\_policy - Access policy that host has on this virtual drive.<br>  - Default: (default) - Use platform default access mode.<br>  - Blocked - Host can neither read nor write to the VD.<br>  - ReadOnly - Host can only read from the VD.<br>  - ReadWrite - Enables host to perform read-write on the VD.<br>* drive\_cache - Disk cache policy for the virtual drive.<br>  - Default: (default) - Use platform default drive cache mode.<br>  - Disable - Disables IO caching on the drive.<br>  - Enable - Enables IO caching on the drive.<br>  - NoChange - Drive cache policy is unchanged.<br>* drive\_slots - The set of drive slots where RAID0 virtual drives must be created.<br>* enable - If enabled, this will create a RAID0 virtual drive per disk and encompassing the whole disk.<br>* read\_policy - Read ahead mode to be used to read data from this virtual drive.<br>  - Default: (default) - Use platform default read ahead mode.<br>  - NoReadAhead - Do not use read ahead mode for the policy.<br>  - ReadAhead - Use read ahead mode for the policy.<br>* strip\_size - Desired strip size - Allowed values are 64KiB, 128KiB, 256KiB, 512KiB, 1024KiB.<br>  - 64: (defualt) -   Number of bytes in a strip is 64 Kibibytes.<br>  - 128 - Number of bytes in a strip is 128 Kibibytes.<br>  - 256 - Number of bytes in a strip is 256 Kibibytes.<br>  - 512 - Number of bytes in a strip is 512 Kibibytes.<br>  - 1024 - Number of bytes in a strip is 1024 Kibibytes or 1 Mebibyte.<br>* write\_policy:(string) Write mode to be used to write data to this virtual drive.<br>  - Default: (default) - Use platform default write mode.<br>  - AlwaysWriteBack - With this policy, write caching remains Write Back even if the battery backup unit is defective or discharged.<br>  - WriteBackGoodBbu - Data is stored in the cache, and is only written to the physical drives when space in the cache is needed. Virtual drives requesting this policy fall back to Write Through caching when the battery backup unit (BBU) cannot guarantee the safety of the cache in the event of a power failure.<br>  - WriteThrough - Data is written through the cache and to the physical drives. Performance is improved, because subsequent reads of that data can be satisfied from the cache. | <pre>list(object(<br>    {<br>      access_policy = optional(string, "Default")<br>      drive_cache   = optional(string, "Default")<br>      drive_slots   = string<br>      enable        = optional(bool, true)<br>      read_policy   = optional(string, "Default")<br>      strip_size    = optional(number, 64)<br>      write_policy  = optional(string, "Default")<br>    }<br>  ))</pre> | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | List of Tag Attributes to Assign to the Policy. | `list(map(string))` | `[]` | no |
| <a name="input_unused_disks_state"></a> [unused\_disks\_state](#input\_unused\_disks\_state) | State to which disks, not used in this policy, are to be moved.<br>* Jbod - JBOD state where the disks start showing up to Host OS.<br>* NoChange - (Default) Drive state will not be modified by Storage Policy.<br>* UnconfiguredGood - Unconfigured good state -ready to be added in a RAID group. | `string` | `"NoChange"` | no |
| <a name="input_use_jbod_for_vd_creation"></a> [use\_jbod\_for\_vd\_creation](#input\_use\_jbod\_for\_vd\_creation) | Disks in JBOD State are used to create virtual drives. | `bool` | `false` | no |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_moid"></a> [moid](#output\_moid) | Storage Policy Managed Object ID (moid). |
| <a name="output_drive_groups"></a> [drive\_groups](#output\_drive\_groups) | Storage Policy - Drive Group(s) Managed Object ID(s) (moids). |
## Resources

| Name | Type |
|------|------|
| [intersight_storage_drive_group.drive_groups](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/resources/storage_drive_group) | resource |
| [intersight_storage_storage_policy.storage](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/resources/storage_storage_policy) | resource |
| [intersight_organization_organization.org_moid](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/data-sources/organization_organization) | data source |
| [intersight_server_profile.profiles](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/data-sources/server_profile) | data source |
| [intersight_server_profile_template.templates](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/data-sources/server_profile_template) | data source |
<!-- END_TF_DOCS -->