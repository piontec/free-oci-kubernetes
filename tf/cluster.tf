resource "oci_containerengine_cluster" "k8s_cluster" {
  compartment_id     = var.compartment_id
  kubernetes_version = var.k8s_version
  name               = "free-k8s-cluster"
  vcn_id             = module.vcn.vcn_id

  endpoint_config {
    is_public_ip_enabled = true
    subnet_id            = oci_core_subnet.vcn_public_subnet.id
  }

  #  cluster_pod_network_options {
  #    cni_type = "ncn"
  #  }

  options {
    add_ons {
      is_kubernetes_dashboard_enabled = false
      is_tiller_enabled               = false
    }
    kubernetes_network_config {
      pods_cidr     = "10.244.0.0/16"
      services_cidr = "10.96.0.0/16"
    }
    service_lb_subnet_ids = [oci_core_subnet.vcn_public_subnet.id]
  }
}

data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_id
}

resource "oci_containerengine_node_pool" "k8s_node_pool" {
  count              = var.arm_pool_count
  cluster_id         = oci_containerengine_cluster.k8s_cluster.id
  compartment_id     = var.compartment_id
  kubernetes_version = var.k8s_version
  name               = "free-k8s-node-pool-${count.index}"

  depends_on = [oci_core_volume.arm_instance_volume]

  node_config_details {
    placement_configs {
      availability_domain = data.oci_identity_availability_domains.ads.availability_domains[count.index].name
      subnet_id           = oci_core_subnet.vcn_private_subnet.id
    }
    size          = var.arm_pool_size
    freeform_tags = { "type" = "k8s" }
  }
  node_shape = "VM.Standard.A1.Flex"

  node_shape_config {
    memory_in_gbs = 12
    ocpus         = 2
  }

  node_source_details {
    image_id    = var.arm_pool_images[count.index]
    source_type = "image"
  }

  node_metadata = {
    user_data = filebase64("${path.module}/setup_bv.sh")
  }

  initial_node_labels {
    key   = "name"
    value = "free-k8s-cluster-pool-${count.index}"
  }

  ssh_public_key = var.ssh_public_key
}

resource "oci_core_volume" "arm_instance_volume" {
  count          = var.arm_pool_count
  compartment_id = var.compartment_id

  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[count.index].name
  size_in_gbs         = var.arm_pool_instance_disk_size_in_gb
  freeform_tags       = { "free-k8s-index" = count.index }
}

resource "oci_identity_dynamic_group" "k8s_instances" {
  compartment_id = var.compartment_id
  description    = "k8s instances"
  matching_rule  = "instance.compartment.id = ${var.compartment_id}"
  # matching_rule   = "Any {instance.id = '${data.oci_containerengine_node_pool.k8s_node_pool[0].nodes[0].id}', instance.id =" '${data.oci_containerengine_node_pool.k8s_node_pool[1].nodes[0].id}'
  # matching_rule = "Any {" + join("instance.id = "${var.compartment_id}"
  name          = "k8s_instances"
  freeform_tags = { "Type" = "k8s" }
}

resource "oci_identity_policy" "k8s_instance_policy" {
  compartment_id = var.compartment_id
  description    = "allow k8s instances to mount disks"
  name           = "k8s_allow_disks"
  statements = [
    "Allow dynamic-group k8s_instances to use instance-family in tenancy",
    "Allow dynamic-group k8s_instances to use volumes in tenancy",
    "Allow dynamic-group k8s_instances to manage volume-attachments in tenancy"
  ]
}

resource "oci_identity_policy" "k8s_instance_policy_metrics" {
  compartment_id = var.compartment_id
  description    = "allow k8s instances to read oci metrics"
  name           = "k8s_allow_oci_metrics"
  statements = [
    "Allow dynamic-group k8s_instances to read metrics in tenancy",
    "Allow dynamic-group k8s_instances to read compartments in tenancy"
  ]
}
