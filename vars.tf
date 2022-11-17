# https://docs.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm#five
variable "compartment_id" {
  description = "an abstract organisational level that OCI did not document very well"
  default     = "ocid1.tenancy.oc1..aaaaabbbbbccccccdddddd"
  type        = string
}

variable "region" {
  description = "an OCI region in order for this stack to work, we need one with three (3) availability_domains (AD)"
  type        = string
  default     = "eu-frankfurt-1"
}

variable "v4_cidr" {
  description = "Private IPv4 Adress space for the VCN as CIDR"
  default     = "10.42.235.0/24"
  type        = string
}

variable "k3s_cluster_cidr" {
  description = "Private IPv4 Cluster CIDR for K3s"
  default     = "10.42.1.0/24"
  type        = string
}

variable "k3s_service_cidr" {
  description = "Private IPv4 Cluster CIDR for K3s"
  default     = "10.42.42.0/24"
  type        = string
}

variable "ssh_authorized_keys" {
  description = "ssh-key to add to authorized_keys"
  type        = string
}

variable "k3s_secret" {
  description = "k3s secret for joining instances etc"
  type        = string
  sensitive   = true
}
variable "sync_email_user" {
  description = "primary email address for the user created"
  type        = string
  default     = "kim@example.org"
}
