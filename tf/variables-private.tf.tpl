variable "compartment_id" {
  type        = string
  description = "The compartment to create the resources in"
  default     = "ocid1.tenancy.oc1..aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
}
variable "region" {
  type        = string
  description = "The region to provision the resources in"
  default     = "eu-frankfurt-1"
}
variable "ssh_public_key" {
  type        = string
  description = "The SSH public key to use for connecting to the worker nodes"
  default     = "ssh-rsa AAAA........"
}
variable "bastion_allowed_ips" {
  type        = list(string)
  description = "List of IP prefixes allowed to connect via bastion"
  default     = ["127.0.0.1/32"]
}
variable "ad_list" {
  type        = list
  description = "List of length 2 with the names of availability regions to use"
  default     = ["fJnH:EU-FRANKFURT-1-AD-1", "fJnH:EU-FRANKFURT-1-AD-1"]
}
