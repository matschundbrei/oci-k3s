locals {
  bucket_names = [
    "solutr-contrib",
    "solutr-images",
    "solutr-backups",
  ]
}

data "oci_objectstorage_namespace" "this" {
  compartment_id = var.compartment_id
}


resource "oci_objectstorage_bucket" "solutr" {
  count          = length(local.bucket_names)
  name           = local.bucket_names[count.index]
  namespace      = data.oci_objectstorage_namespace.this.namespace
  compartment_id = var.compartment_id
  access_type    = "NoPublicAccess"
  auto_tiering   = "InfrequentAccess"
  versioning     = "Enabled"
}