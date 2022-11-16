resource "oci_core_vcn" "k3snet" {
  display_name   = "K3s VCN"
  compartment_id = var.compartment_id
  dns_label      = "solutrk3s"
  is_ipv6enabled = true
  cidr_blocks = [
    "10.42.235.0/24",
  ]
}

resource "oci_core_default_route_table" "k3snet" {
  manage_default_resource_id = oci_core_vcn.k3snet.default_route_table_id
  route_rules {
    description       = "default route via internet gateway (v4)"
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.k3snet.id
  }
  route_rules {
    description       = "default route via internet gateway (v6)"
    destination       = "::/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.k3snet.id
  }
}

resource "oci_core_internet_gateway" "k3snet" {
  display_name   = "K3s Internet Gateway"
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.k3snet.id
  enabled        = true
  route_table_id = oci_core_vcn.k3snet.default_route_table_id
}

locals {
  subnets = [
    "10.42.235.0/25",
    "10.42.235.128/25",
  ]
}

resource "oci_core_subnet" "k3snet" {
  count          = 2
  cidr_block     = local.subnets[count.index]
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.k3snet.id
  dns_label      = "subnet${count.index}"
  display_name   = "K3s VCN Subnet ${count.index}"
}

resource "oci_core_route_table_attachment" "k3snet_sub" {
  count          = 2
  subnet_id      = oci_core_subnet.k3snet[count.index].id
  route_table_id = oci_core_vcn.k3snet.default_route_table_id
}

resource "oci_core_network_security_group" "allow_outbound" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.k3snet.id
  display_name   = "Allow Outbound"
}

resource "oci_core_network_security_group_security_rule" "allow_outbound_v6" {
  count                     = length(oci_core_vcn.k3snet.ipv6cidr_blocks)
  description               = "Allows outgoing traffic to anything (IPv6)"
  network_security_group_id = oci_core_network_security_group.allow_outbound.id
  direction                 = "EGRESS"
  destination_type          = "CIDR_BLOCK"
  destination               = "::/0"
  source_type               = "CIDR_BLOCK"
  source                    = oci_core_vcn.k3snet.ipv6cidr_blocks[count.index]
  protocol                  = "all"
}

resource "oci_core_network_security_group_security_rule" "allow_outbound_v4" {
  count                     = length(oci_core_vcn.k3snet.cidr_blocks)
  description               = "Allows outgoing traffic to anything (IPv4)"
  network_security_group_id = oci_core_network_security_group.allow_outbound.id
  direction                 = "EGRESS"
  destination_type          = "CIDR_BLOCK"
  destination               = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  source                    = oci_core_vcn.k3snet.cidr_blocks[count.index]
  protocol                  = "all"
}


resource "oci_core_network_security_group" "world_ssh" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.k3snet.id
  display_name   = "Open SSH Port to Everyone"

}

resource "oci_core_network_security_group_security_rule" "world_ssh_v6" {
  count                     = length(oci_core_vcn.k3snet.ipv6cidr_blocks)
  description               = "Opens port 22 for TCP from all sources (IPv6)"
  network_security_group_id = oci_core_network_security_group.world_ssh.id
  direction                 = "INGRESS"
  destination_type          = "CIDR_BLOCK"
  destination               = oci_core_vcn.k3snet.ipv6cidr_blocks[count.index]
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
  count                     = length(oci_core_vcn.k3snet.cidr_blocks)
  description               = "Opens port 22 for TCP from all sources (IPv4)"
  network_security_group_id = oci_core_network_security_group.world_ssh.id
  direction                 = "INGRESS"
  destination_type          = "CIDR_BLOCK"
  destination               = oci_core_vcn.k3snet.cidr_blocks[count.index]
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
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.k3snet.id
  display_name   = "Open HTTP(s) Ports to Everyone"
}

resource "oci_core_network_security_group_security_rule" "http_v6" {
  count                     = length(oci_core_vcn.k3snet.ipv6cidr_blocks)
  description               = "Opens port 80 for TCP from all sources (IPv6)"
  network_security_group_id = oci_core_network_security_group.http_https.id
  direction                 = "INGRESS"
  destination_type          = "CIDR_BLOCK"
  destination               = oci_core_vcn.k3snet.ipv6cidr_blocks[count.index]
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
  count                     = length(oci_core_vcn.k3snet.cidr_blocks)
  description               = "Opens port 80 for TCP from all sources (IPv4)"
  network_security_group_id = oci_core_network_security_group.http_https.id
  direction                 = "INGRESS"
  destination_type          = "CIDR_BLOCK"
  destination               = oci_core_vcn.k3snet.cidr_blocks[count.index]
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
  count                     = length(oci_core_vcn.k3snet.ipv6cidr_blocks)
  description               = "Opens port 443 for TCP from all sources (IPv6)"
  network_security_group_id = oci_core_network_security_group.http_https.id
  direction                 = "INGRESS"
  destination_type          = "CIDR_BLOCK"
  destination               = oci_core_vcn.k3snet.ipv6cidr_blocks[count.index]
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
  count                     = length(oci_core_vcn.k3snet.cidr_blocks)
  description               = "Opens port 443 for TCP from all sources (IPv4)"
  network_security_group_id = oci_core_network_security_group.http_https.id
  direction                 = "INGRESS"
  destination_type          = "CIDR_BLOCK"
  destination               = oci_core_vcn.k3snet.cidr_blocks[count.index]
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