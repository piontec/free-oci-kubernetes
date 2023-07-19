# Free OCI Kubernetes Cluster with GitOps

**Work in progress**

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
