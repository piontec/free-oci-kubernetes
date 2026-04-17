# AGENTS.md - Free OCI Kubernetes Cluster with GitOps

## Project Overview

This repository provisions a free Kubernetes cluster on Oracle Cloud Infrastructure (OCI) using Flux CD for
GitOps. It deploys monitoring (Prometheus, Loki, Grafana), cilium, cert-manager, and optional extras like
WireGuard VPN.

## Required Tools

- **tofu** - Infrastructure as Code (OpenTofu/Terraform fork)
- **flux** - Flux CD CLI for GitOps
- **sops** - Secret encryption
- **gpg** - GPG keys for SOPS
- **oci** - Oracle Cloud CLI
- **kubectl** - Kubernetes CLI
- **pre-commit** - Git hooks (optional, for PRs)

## Project Structure

```
/                 # Root config files (.sops.yaml, .yamlfmt, .pre-commit-config.yaml)
tf/               # OpenTofu infrastructure (OCI cluster, networking, Flux operator)
flux/             # Flux CD core installation
flux-modules/     # GitOps modules:
  - cilium/           # CNI, Gateway API
  - monitoring/       # Prometheus, Loki, Grafana
  - flux-system-extra/
  - kube-system-extra/
  - extras/           # Optional: wireguard
```

## Secrets

Secrets are encrypted with SOPS + GPG. See `.sops.yaml` for configuration.

Files ending with `.tpl.enc` are templates - copy to corresponding `.yaml` file, add secrets, then encrypt:

```sh
sops -i -e flux-modules/<path>/<file>.yaml
```

## Public services access

Public services are exposed using the Gateway API provided by Cilium, which also works as a CNI driver.
(The cluster was successfully migrated from nginx-ingress to Cilium Gateway API in March 2026).
Certificates for encrypted HTTP are automatically requested from Let's Encrypt by cert-manager using Gateway
integration. At any point in time, the whole cluster must use only 1 Oracle Cloud Network
Load Balancer and no other load balancers of any type.

## Common Commands

```sh
# Deploy infrastructure
cd tf && tofu init && tofu apply

# Bootstrap Flux
tofu apply -target helm_release.flux_operator -var git_token="$GH_TOKEN"

# Check Flux status
kubectl get gitrepository -A
kubectl get kustomization -A
```

## Kilo Integration

The `.kilo/` directory contains Kilo AI assistant config with:

- `mcp-kubernetes` - Kubernetes access
- `flux-operator-mcp` - Flux CD management
