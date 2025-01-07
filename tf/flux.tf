// Create a Kubernetes secret with the Git credentials
// if a Git token is provided.
resource "kubernetes_secret" "git_auth" {
  count      = var.git_token != "" ? 1 : 0

  metadata {
    name      = "flux-system"
    namespace = "flux-system"
  }

  data = {
    username = "git"
    password = var.git_token
  }

  type = "Opaque"
}

// Install the Flux Operator.
resource "helm_release" "flux_operator" {
  name       = "flux-operator"
  namespace  = "flux-system"
  repository = "oci://ghcr.io/controlplaneio-fluxcd/charts"
  chart      = "flux-operator"
  create_namespace = true
}

// Configure the Flux instance.
resource "kubernetes_manifest" "flux_instance" {
  depends_on = [helm_release.flux_operator]

  manifest = {
    "apiVersion"= "fluxcd.controlplane.io/v1"
    "kind" = "FluxInstance"
    "metadata" = {
      "name" = "flux"
      "namespace" = "flux-system"
    }
    "spec" = {
      "cluster" = {
        "domain" = "cluster.local"
        "multitenant" = "false"
        "networkPolicy" = "true"
        "type" = "kubernetes"
        "tenantDefaultServiceAccount" = "default"
      }
      "components" = [
        "source-controller",
        "kustomize-controller",
        "helm-controller",
        "notification-controller",
        "image-reflector-controller",
        "image-automation-controller"
      ]
      "distribution" = {
        "artifact" = "oci://ghcr.io/controlplaneio-fluxcd/flux-operator-manifests"
        "registry" = var.flux_registry
        "version" = var.flux_version
      }
      "sync" = {
        "interval" = "1m"
        "kind" = "GitRepository"
        "path" = var.git_path
        "pullSecret" = "flux-system"
        "ref" = var.git_ref
        "url" = var.git_url
      }
      "wait" = "true"
    }
  }
}

