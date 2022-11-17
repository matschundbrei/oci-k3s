output "public_ipv4_addresses" {
  description = "an object containing nodename (hostlabel) => public v4 address"
  value = {
    "${oci_core_instance.k3s_main.create_vnic_details[0].hostname_label}"     = oci_core_instance.k3s_main.public_ip,
    "${oci_core_instance.k3s_nodes[0].create_vnic_details[0].hostname_label}" = oci_core_instance.k3s_nodes[0].public_ip,
    "${oci_core_instance.k3s_nodes[1].create_vnic_details[0].hostname_label}" = oci_core_instance.k3s_nodes[1].public_ip,
  }
}

output "public_ipv6_addresses" {
  description = "an object containing nodename (hostlabel) => public v6 address"
  value = {
    "${oci_core_instance.k3s_main.create_vnic_details[0].hostname_label}"     = oci_core_ipv6.ipv6_address[0].ip_address,
    "${oci_core_instance.k3s_nodes[0].create_vnic_details[0].hostname_label}" = oci_core_ipv6.ipv6_address[1].ip_address,
    "${oci_core_instance.k3s_nodes[1].create_vnic_details[0].hostname_label}" = oci_core_ipv6.ipv6_address[2].ip_address,
  }
}
