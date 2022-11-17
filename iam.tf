locals {
  s3_compat_api_access_key = oci_identity_customer_secret_key.etcd_s3_compat_snapshots.id
  s3_compat_api_secret_key = oci_identity_customer_secret_key.etcd_s3_compat_snapshots.id
}

resource "oci_identity_user" "etcd_bucket_access" {
  compartment_id = var.compartment_id
  description    = "provides access to buckets via s3 api"
  name           = "k3s-etcd-snapshots"
  email          = var.sync_email_user
}

resource "oci_identity_policy" "etcd_bucket_access" {
  compartment_id = var.compartment_id
  description    = "provides access to etcd-bucket for k3s-etcd-snapshots user"
  name           = "etcd-bucket-access"
  statements = [
    "Allow user ${oci_identity_user.etcd_bucket_access.name} to read buckets in compartment ${data.oci_identity_compartment.this.name}",
    "Allow user ${oci_identity_user.etcd_bucket_access.name} to manage objects in compartment ${data.oci_identity_compartment.this.name} where all {target.bucket.name='${oci_objectstorage_bucket.etcd_backup.name}', any {request.permission='OBJECT_CREATE', request.permission='OBJECT_INSPECT'}}",
  ]
}

resource "oci_identity_customer_secret_key" "etcd_s3_compat_snapshots" {
  display_name = "K3sEtcdS3CompatKey"
  user_id      = oci_identity_user.etcd_bucket_access.id
}
