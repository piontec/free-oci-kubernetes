# Free OCI Kubernetes Cluster with GitOps

By applying this repository you will get a completely free (as of Q1 2024, using the free tier of Oracle Cloud) Kubernetes cluster that has important applications already
pre-installed and is fully GitOps drive using Flux CD.

In more details, by following this guide you'll get:

- a completely free Kubernetes cluster, with 2 nodes, each wit 4 core ARM CPU, 12 GBs of RAM and 50 GB of storage (using the Oracle Cloud Infrastructure)
- a fully GitOps driven Kubernetes cluster, including
  - nginx-ingress-controller
  - cert-manager
  - monitoring setup, including Prometheus, Loki and Grafana
  - personal notifications about the alerts and health of your cluster
  - optional extra features, like a wireguard VPN server exposing your cluster deployments

# Getting started

## Intro

Before we can start creating the cluster, we need to first bootstrap our cloud infrastructure, our security keys and other secrets
that we need to run all the applications.

## 1. Tools you need to have installed

Before we start, make sure that you have installed (tested on Linux, should work on other OSes as well):

- tofu - this is a fork of the well-known TerraForm project, we'll use it to bootstrap our cloud infrastructure
- flux - the CLI for controlling flux deployment
- sops - a secret encryption tool that we use to securely keep all secrets in the repository
- gpg - encryption tool that we will use as a backend for `sops`
- [oci oracle cloud cli](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm) - a CLI tool to control infrastructure in the OCI

## 2. Preparing your repository

Your cluster will be driven form your own repository, that has to be a copy of this one. Create a fork of this repository
(I recommend keeping it private) and check it out on your local drive. If not stated otherwise, all the commands and files in
this guide will assume we're in the root directory of your repository.

## 3. Bootstrapping the cloud infrastructure

Before you start creating any infrastructure, you need to register a new account with Oracle Cloud. You need to have a valid credit
card to register, even though the whole setup here is tailored to not use any paid resources and max out the free tier the OCI offers.

