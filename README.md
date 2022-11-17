# OCI K3s for Free

An Oracle Cloud Resource Manager ready stack to deploy an ARM based three node K3s cluster for free.

## Synopsis

This is a [Terraform](https://www.terraform.io/) stack, that is suitable for the [OCI Resource Manager](https://docs.oracle.com/en-us/iaas/Content/ResourceManager/Concepts/resource-manager-and-terraform.htm) but can be used on its own as well.

It will set up a IPv6 enabled virtual network and three K3s Nodes based on Ubuntu and the ARM-Offering of OCI.

This should be great to test and run small apps or learn more about kubernetes.

1. [Create an account with OCI](https://signup.oraclecloud.com/)
2. [Fork this repo](https://github.com/matschundbrei/oci-k3s/fork)
3. [Create an personal access token on Github with the 'repo' scope](https://github.com/settings/tokens)
4. [Create a stack from Git in your OCI](https://docs.oracle.com/en-us/iaas/Content/ResourceManager/Tasks/create-stack-git.htm)
5. Fill out the variables
6. ...
7. Profit!

## Background

It was the brink of the pumpkin spiced latte season when my favorite cloud commentator [Corey Quinn](https://twitter.com/QuinnyPig) (Website: [lastweekinaws.com](https://www.lastweekinaws.com/)) mentioned that the Oracle Cloud actually has a [free tier](https://www.oracle.com/cloud/free/) (as in 'free beer' not 'free lunch' like with most other providers). To my complete surprise this turned out to be true, so I thought to myself, maybe we can do something sensible with this.

So what you are looking at here, is the result of that thought.

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_oci"></a> [oci](#provider\_oci) | 4.99.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [oci_core_default_route_table.k3snet](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_default_route_table) | resource |
| [oci_core_instance.k3s_main](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_instance) | resource |
| [oci_core_instance.k3s_nodes](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_instance) | resource |
| [oci_core_internet_gateway.k3snet](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_internet_gateway) | resource |
| [oci_core_ipv6.ipv6_address](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_ipv6) | resource |
| [oci_core_network_security_group.allow_outbound](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_network_security_group) | resource |
| [oci_core_network_security_group.http_https](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_network_security_group) | resource |
| [oci_core_network_security_group.world_ssh](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_network_security_group) | resource |
| [oci_core_network_security_group_security_rule.allow_internal_v4](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_network_security_group_security_rule) | resource |
| [oci_core_network_security_group_security_rule.allow_internal_v6](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_network_security_group_security_rule) | resource |
| [oci_core_network_security_group_security_rule.allow_outbound_v4](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_network_security_group_security_rule) | resource |
| [oci_core_network_security_group_security_rule.allow_outbound_v6](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_network_security_group_security_rule) | resource |
| [oci_core_network_security_group_security_rule.http_v4](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_network_security_group_security_rule) | resource |
| [oci_core_network_security_group_security_rule.http_v6](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_network_security_group_security_rule) | resource |
| [oci_core_network_security_group_security_rule.https_v4](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_network_security_group_security_rule) | resource |
| [oci_core_network_security_group_security_rule.https_v6](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_network_security_group_security_rule) | resource |
| [oci_core_network_security_group_security_rule.world_ssh_v4](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_network_security_group_security_rule) | resource |
| [oci_core_network_security_group_security_rule.world_ssh_v6](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_network_security_group_security_rule) | resource |
| [oci_core_route_table_attachment.k3snet_sub](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_route_table_attachment) | resource |
| [oci_core_subnet.k3snet](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_subnet) | resource |
| [oci_core_vcn.k3snet](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_vcn) | resource |
| [oci_objectstorage_bucket.solutr](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/objectstorage_bucket) | resource |
| [oci_core_images.ubuntu_arm](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/data-sources/core_images) | data source |
| [oci_core_vnic_attachments.all](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/data-sources/core_vnic_attachments) | data source |
| [oci_identity_availability_domains.this](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/data-sources/identity_availability_domains) | data source |
| [oci_identity_compartment.this](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/data-sources/identity_compartment) | data source |
| [oci_objectstorage_namespace.this](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/data-sources/objectstorage_namespace) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_compartment_id"></a> [compartment\_id](#input\_compartment\_id) | an abstract organisational level that OCI did not document very well | `string` | `"ocid1.tenancy.oc1..aaaaabbbbbccccccdddddd"` | no |
| <a name="input_k3s_cluster_cidr"></a> [k3s\_cluster\_cidr](#input\_k3s\_cluster\_cidr) | Private IPv4 Cluster CIDR for K3s | `string` | `"10.42.1.0/24"` | no |
| <a name="input_k3s_secret"></a> [k3s\_secret](#input\_k3s\_secret) | k3s secret for joining instances etc | `string` | n/a | yes |
| <a name="input_k3s_service_cidr"></a> [k3s\_service\_cidr](#input\_k3s\_service\_cidr) | Private IPv4 Cluster CIDR for K3s | `string` | `"10.42.42.0/24"` | no |
| <a name="input_region"></a> [region](#input\_region) | an OCI region in order for this stack to work, we need one with three (3) availability\_domains (AD) | `string` | `"eu-frankfurt-1"` | no |
| <a name="input_ssh_authorized_keys"></a> [ssh\_authorized\_keys](#input\_ssh\_authorized\_keys) | ssh-key to add to authorized\_keys | `string` | n/a | yes |
| <a name="input_v4_cidr"></a> [v4\_cidr](#input\_v4\_cidr) | Private IPv4 Adress space for the VCN as CIDR | `string` | `"10.42.235.0/24"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_oci_oicd_name"></a> [oci\_oicd\_name](#output\_oci\_oicd\_name) | n/a |
