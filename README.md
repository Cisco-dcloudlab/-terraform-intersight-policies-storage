<!-- BEGIN_TF_DOCS -->
# Terraform Intersight Policies - Storage
Manages Intersight Storage Policies

Location in GUI:
`Policies` » `Create Policy` » `Storage`

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
  secretkey = var.secretkey
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
  description = "Intersight Secret Key."
  sensitive   = true
  type        = string
}
```

## Environment Variables

### Terraform Cloud/Enterprise - Workspace Variables
- Add variable apikey with value of [your-api-key]
- Add variable secretkey with value of [your-secret-file-content]

### Linux
```bash
export TF_VAR_apikey="<your-api-key>"
export TF_VAR_secretkey=`cat <secret-key-file-location>`
```

### Windows
```bash
$env:TF_VAR_apikey="<your-api-key>"
$env:TF_VAR_secretkey="<secret-key-file-location>"
```
<!-- END_TF_DOCS -->