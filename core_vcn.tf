resource "oci_core_vcn" "k3snet" {
  display_name   = "K3s VCN"
  compartment_id = var.compartment_ocid
  dns_label      = "solutrk3s"
  is_ipv6enabled = true
  cidr_blocks = [
    var.v4_cidr,
  ]
}

resource "oci_core_default_route_table" "k3snet" {
  manage_default_resource_id = oci_core_vcn.k3snet.default_route_table_id
  route_rules {
    description       = "default route via internet gateway (v4)"
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.k3snet.id
  }
}

resource "oci_core_internet_gateway" "k3snet" {
  display_name   = "K3s Internet Gateway"
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.k3snet.id
  enabled        = true
}

resource "oci_core_subnet" "k3snet" {
  count          = 2
  cidr_block     = cidrsubnet(var.v4_cidr, 1, count.index)
  ipv6cidr_block = cidrsubnet(oci_core_vcn.k3snet.ipv6cidr_blocks[0], 8, count.index)
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.k3snet.id
  dns_label      = "sn${count.index + 1}"
  display_name   = "K3s VCN Subnet ${count.index + 1}"
}

resource "oci_core_route_table_attachment" "k3snet_sub" {
  count          = 2
  subnet_id      = oci_core_subnet.k3snet[count.index].id
  route_table_id = oci_core_vcn.k3snet.default_route_table_id
}

resource "oci_core_network_security_group" "allow_outbound" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.k3snet.id
  display_name   = "Allow Outbound and Internal"
}

resource "oci_core_network_security_group_security_rule" "allow_outbound_v6" {
  description               = "Allows outgoing traffic to anything (IPv6)"
  network_security_group_id = oci_core_network_security_group.allow_outbound.id
  direction                 = "EGRESS"
  destination_type          = "CIDR_BLOCK"
  destination               = "::/0"
  source                    = oci_core_vcn.k3snet.ipv6cidr_blocks[0]
  protocol                  = "all"
}

resource "oci_core_network_security_group_security_rule" "allow_outbound_v4" {
  description               = "Allows outgoing traffic to anything (IPv4)"
  network_security_group_id = oci_core_network_security_group.allow_outbound.id
  direction                 = "EGRESS"
  destination_type          = "CIDR_BLOCK"
  destination               = "0.0.0.0/0"
  source                    = oci_core_vcn.k3snet.cidr_blocks[0]
  protocol                  = "all"
}

resource "oci_core_network_security_group_security_rule" "allow_internal_v4" {
  description               = "Allows internal traffic from VCN"
  network_security_group_id = oci_core_network_security_group.allow_outbound.id
  direction                 = "INGRESS"
  destination               = oci_core_vcn.k3snet.cidr_blocks[0]
  source                    = oci_core_vcn.k3snet.cidr_blocks[0]
  source_type               = "CIDR_BLOCK"
  protocol                  = "all"
}

resource "oci_core_network_security_group_security_rule" "allow_internal_v6" {
  description               = "Allows internal traffic from VCN"
  network_security_group_id = oci_core_network_security_group.allow_outbound.id
  direction                 = "INGRESS"
  destination               = oci_core_vcn.k3snet.ipv6cidr_blocks[0]
  source                    = oci_core_vcn.k3snet.ipv6cidr_blocks[0]
  source_type               = "CIDR_BLOCK"
  protocol                  = "all"
}


resource "oci_core_network_security_group" "world_ssh" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.k3snet.id
  display_name   = "Open SSH Port to Everyone"
}

resource "oci_core_network_security_group_security_rule" "world_ssh_v6" {
  description               = "Opens port 22 for TCP from all sources (IPv6)"
  network_security_group_id = oci_core_network_security_group.world_ssh.id
  direction                 = "INGRESS"
  destination               = oci_core_vcn.k3snet.ipv6cidr_blocks[0]
  source_type               = "CIDR_BLOCK"
  source                    = "::/0"
  protocol                  = 6
  tcp_options {
    destination_port_range {
      max = 22
      min = 22
    }
  }
}

resource "oci_core_network_security_group_security_rule" "world_ssh_v4" {
  description               = "Opens port 22 for TCP from all sources (IPv4)"
  network_security_group_id = oci_core_network_security_group.world_ssh.id
  direction                 = "INGRESS"
  destination               = oci_core_vcn.k3snet.cidr_blocks[0]
  source_type               = "CIDR_BLOCK"
  source                    = "0.0.0.0/0"
  protocol                  = 6
  tcp_options {
    destination_port_range {
      max = 22
      min = 22
    }
  }
}

resource "oci_core_network_security_group" "http_https" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.k3snet.id
  display_name   = "Open HTTP(s) Ports to Everyone"
}

resource "oci_core_network_security_group_security_rule" "http_v6" {
  description               = "Opens port 80 for TCP from all sources (IPv6)"
  network_security_group_id = oci_core_network_security_group.http_https.id
  direction                 = "INGRESS"
  destination               = oci_core_vcn.k3snet.ipv6cidr_blocks[0]
  source_type               = "CIDR_BLOCK"
  source                    = "::/0"
  protocol                  = 6
  tcp_options {
    destination_port_range {
      max = 80
      min = 80
    }
  }
}

resource "oci_core_network_security_group_security_rule" "http_v4" {
  description               = "Opens port 80 for TCP from all sources (IPv4)"
  network_security_group_id = oci_core_network_security_group.http_https.id
  direction                 = "INGRESS"
  destination               = oci_core_vcn.k3snet.cidr_blocks[0]
  source_type               = "CIDR_BLOCK"
  source                    = "0.0.0.0/0"
  protocol                  = 6
  tcp_options {
    destination_port_range {
      max = 80
      min = 80
    }
  }
}

resource "oci_core_network_security_group_security_rule" "https_v6" {
  description               = "Opens port 443 for TCP from all sources (IPv6)"
  network_security_group_id = oci_core_network_security_group.http_https.id
  direction                 = "INGRESS"
  destination               = oci_core_vcn.k3snet.ipv6cidr_blocks[0]
  source_type               = "CIDR_BLOCK"
  source                    = "::/0"
  protocol                  = 6
  tcp_options {
    destination_port_range {
      max = 443
      min = 443
    }
  }
}

resource "oci_core_network_security_group_security_rule" "https_v4" {
  description               = "Opens port 443 for TCP from all sources (IPv4)"
  network_security_group_id = oci_core_network_security_group.http_https.id
  direction                 = "INGRESS"
  destination               = oci_core_vcn.k3snet.cidr_blocks[0]
  source_type               = "CIDR_BLOCK"
  source                    = "0.0.0.0/0"
  protocol                  = 6
  tcp_options {
    destination_port_range {
      max = 443
      min = 443
    }
  }
}
