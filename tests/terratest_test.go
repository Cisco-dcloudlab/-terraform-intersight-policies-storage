package test

import (
	"fmt"
	"os"
	"testing"

	iassert "github.com/cgascoig/intersight-simple-go/assert"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestFull(t *testing.T) {
	//========================================================================
	// Setup Terraform options
	//========================================================================

	// Generate a unique name for objects created in this test to ensure we don't
	// have collisions with stale objects
	uniqueId := random.UniqueId()
	instanceName := fmt.Sprintf("test-policies-storage-%s", uniqueId)

	// Input variables for the TF module
	vars := map[string]interface{}{
		"apikey":        os.Getenv("IS_KEYID"),
		"secretkeyfile": os.Getenv("IS_KEYFILE"),
		"name":          instanceName,
	}

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "./full",
		Vars:         vars,
	})

	//========================================================================
	// Init and apply terraform module
	//========================================================================
	defer terraform.Destroy(t, terraformOptions) // defer to ensure that TF destroy happens automatically after tests are completed
	terraform.InitAndApply(t, terraformOptions)
	drive_group := terraform.Output(t, terraformOptions, "drive_group")
	moid := terraform.Output(t, terraformOptions, "moid")
	assert.NotEmpty(t, drive_group, "TF module drive_group moid output should not be empty")
	assert.NotEmpty(t, moid, "TF module moid output should not be empty")

	// Input variables for the TF module
	vars2 := map[string]interface{}{
		"drive_group":    drive_group,
		"storage_policy": moid,
		"name":           instanceName,
	}

	//========================================================================
	// Make Intersight API call(s) to validate module worked
	//========================================================================

	// Setup the expected values of the returned MO.
	// This is a Go template for the JSON object, so template variables can be used
	expectedJSONTemplate := `
{
	"Name":        "{{ .name }}",
	"Description": "{{ .name }} Storage Policy.",

	"DriveGroup": [
        {
          "ClassId": "mo.MoRef",
          "Moid": "{{ .drive_group }}",
          "ObjectType": "storage.DriveGroup",
          "link": "https://www.intersight.com/api/v1/storage/DriveGroups/{{ .drive_group }}"
        }
	],
	"GlobalHotSpares": "",
	"M2VirtualDrive": {
        "ClassId": "storage.M2VirtualDriveConfig",
        "ControllerSlot": "MSTOR-RAID-1",
        "Enable": true,
        "ObjectType": "storage.M2VirtualDriveConfig"
	},
	"Raid0Drive": {
        "ClassId": "storage.R0Drive",
        "DriveSlots": "",
        "DriveSlotsList": "",
        "Enable": false,
        "ObjectType": "storage.R0Drive",
        "VirtualDrivePolicy": {
          "AccessPolicy": "Default",
          "ClassId": "storage.VirtualDrivePolicy",
          "DriveCache": "Default",
          "ObjectType": "storage.VirtualDrivePolicy",
          "ReadPolicy": "Default",
          "StripSize": 64,
          "WritePolicy": "Default"
        }
	},
	"UnusedDisksState": "NoChange",
	"UseJbodForVdCreation": true
}
`
	// Validate that what is in the Intersight API matches the expected
	// The AssertMOComply function only checks that what is expected is in the result. Extra fields in the
	// result are ignored. This means we don't have to worry about things that aren't known in advance (e.g.
	// Moids, timestamps, etc)
	iassert.AssertMOComply(t, fmt.Sprintf("/api/v1/storage/StoragePolicies/%s", moid), expectedJSONTemplate, vars2)

	// Setup the expected values of the returned MO.
	// This is a Go template for the JSON object, so template variables can be used
	expectedDGTemplate := `
{
	"AutomaticDriveGroup": {
        "ClassId": "storage.AutomaticDriveGroup",
        "DriveType": "Any",
        "DrivesPerSpan": 0,
        "MinimumDriveSize": 0,
        "NumDedicatedHotSpares": "",
        "NumberOfSpans": 0,
        "ObjectType": "storage.AutomaticDriveGroup",
        "UseRemainingDrives": false
      },
      "ManualDriveGroup": {
        "ClassId": "storage.ManualDriveGroup",
        "DedicatedHotSpares": "",
        "ObjectType": "storage.ManualDriveGroup",
        "SpanGroups": [
          {
            "ClassId": "storage.SpanDrives",
            "ObjectType": "storage.SpanDrives",
            "Slots": "1,2"
          }
        ]
      },
      "RaidLevel": "Raid1",
      "StoragePolicy": {
        "ClassId": "mo.MoRef",
        "Moid": "{{ .storage_policy }}",
        "ObjectType": "storage.StoragePolicy",
        "link": "https://www.intersight.com/api/v1/storage/StoragePolicies/{{ .storage_policy }}"
      },
      "VirtualDrives": [
        {
          "BootDrive": true,
          "ClassId": "storage.VirtualDriveConfiguration",
          "ExpandToAvailable": true,
          "Name": "vd0",
          "ObjectType": "storage.VirtualDriveConfiguration",
          "Size": 50,
          "VirtualDrivePolicy": {
            "AccessPolicy": "Default",
            "ClassId": "storage.VirtualDrivePolicy",
            "DriveCache": "Default",
            "ObjectType": "storage.VirtualDrivePolicy",
            "ReadPolicy": "Default",
            "StripSize": 64,
            "WritePolicy": "Default"
          }
        }
      ]
    }
  ]}
`
	// Validate that what is in the Intersight API matches the expected
	// The AssertMOComply function only checks that what is expected is in the result. Extra fields in the
	// result are ignored. This means we don't have to worry about things that aren't known in advance (e.g.
	// Moids, timestamps, etc)
	iassert.AssertMOComply(t, fmt.Sprintf("/api/v1/storage/DriveGroups/%s", drive_group), expectedDGTemplate, vars2)
}
