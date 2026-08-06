// Bootstrap the Flux Operator using the controlplaneio-fluxcd bootstrap module.
//
// An ephemeral in-cluster Job installs the Flux Operator (Helm) and applies the
// FluxInstance with create-if-missing semantics, then hands ownership over to
// Flux. The FluxInstance manifest is read straight from the GitOps tree
// (single source of truth); after bootstrap, Flux reconciles the same file from
// the "flux/" sync path and adopts the operator HelmRelease + FluxInstance.
module "flux_operator_bootstrap" {
  source  = "controlplaneio-fluxcd/flux-operator-bootstrap/kubernetes"
  version = "0.7.0"

  // Wait for .kube.config to be written before the helm/kubernetes providers
  // try to reach the cluster.
  depends_on = [null_resource.kube_config]

  // Bump to force the bootstrap Job to re-run.
  revision = 1

  gitops_resources = {
    instance_yaml = file("${path.module}/../flux/flux-system/flux-instance.yaml")
  }

  // Git credentials secret (username/password) consumed by the FluxInstance
  // sync via pullSecret: flux-system. Never stored in Terraform state - the
  // module only keeps a SHA-256 hash. Skipped when no token is provided.
  managed_resources = {
    secrets_yaml = var.git_token == "" ? "" : <<-YAML
      apiVersion: v1
      kind: Secret
      metadata:
        name: flux-system
        namespace: flux-system
      type: Opaque
      stringData:
        username: git
        password: '${replace(var.git_token, "'", "''")}'
    YAML
  }
}

// State migration: detach the resources from the previous bootstrap mechanism
// WITHOUT deleting them from the live cluster. The module re-adopts them.
removed {
  from = kubernetes_manifest.flux_instance

  lifecycle {
    destroy = false
  }
}

removed {
  from = kubernetes_secret_v1.git_auth

  lifecycle {
    destroy = false
  }
}
