# Wordpress extra

Source: <https://wordpress.org/>.

This modules deploys wordpress blog platform. To make it work,
it requires the mariadb-operator to be deployed in the same cluster.

It is possible to deploy multiple instances of wordpress in the same cluster.

To prepare for installation, do the following:

- make a copy of the directory `flux/extras/wordpress-template` in the same directory (`flux/extras`) and name according to your preference, for example `wordpress-mine`
- in the `config/` subdirectory, edit all the `*yaml.tpl` secret templates and encrypt them with `sops`
- in the `wordpress-mine/kustomization-wordpress.yaml` file, edit the following:
  - replace the name `wordpress-template` with the name of yours wordpress directory (here `wordpress-mine`)
  - in `postBuild` section, edit blog's name, domain and contact email; _important_ keep the `wp_name` to the same value you used in the directory name (here `mine`)
  - if you need any patches to the deployment, check the commented out example that sets extra domain

Then, to deploy wordpress, add the following line to the `resources` section of the `flux/extras/kustomization.yaml` file:

- `wordpress-mine/kustomization-wordpress.yaml`
