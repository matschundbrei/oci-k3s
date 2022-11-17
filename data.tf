data "oci_identity_compartment" "this" {
  id = var.compartment_id
}

data "oci_identity_availability_domains" "this" {
  compartment_id = var.compartment_id
}

