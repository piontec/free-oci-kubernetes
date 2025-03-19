# Free OCI Kubernetes Cluster with GitOps

By applying this repository you will get a completely free (still, as of Q1 2025, using the free tier of Oracle Cloud) Kubernetes cluster that has important applications already
pre-installed and is fully GitOps drive using Flux CD.

In more details, by following this guide you'll get:

- a completely free Kubernetes cluster, with 2 nodes, each wit 4 core ARM CPU, 12 GBs of RAM and 50 GB of storage (using the Oracle Cloud Infrastructure)
- a fully GitOps driven Kubernetes cluster using Flux CD, including
  - nginx-ingress-controller
  - cert-manager
  - monitoring setup, including Prometheus, Loki and Grafana
  - personal notifications about the alerts and health of your cluster
  - optional extra features, like a wireguard VPN server exposing your cluster deployments

## Index

- How to create your own cluster - this document
- [Design considerations](design.md)
- [Extras](extras.md) - optional extra modules

## Getting started

### Intro

Before we can start creating the cluster, we need to first bootstrap our cloud infrastructure, our security keys and other secrets
that we need to run all the applications.

### 1. Tools you need to have installed

Before we start, make sure that you have installed (tested on Linux, should work on other OSes as well):

- tofu - this is a fork of the well-known TerraForm project, we'll use it to bootstrap our cloud infrastructure
- flux - the CLI for controlling flux deployment
- sops - a secret encryption tool that we use to securely keep all secrets in the repository
- gpg - encryption tool that we will use as a backend for `sops`
- [oci oracle cloud cli](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm) - a CLI tool to control infrastructure in the OCI

### 2. Preparing your repository

Your cluster will be driven form your own repository, that has to be a copy of this one. Create a fork of this repository
(I recommend keeping it private) and check it out on your local drive. If not stated otherwise, all the commands and files in
this guide will assume we're in the root directory of your repository.

### 3. Bootstrapping the cloud infrastructure

Before you start creating any infrastructure, you need to register a new account with Oracle Cloud. You need to have a valid credit
card to register, even though the whole setup here is tailored to not use any paid resources and max out the free tier the OCI offers.

