# Changelog

## Unreleased

- switch the CNI to cilium

## 0.5.0 (2025.03.20)

- Upgrade kubernetes to 1.32.1

## 0.4.0 (2025.03.20)

- Upgrade kubernetes to 1.31.1
- Upgrade `mariadb-operator` to v0.29 and `mariadb` engine to 11.4
- Add VPA definitions for wordpress
- Add vertical-pod-autoscaler to kube-system apps
- Refactor: move flux monitoring to a separate folder and kustomization
- Fix: add missing dependencies necessary for the bootstrap phase
- Enable PSS baseline policy where possible
- Switch Flux deployment to flux-operator
- Add explicit my.cnf config map name for mariadb

## 0.3.0 (2024.07.24)

- added support for [`mariadb-operator`](./flux-modules/extras/mariadb/README.md)
- added support for [`paperless`](./flux-modules/extras/paperless/README.md)
- added support for [`wordpress`](./flux-modules/extras/wordpress/README.md)
- upgrade to k8s 1.30.1

## 0.2.0 (2024.03.22)

- fix multiple issues when provisioning with `tofu` on an empty OCI account
- rewrite docs
- change layout of Flux resources so they don't clash with the default configuration created by
  `flux bootstrap`

## 0.1.1 (2024.03.05)

- first tagged release
  - all the basic features of the cluster
- added wireguard support
- added `pre-commit` config as validation engine
