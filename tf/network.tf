module "vcn" {
  source  = "oracle-terraform-modules/vcn/oci"
  version = ">=3.5.0"

  compartment_id = var.compartment_id
  region         = var.region

  internet_gateway_route_rules = null
  local_peering_gateways       = null
  nat_gateway_route_rules      = null

  vcn_name      = "free-k8s-vcn"
  vcn_dns_label = "freek8svcn"
  vcn_cidrs     = ["10.0.0.0/16"]

  create_internet_gateway = true
  create_nat_gateway      = true
  create_service_gateway  = true
}

resource "oci_core_security_list" "private_subnet_sl" {
  compartment_id = var.compartment_id
  vcn_id         = module.vcn.vcn_id

  display_name = "free-k8s-private-subnet-sl"

  egress_security_rules {
    stateless        = false
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
  }

  ingress_security_rules {
    stateless   = false
    source      = "10.0.0.0/16"
    source_type = "CIDR_BLOCK"
    protocol    = "all"
  }
}

locals {
  public_tcp_ports = [80, 443, 6443]
  public_udp_ports = var.enable_wireguard == true ? [30111] : []
}

resource "oci_core_security_list" "public_subnet_sl" {
  compartment_id = var.compartment_id
  vcn_id         = module.vcn.vcn_id

  display_name = "free-k8s-public-subnet-sl"

  egress_security_rules {
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
    stateless        = false
  }

  ingress_security_rules {
    stateless   = false
    source      = "10.0.0.0/16"
    source_type = "CIDR_BLOCK"
    protocol    = "all"
  }

  dynamic "ingress_security_rules" {
    for_each = local.public_tcp_ports
    content {
      protocol    = "6"
      source      = "0.0.0.0/0"
      source_type = "CIDR_BLOCK"
      stateless   = false

      tcp_options {
        max = ingress_security_rules.value
        min = ingress_security_rules.value
      }
    }
  }

  dynamic "ingress_security_rules" {
    for_each = local.public_udp_ports
    content {
      protocol    = "17"
      source      = "0.0.0.0/0"
      source_type = "CIDR_BLOCK"
      stateless   = false

      udp_options {
        max = ingress_security_rules.value
        min = ingress_security_rules.value
      }
    }
  }
}

resource "oci_core_subnet" "vcn_private_subnet" {
  compartment_id = var.compartment_id
  vcn_id         = module.vcn.vcn_id
  cidr_block     = "10.0.1.0/24"

  route_table_id             = module.vcn.nat_route_id
  security_list_ids          = [oci_core_security_list.private_subnet_sl.id]
  display_name               = "free-k8s-private-subnet"
  prohibit_public_ip_on_vnic = true
}

resource "oci_core_subnet" "vcn_public_subnet" {
  compartment_id = var.compartment_id
  vcn_id         = module.vcn.vcn_id
  cidr_block     = "10.0.0.0/24"

  route_table_id    = module.vcn.ig_route_id
  security_list_ids = [oci_core_security_list.public_subnet_sl.id]
  display_name      = "free-k8s-public-subnet"
}

resource "oci_core_network_security_group" "nginx_ingress_network_security_group" {
  compartment_id = var.compartment_id
  vcn_id         = module.vcn.vcn_id
}

resource "oci_core_network_security_group_security_rule" "nginx_ingress_network_security_group_security_rule_443" {
  network_security_group_id = oci_core_network_security_group.nginx_ingress_network_security_group.id
  description               = "nginx-ingress"
  direction                 = "INGRESS"
  protocol                  = 6

  source      = "0.0.0.0/0"
  source_type = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      max = 443
      min = 443
    }
  }
}

resource "oci_core_network_security_group_security_rule" "nginx_ingress_network_security_group_security_rule_80" {
  network_security_group_id = oci_core_network_security_group.nginx_ingress_network_security_group.id
  description               = "nginx-ingress"
  direction                 = "INGRESS"
  protocol                  = 6

  source      = "0.0.0.0/0"
  source_type = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      max = 80
      min = 80
    }
  }
}

resource "local_file" "ingress_sec_group_oidc" {
  content         = templatefile("network-ingress-oidc.tftpl", { oidc = oci_core_network_security_group.nginx_ingress_network_security_group.id })
  filename        = "../flux-modules/kube-system/ingress-nginx-secgroup-oidc-cm.yaml"
  file_permission = "0640"
}
