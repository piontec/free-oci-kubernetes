# Mariadb operator extra

Source: <https://github.com/mariadb-operator/mariadb-operator>.

This operator manages mariadb instances. It can be used to create and manage mariadb instances in your cluster. The default installation will deploy a mariadb instance with a monitoring service and dashboard. Make sure to edit `mariadb/deploy/mariadb-secret.yaml.tpl` to set the admin user password. Make sure you encypt the password with `sops` before committing the changes.

To enable the mariadb-operator, add the following line to the `resources` section of the `flux/extras/kustomization.yaml` file:

```txt
  - ../../flux-modules/extras/mariadb/
```

Please note that the default installation does not configure any backup solution. If you want to use this deployment
for anything more serious, I highly recommend to setup off-site backups according to [this docs](https://github.com/mariadb-operator/mariadb-operator/blob/main/docs/BACKUP.md).
