data "oci_identity_compartment" "this" {
  id = var.compartment_id
}

data "oci_identity_availability_domains" "this" {
  compartment_id = var.compartment_id
}

data "oci_core_images" "ubuntu_arm" {
  compartment_id           = var.compartment_id
  operating_system         = "Canonical Ubuntu"
  operating_system_version = "22.04"
  state                    = "AVAILABLE"
  shape                    = "VM.Standard.A1.Flex"
  sort_by                  = "TIMECREATED"
}