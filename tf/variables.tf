variable "k8s_version" {
  type        = string
  description = "k8s version"
  default     = "v1.27.2"
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
    # Oracle-Linux-8.8-aarch64-2023.09.26-0-OKE-1.27.2-648
    "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaav3ywxq3w4xbxoymp4louvugs4m5zcumqhwopwvhqlf5io7hprbwa",
    # Oracle-Linux-8.8-aarch64-2023.09.26-0-OKE-1.27.2-648
    "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaav3ywxq3w4xbxoymp4louvugs4m5zcumqhwopwvhqlf5io7hprbwa",
  ]
}
