locals {
  main_node_dns_name = "${oci_core_instance.k3s_main.create_vnic_details[0].hostname_label}.${oci_core_subnet.k3snet[0].subnet_domain_name}"
  metadata_generic = {
    ssh_authorized_keys = var.ssh_authorized_keys
    k3s_secret          = var.k3s_secret
    k3s_cluster_cidr    = var.k3s_cluster_cidr
    k3s_service_cidr    = var.k3s_service_cidr
  }
}


resource "oci_core_instance" "k3s_main" {
  availability_domain = data.oci_identity_availability_domains.this.availability_domains[0].name
  compartment_id      = data.oci_identity_availability_domains.this.availability_domains[0].compartment_id
  shape               = "VM.Standard.A1.Flex"
  display_name        = "K3s Main Node"
  source_details {
    source_type = "image"
    source_id   = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaa7xlh7c3l2xtrn53n5ezp2thnac3hgjo6biolfxisk3l4igfl3xba"
  }
  shape_config {
    ocpus         = 1
    memory_in_gbs = 6
  }
  create_vnic_details {
    assign_private_dns_record = true
    assign_public_ip          = true
    display_name              = "K3s Main Node Primary NIC"
    hostname_label            = "k3s-main"
    subnet_id                 = oci_core_subnet.k3snet[0].id
    nsg_ids = [
      oci_core_network_security_group.allow_outbound.id,
      oci_core_network_security_group.world_ssh.id,
      oci_core_network_security_group.http_https.id,
    ]
  }
  metadata = merge({
    user_data = filebase64("${path.module}/scripts/k3s_master_user_data.sh")
  }, local.metadata_generic)
}

resource "oci_core_instance" "k3s_nodes" {
  count               = 2
  availability_domain = data.oci_identity_availability_domains.this.availability_domains[count.index + 1].name
  compartment_id      = data.oci_identity_availability_domains.this.availability_domains[count.index + 1].compartment_id
  shape               = "VM.Standard.A1.Flex"
  display_name        = "K3s Main Node ${count.index + 1}"
  source_details {
    source_type = "image"
    source_id   = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaa7xlh7c3l2xtrn53n5ezp2thnac3hgjo6biolfxisk3l4igfl3xba"
  }
  shape_config {
    ocpus         = 1
    memory_in_gbs = 6
  }
  create_vnic_details {
    assign_private_dns_record = true
    assign_public_ip          = true
    display_name              = "K3s Node ${count.index + 1} Primary NIC"
    hostname_label            = "k3s-node${count.index + 1}"
    subnet_id                 = oci_core_subnet.k3snet[1].id
    nsg_ids = [
      oci_core_network_security_group.allow_outbound.id,
      oci_core_network_security_group.world_ssh.id,
      oci_core_network_security_group.http_https.id,
    ]
  }
  metadata = merge({
    user_data = filebase64("${path.module}/scripts/k3s_node_user_data.sh")
    k3s_main  = local.main_node_dns_name
  }, local.metadata_generic)
}


data "oci_core_vnic_attachments" "main" {
  compartment_id = var.compartment_id
  instance_id    = oci_core_instance.k3s_main.id
}

data "oci_core_vnic_attachments" "nodes" {
  count          = 2
  compartment_id = var.compartment_id
  instance_id    = oci_core_instance.k3s_nodes[count.index].id
}

resource "oci_core_ipv6" "main" {
  vnic_id = data.oci_core_vnic_attachments.main.vnic_attachments[0].id
}

resource "oci_core_ipv6" "nodes" {
  count   = 2
  vnic_id = data.oci_core_vnic_attachments.nodes[count.index].vnic_attachments[0].id
}
