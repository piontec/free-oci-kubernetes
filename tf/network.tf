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

removed {
  from = oci_core_security_list.private_subnet_sl

  lifecycle {
    destroy = false
  }
}

removed {
  from = oci_core_security_list.public_subnet_sl

  lifecycle {
    destroy = false
  }
}

resource "oci_core_subnet" "vcn_private_subnet" {
  compartment_id = var.compartment_id
  vcn_id         = module.vcn.vcn_id
  cidr_block     = "10.0.1.0/24"

  route_table_id             = module.vcn.nat_route_id
  display_name               = "free-k8s-private-subnet"
  prohibit_public_ip_on_vnic = true

  lifecycle {
    ignore_changes = [security_list_ids]
  }
}

resource "oci_core_subnet" "vcn_public_subnet" {
  compartment_id = var.compartment_id
  vcn_id         = module.vcn.vcn_id
  cidr_block     = "10.0.0.0/24"

  route_table_id = module.vcn.ig_route_id
  display_name   = "free-k8s-public-subnet"

  lifecycle {
    ignore_changes = [security_list_ids]
  }
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

removed {
  from = local_file.gateway_nlb_patch

  lifecycle {
    destroy = false
  }
}

resource "null_resource" "gateway_nlb_patch" {
  triggers = {
    content_sha = sha256(templatefile("gateway-nlb-patch.yaml.tftpl", {
      nsg_ocid = oci_core_network_security_group.nginx_ingress_network_security_group.id
    }))
  }

  provisioner "local-exec" {
    working_dir = path.module
    command = <<-EOT
      set -eu

      if [ -e ../flux-modules/kube-system/gateway-nlb-patch.yaml ]; then
        echo "../flux-modules/kube-system/gateway-nlb-patch.yaml already exists, leaving it unchanged"
        exit 0
      fi

      cat > ../flux-modules/kube-system/gateway-nlb-patch.yaml <<'EOF'
${templatefile("gateway-nlb-patch.yaml.tftpl", {
    nsg_ocid = oci_core_network_security_group.nginx_ingress_network_security_group.id
})}
EOF
      chmod 0640 ../flux-modules/kube-system/gateway-nlb-patch.yaml
    EOT
}
}
