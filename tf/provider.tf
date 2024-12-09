provider "oci" {
  region              = var.region
  # config_file_profile = "test"
}

terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 4.0.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.27"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.12"
    }
  }
}

provider "kubernetes" {
  config_path = ".kube.config"
}

provider "helm" {
  kubernetes {
    config_path = ".kube.config"
  }
}
