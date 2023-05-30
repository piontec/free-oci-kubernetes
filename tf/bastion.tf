resource "oci_bastion_bastion" "k8s_bastion" {
  bastion_type                 = "STANDARD"
  compartment_id               = var.compartment_id
  target_subnet_id             = oci_core_subnet.vcn_private_subnet.id
  max_session_ttl_in_seconds   = 10800
  name                         = "k8s"
  client_cidr_block_allow_list = var.bastion_allowed_ips
}
