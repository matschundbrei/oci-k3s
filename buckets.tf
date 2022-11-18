locals {
  s3_compat_api_endpoint = "${data.oci_objectstorage_namespace.this.namespace}.compat.objectstorage.${var.region}.oraclecloud.com"
}

data "oci_objectstorage_namespace" "this" {
  compartment_id = var.compartment_ocid
}

resource "oci_objectstorage_bucket" "etcd_backup" {
  name           = "etcd-backups"
  namespace      = data.oci_objectstorage_namespace.this.namespace
  compartment_id = var.compartment_ocid
  access_type    = "NoPublicAccess"
  auto_tiering   = "InfrequentAccess"
  versioning     = "Disabled"
}
