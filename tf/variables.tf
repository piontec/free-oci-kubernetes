variable "k8s_version" {
  type        = string
  description = "k8s version"
  default     = "v1.37.0"
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
    # "Oracle-Linux-9.8-aarch64-2026.08.14-0-OKE-1.37.0-1820"
    "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaa3txwracxjpsf5xtsmf6slzfuc2v3s5t4ube6iw5mxf2doxakgbmq",
    # "Oracle-Linux-9.8-aarch64-2026.08.14-0-OKE-1.37.0-1820"
    "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaa3txwracxjpsf5xtsmf6slzfuc2v3s5t4ube6iw5mxf2doxakgbmq",
  ]
}
variable "enable_wireguard" {
  type        = bool
  description = "Weather or not create wireguard security group allow rules."
  default     = true
}
