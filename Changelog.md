# Changelog

## Unreleased

- upgrade `mariadb-operator` to v0.29 and `mariadb` engine to 11.4

## 0.3.0 (2024.07.24)

- added support for [`mariadb-operator`](./flux-modules/extras/mariadb/README.md)
- added support for [`paperless`](./flux-modules/extras/paperless/README.md)
- added support for [`wordpress`](./flux-modules/extras/wordpress/README.md)
- upgrade to k8s 1.30.1

## 0.2.0 (2024.03.22)

- fix multiple issues when provisioning with `tofu` on an empty OCI account
- rewrite docs
- change layout of Flux resources so they don't clash with the default configuration created by `flux bootstrap`

## 0.1.1 (2024.03.05)

- first tagged release
  - all the basic features of the cluster
- added wireguard support
- added `pre-commit` config as validation engine
