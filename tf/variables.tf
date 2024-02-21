variable "k8s_version" {
  type        = string
  description = "k8s version"
  default     = "v1.28.2"
}
variable "arm_pool_count" {
  type        = number
  description = "The number of instances pools."
  default     = 2
}
variable "arm_pool_size" {
  type        = number
  description = "The number of ARM instances in a pool."
  default     = 1
}
variable "arm_pool_instance_disk_size_in_gb" {
  type        = number
  description = "The size of attached volume in GB"
  default     = 50
}
variable "arm_pool_images" {
  type        = list(string)
  description = "ready images for ARM pools"
  default = [
    # "Oracle-Linux-8.8-aarch64-2023.09.26-0-OKE-1.28.2-653"
    "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaawo2geurhrh2tgdrxmauzfffny3t4cc66rpdtk6rjrugwro4igfbq",
    # "Oracle-Linux-8.8-aarch64-2023.09.26-0-OKE-1.28.2-653"
    "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaawo2geurhrh2tgdrxmauzfffny3t4cc66rpdtk6rjrugwro4igfbq",
  ]
}
variable "enable_wireguard" {
  type        = bool
  description = "Weather or not create wireguard security group allow rules."
  default     = true
}