Go to <https://signup.oraclecloud.com/> and create a new account. Some services, especially related to Kubernetes, are not included
in the free tier, but are still available to be used for free. Do be able to use them, you have to upgrade your billing tier. Go to
your [billing settings](https://cloud.oracle.com/invoices-and-orders/upgrade-and-payment), then click on "Add card" and "upgrade your account".
Once again, all the resource we use are available (at the time of writing and ofr the last at least a year) for free. Now you have to wait until
your billing tier change is processed.

### 3.1. Creating the infrastructure

In your terminal, run:

```sh
oci setup config
```

This will guide you through the process of setting up CLI access to OCI infrastructure. Read the documents printed by the `setup` command
to learn where to find necessary input data.

Next, go to the `tf/` directory in the repository and fill in information about your cloud account.
Copy the template settings file `cp variables-private.tf.tpl variables-private.tf` and edit it:

- insert your public SSH key as the `default` value for `ssh_public_key`
- enter 'bastion allowed IPs' these are the IP addresses allowed to connect to the bastion host created for the cluster nodes
- enter your default `compartment ID` - [here's how to find it](https://docs.oracle.com/en-us/iaas/Content/GSG/Tasks/contactingsupport_topic-Locating_Oracle_Cloud_Infrastructure_IDs.htm)

It's time to run `tofu` - be patient, the `apply` step can take pretty long (even up to an hour):

```sh
tofu init
tofu apply
```

Now, we can create a `kube.config` file to access our cluster. Find your cluster's OCID (cloud provider's ID) or just go to the web console in OCI, list your clusters and click on the newly created one. Then, in the top menu,
choose 'access cluster' and 'public access'. You will get a ready command that looks like this - run it:

```sh
oci ce cluster create-kubeconfig --cluster-id ocid1.cluster.oc1.REGION.aaaaaaaaopsxxxxxxxxxxxx --file $HOME/.kube/oci-test.config --region REGION --token-version 2.0.0  --kube-endpoint PUBLIC_ENDPOINT
```

Your kubeconfig should be ready. You can test it with:

```sh
export export KUBECONFIG=~/.kube/oci-test.config
kubectl get nodes
```

## 4. Bootstrapping the GitOps setup

While waiting for the infrastructure to be created, we can start filling in configuration necessary to set up Flux on our cluster.

### 4.1. Generating GPG key and configuring sops

First, we have to configure an encryption tool, that will help us to store all the secrets in the repository in an encrypted form, but one
that is still automatically decrypted on the cluster.

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

Next, save the private key to your cluster *without putting ths key into the repo*:

```txt
gpg --export-secret-keys --armor "[KEY_FINGERPRINT]" |
kubectl create secret generic sops-gpg \
--namespace=flux-system \
--from-file=sops.asc=/dev/stdin
```

### 4.2. Create a slack profile

This step is not really necessary, but it's very useful. Here we'll create a free slack profile, where we can receive notifications
from Flux and from our monitoring setup. Slack notifications are pretty easy to set up and still can be completely free, but obviously feel
free to change this step later.

First, [create a new slack profile](https://slack.com/get-started#/createnew). Then, create and save slack's webhook URL using [this instruction](https://api.slack.com/messaging/webhooks).

### 4.3. Preparing secrets

In the configuration repo, there are many secrets needed, usually passwords to different applications deployed. All files that need editing and filling in
some secrets have file names ending with `.tpl.enc`.

For each such file (see list below), you have to repeat the same procedure:

- copy the file into the same name, but without the `.tpl.enc` suffix
- fill in required secrets, remember to base64-encode them, for example `echo "MY_GRAFANA_PASS" | base64 -w 0`
- **do not put the files into the repo yet, they are still plain-text**
- encrypt the file with the command `sops -i -e flux/[FILE].yaml`
- only now add your secrets are ready to be included in the GitOps repo

You need to process the following files with secrets:

- ./flux-system-extra/github-api-token-secret.yaml.tpl.enc - paste your GitHub PAT again, so Flux can report back the status fo your commits
- ./flux-system-extra/gitops-dashboard-secret.yaml.tpl.enc - create a password for the web application with Flux overwiev
- ./flux-system-extra/slack-flux-notification-url-secret.yaml.tpl.enc - enter here the Slack webhook you created earlier
- ./monitoring/alertmanager-slack-api-secret.yaml.tpl.enc - again, include the Slack webhook URL
- ./monitoring/prom-stack-grafana-pass-secret.yaml.tpl.enc - create a user password for the Grafana web UI

Additionally, edit `flux/kube-system/kustomization-kube-system-extra.yaml` and enter your correct email address. It's used for the `letsencrypt` automatic cert provider.

Make sure that the `tofu` run is complete as well. Now, you can commit everything into your GitOps repository and push the changes, adding the following files to your repo:

- flux/kube-system/ingress-nginx-secgroup-oidc-cm.yaml
- tf/terraform.tfstate
- tf/terraform.tfstate.backup
- tf/variables-private.tf
- .terraform.lock.hcl

```sh
git commit -am "cluster bootstrap commit"
git push
```

### 4.4. Bootstrap Flux

Stat by reading the [official documentation about bootstrapping Flux with GitHub](https://fluxcd.io/flux/installation/bootstrap/github/).

Make sure you noted your GitHub Private Access Token (PAT). Now, remove the flux config present in this repo (it's used for the auto-upgrade GitHub Action) and run the following command:

```sh
git rm -r flux/flux-system
git commit -am "flux init"
git push
flux bootstrap github \
  --token-auth \
  --owner=piontec \
  --repository=oci-test \
  --branch=main \
  --path=flux/ \
  --personal
```

When asked, enter the PAT.

Wait until it's done, then add back the needed Kustomizations into your config file `flux/flux-system/kustomization.yaml`, so it looks like this:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - gotk-components.yaml
  - gotk-sync.yaml
  - ../flux-system-extra/kustomization-flux-system-extra.yaml
  - ../kube-system/kustomization-kube-system.yaml
  - ../monitoring/kustomization-monitoring.yaml
  - ../wireguard/
```

Commit, push and give Flux some time to reconcile everything.

Your work should be done now! From now on, Flux takes over and adjusts your cluster configuration exactly as in your GitOps repository on GitHub.

You can check the status of the most important object by running the following commands:

```sh
kubectl get gitrepository -A
kubectl get kustomization -A
```

### 5. Next steps

Your cluster is ready. Now you can either forget about the repository you cloned (not recommended, but totally possible) and modify your repository however
you like. Or you can read on [keeping track and contributing back](!TODO).

# Design decision racionale

**Work in Progress**

# Synchronizing with source and providing pull requests

**Work in Progress**