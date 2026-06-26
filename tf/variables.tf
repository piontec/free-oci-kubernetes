variable "k8s_version" {
  type        = string
  description = "k8s version"
  default     = "v1.36.0"
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
    # "Oracle-Linux-8.10-aarch64-2026.04.30-3-OKE-1.36.0-1462",
    "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaaurf2m4ofluyf3qwvhc34jr3mhzqz4utyz2hgtmkzlujvqm7xzmka",
    # "Oracle-Linux-8.10-aarch64-2026.04.30-3-OKE-1.36.0-1462",
    "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaaurf2m4ofluyf3qwvhc34jr3mhzqz4utyz2hgtmkzlujvqm7xzmka",
  ]
}
variable "enable_wireguard" {
  type        = bool
  description = "Weather or not create wireguard security group allow rules."
  default     = true
}

variable "git_path" {
  description = "Path to the cluster manifests in the Git repository"
  type        = string
  nullable    = false
  default     = "flux/"
}

variable "git_ref" {
  description = "Git branch or tag in the format refs/heads/main or refs/tags/v1.0.0"
  type        = string
  default     = "refs/heads/main"
}

variable "flux_version" {
  description = "Flux version semver range"
  type        = string
  default     = "2.x"
}

variable "flux_registry" {
  description = "Flux distribution registry"
  type        = string
  default     = "ghcr.io/fluxcd"
}
