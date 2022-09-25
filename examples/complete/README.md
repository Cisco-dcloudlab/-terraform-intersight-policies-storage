<!-- BEGIN_TF_DOCS -->
# Storage Policy Example

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Note that this example will create resources. Resources can be destroyed with `terraform destroy`.

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
<!-- END_TF_DOCS -->