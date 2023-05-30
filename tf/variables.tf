variable "k8s_version" {
  type        = string
  description = "k8s version"
  default     = "v1.26.2"
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

    # Oracle-Linux-8.7-aarch64-2023.02.28-1-OKE-1.26.2-605
    "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaa3kigaixnhxyyunekwknlsr7n4pd62kjee22ymfiuwfsffdbdjwjq",
    # Oracle-Linux-8.7-aarch64-2023.02.28-1-OKE-1.26.2-605
    "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaa3kigaixnhxyyunekwknlsr7n4pd62kjee22ymfiuwfsffdbdjwjq",
  ]
}
