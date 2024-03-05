output "k8s-cluster-id" {
  value = oci_containerengine_cluster.k8s_cluster.id
}

output "nginx-ingress-secgroup-ocid" {
  value = oci_core_network_security_group.nginx_ingress_network_security_group.id
}
