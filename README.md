# Free OCI Kubernetes Cluster with GitOps

**Work in progress**

# Getting started

## 1. Tools you need to have installed

- open tofu
- flux
- sops
- gpg
- oci oracle cloud cli https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm

## 2. Preparing your repository

## 3. Bootstrapping the cloud infrastructure

https://signup.oraclecloud.com/
you have to have a credit card, even though you won't pay for anything (as of now)

Run

```
oci session authenticate
```

Go to repo/tf

```
cp variables-private.tf.tpl variables-private.tf
```

Edit `variables-private.tf`

- insert SSH key
- bastion allowed IPs you're gonna connect from
- compartment ID - how to find https://docs.oracle.com/en-us/iaas/Content/GSG/Tasks/contactingsupport_topic-Locating_Oracle_Cloud_Infrastructure_IDs.htm

## 4. Bootstrapping the GitOps setup

### 4.1. Generating GPG key and configuring sops

### 4.2. Create a slack profile

### 4.2. Bootstrapping Flux

# Design decision racionale

# Synchronizing with source and providing pull requests

Getting started:

**Note**: all `*.tpl` files need to be edited

- clone
- prepare tools
  - install CLI tools: `flux`, `sops` and `gpg`
  - create a new gpg key named `sops` and export private key to a file `sops.asc`
  - register (if you don't have it) a slack profile to receive notifications; then prepare an API access token with permissions to post to channels
- run terraform
  - add your variables in `*.tpl` files
    - `tf/variables-private.tf.tpl`
- bootstrap flux
  - add your variables in `*.tpl` files
    - configure `sops`
      - create the sops key in cluster as a `sops-gpg` secret in `flux-system` namespace using `sops.asc` key name in the Secret
    - configure your key hash and rename the file `flux/.sops.yaml.tpl`
    - prepare and encrypt needed secrets
      - for each file ending with `*.yaml.tpl.enc`, copy the file into the same name but without the `.tpl.enc` suffix
      - fill in required secrets, remember to based64 them
      - **do not put the files into the repo, they are still plain-text**
      - encrypt every file with the command `sops -i -e flux/[FILE].yaml`
      - only now add your secrets to repo
  - edit `flux/kube-system/kustomization-kube-system-extra.yaml` and enter your correct email address (it's used for the letsencrypt cert provider)
  - commit everything to your new gitops repository
  - run flux bootstrap
- done
