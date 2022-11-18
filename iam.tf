locals {
  s3_compat_api_access_key = oci_identity_customer_secret_key.etcd_s3_compat_snapshots.id
  s3_compat_api_secret_key = oci_identity_customer_secret_key.etcd_s3_compat_snapshots.key
}

resource "oci_identity_user" "etcd_bucket_access" {
  compartment_id = var.tenancy_ocid
  description    = "provides access to buckets via s3 api"
  name           = "K3sEtcd"
  email          = var.sync_email_user
}

resource "oci_identity_user_capabilities_management" "etcd_bucket_access" {
  user_id                      = oci_identity_user.etcd_bucket_access.id
  can_use_api_keys             = "true"
  can_use_auth_tokens          = "true"
  can_use_console_password     = "false"
  can_use_customer_secret_keys = "true"
  can_use_smtp_credentials     = "false"
}

locals {
  # small bit of magic to create printable policy target
  policy_target = (
    startswith(var.compartment_ocid, "ocid1.tenancy")
    ? "tenancy"
    : "compartment '${data.oci_identity_compartment.this.name}'"
  )

}

resource "oci_identity_group" "etcd_bucket_access" {
  compartment_id = var.tenancy_ocid
  description    = "group for the users that are allowed to access etcd snapshots"
  name           = "K3sEtcd"
}

resource "oci_identity_policy" "etcd_bucket_access" {
  compartment_id = var.tenancy_ocid
  description    = "provides access to etcd-bucket for k3s-etcd-snapshots user"
  name           = "K3sEtcd"
  statements = [
    "Allow group '${oci_identity_group.etcd_bucket_access.name}' to read buckets in ${local.policy_target}",
    "Allow group '${oci_identity_group.etcd_bucket_access.name}' to manage objects in ${local.policy_target} where all {target.bucket.name='${oci_objectstorage_bucket.etcd_backup.name}', any {request.permission='OBJECT_CREATE', request.permission='OBJECT_INSPECT'}}",
  ]
}

resource "oci_identity_user_group_membership" "etcd_bucket_access" {
  group_id = oci_identity_group.etcd_bucket_access.id
  user_id  = oci_identity_user.etcd_bucket_access.id
}

resource "oci_identity_customer_secret_key" "etcd_s3_compat_snapshots" {
  display_name = "K3sEtcdS3CompatKey"
  user_id      = oci_identity_user.etcd_bucket_access.id
}
