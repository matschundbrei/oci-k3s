# https://docs.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm#five
variable "compartment_id" {
  description = "an abstract organisational level that OCI did not document very well"
  default     = "ocid1.tenancy.oc1..aaaaaaaaznujs6ihyfatjlswpip3awhd4fywcck3bd2dtqcs3qdbz7fnuqeq"
  type = string
}

variable "v4_cidr" {
  description = "Private IPv4 Adress space for the VCN as CIDR"
  default = "10.42.235.0/24"
}