Go to <https://signup.oraclecloud.com/> and create a new account. Some services, especially related to Kubernetes, are not included
in the free tier, but are still available to be used for free. Do be able to use them, you have to upgrade your billing tier. Go to
your [billing settings](https://cloud.oracle.com/invoices-and-orders/upgrade-and-payment), then click on "Add card" and "upgrade your account".
Once again, all the resource we use are available (at the time of writing and ofr the last at least a year) for free. Now you have to wait until
your billing tier change is processed.

#### 3.1. Creating the infrastructure

In your terminal, run:

```sh
oci setup config
```

This will guide you through the process of setting up CLI access to OCI infrastructure. Read the documents printed by the `setup` command
to learn where to find necessary input data.

Next, go to the `tf/` directory in the repository and fill in information about your cloud account.
Copy the template settings file `cp variables-private.tf.tpl variables-private.tf` and edit it:

- insert your public SSH key as the `default` value for `ssh_public_key`
- enter 'bastion allowed IPs', these are the IP addresses allowed to connect to the bastion host created for the cluster nodes
- enter your default `compartment ID` - [here's how to find it](https://docs.oracle.com/en-us/iaas/Content/GSG/Tasks/contactingsupport_topic-Locating_Oracle_Cloud_Infrastructure_IDs.htm)
- enter your region and 2 Availability Domains within it
- enter the `git_url` value that points to your repository
- don't enter `git_token`, as we want this value to be secret (don't save it on your hard drive).

Now, go to [github.com profile page](https://github.com/settings/profile) and generate a fine-grained private access token (PAT) with `repo` scope (Read and Write access to code). Here are [more details](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens). Copy the token and paste it into the `variables-private.tf` file as the `git_token` value.

Export the PAT as environment variable

```
 export GH_TOKEN=YOUR_PAT
```

It's time to run `tofu` to bootstrap our cluster and obtain a `kube.config` file for it. Be patient, the first `apply` step can take pretty long (around half an hour):

```sh
tofu init
tofu apply -var git_token="$GH_TOKEN" -target local_file.kube_config
```

Your `kube.config` should be ready. You can test it with:

```sh
export KUBECONFIG=$PWD/.kube.config
kubectl version
kubectl get nodes
```

### 4. Bootstrapping the GitOps setup

While waiting for the infrastructure to be created, we can start filling in configuration necessary to set up Flux on our cluster.

#### 4.1. Generating GPG key and configuring sops

First, we have to configure an encryption tool, that will help us to store all the secrets in the repository in an encrypted form, but one
that is still automatically decrypted on the cluster.

Switch to the repo root folder.

If you don't have a ready GPG key, [here's a more detailed manual by GitHub about how to create one](https://docs.github.com/en/authentication/managing-commit-signature-verification/).

If you just want a kick-start, generate a new key with

```txt
gpg --full-generate-key
```

Save its key fingerprint that is printed out when the key is ready (and remove space between all the 4-characters blocks). We will use your GPG key
with `sops` tool, that will encrypt the secrets for use with Flux. Now, copy the `sops` config from template:

```sh
cp .sops.yaml.tpl .sops.yaml
```

then edit the file and paste your key fingerprint.

Next, save the private key to your cluster _without putting the key into the repo_:

```txt
kubectl create ns flux-system
gpg --export-secret-keys --armor "[KEY_FINGERPRINT]" |
kubectl create secret generic sops-gpg \
--namespace=flux-system \
--from-file=sops.asc=/dev/stdin
```

#### 4.2. Create a slack profile

This step is not really necessary, but it's very useful. Here we'll create a free slack profile, where we can receive notifications
from Flux and from our monitoring setup. Slack notifications are pretty easy to set up and still can be completely free, but obviously feel
free to change this step later.

First, [create a new slack profile](https://slack.com/get-started#/createnew). Then, create and save slack's webhook URL using [this instruction](https://api.slack.com/messaging/webhooks).

#### 4.3. Preparing secrets

In the configuration repo, there are many secrets needed, usually passwords to different applications deployed. All files that need editing and filling in
some secrets have file names ending with `.tpl.enc`.

For each such file (see list below), you have to repeat the same procedure:

- copy the file into the same name, but without the `.tpl.enc` suffix
- fill in required secrets, remember to base64-encode them, for example `echo "MY_GRAFANA_PASS" | base64 -w 0`
- **do not put the files into the repo yet, they are still plain-text**
- encrypt the file with the command `sops -i -e flux/[FILE].yaml`
- only now add your secrets are ready to be included in the GitOps repo

You need to process the following files with secrets:

- ./flux-modules/flux-system-extra/github-api-token-secret.yaml.tpl.enc - paste your GitHub PAT again, so Flux can report back the status fo your commits
- ./flux-modules/flux-system-extra/slack-flux-notification-url-secret.yaml.tpl.enc - enter here the Slack webhook you created earlier
- ./flux-modules/monitoring/alertmanager-slack-api-secret.yaml.tpl.enc - again, include the Slack webhook URL
- ./flux-modules/monitoring/prom-stack-grafana-pass-secret.yaml.tpl.enc - create a user password for the Grafana web UI

Additionally, you have to edit `postBuild` section of a few files to give information like your DNS name for hosting the cluster or admin's email address (required for
`letsencrypt`). The files you need to edit are:

- flux-modules/flux-system-extra/kustomization-flux-system-extra.yaml
- flux-modules/kube-system-extra/kustomization-kube-system-extra.yaml
- flux-modules/monitoring/kustomization-monitoring.yaml
- flux-modules/extras/wireguard/kustomization-wireguard.yaml
- flux-modules/extras/wireguard/kustomization-wireguard-pre.yaml

#### 4.4. Bootstrap Flux

Stat by reading the [official documentation about bootstrapping Flux with Flux Operator](https://fluxcd.control-plane.io/operator/).

Run `tofu` again, this time asking it to deploy the `flux-operator`

```sh
# run from the tf/ directory
tofu apply -target helm_release.flux_operator -var git_token="$GH_TOKEN"
```

Running

```sh
kubectl -n flux-system get deploy
```

should show you that the `flux-operator` deployment is up and running (`Ready: 1/1`).

Now, we can create an actual Flux instance that will deploy all the applications we have in our GitOps repository. We can do full `tofu apply` now to make sure our full `tofu` config is deployed:

```sh
tofu apply -var git_token="$GH_TOKEN"
```

Make sure that the `tofu` run is complete. Now, you can commit everything into your GitOps repository and push the changes, adding all the created terraform and \*.yaml
files to your repo. Check that all the files are in, especially `tofu` state files:

- tf/terraform.tfstate
- tf/terraform.tfstate.backup
- tf/variables-private.tf
- .terraform.lock.hcl

```sh
git commit -am "cluster bootstrap commit"
git push
```

Your work should be done now! From now on, Flux takes over and adjusts your cluster configuration exactly as in your GitOps repository on GitHub.

You can check the status of the most important object by running the following commands:

```sh
kubectl get gitrepository -A
kubectl get kustomization -A
```

### 5. Next steps

Your cluster is ready. Now you can either forget about the repository you cloned (not recommended, but totally possible) and modify your repository however
you like. Or you can read on [keeping track and contributing back](#synchronizing-with-source-repository-and-providing-pull-requests).

## Configuring the repository to run automatic Flux upgrade job

## Synchronizing with source repository and providing pull requests

After you bootstrap your own repository, you can forget about the one you forked it from. Still, it is beneficial to be able to get upstream changes,
including new versions and new modules. Below is information useful in tracking and contributing to the upstream repository.

### Fetching changes from the upstream repository

It is recommended to setup additional git source repository, then fetch and merge the changes with your selected branch:

```sh
git remote add upstream https://github.com/piontec/free-oci-kubernetes.git  # run only once, if you don't have the upstream definition yet
git fetch upstream main
git merge upstream/main
```

Now you might need to resolve any potential merge conflicts. Once that's done, review the changes and you should be ready to push them to your branch for
Flux to pick-up.

### Preparing pull requests

It's best if you prepare a small and scoped PR. Please make also sure, that your code complies to `pre-commit` linting tests. To make it run automatically
for you, install [pre-commit](https://pre-commit.com/), then run:

```txt
pre-commit install --install-hooks
```

From now on, all the commits will automatically validated.
