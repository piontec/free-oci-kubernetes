# Paperless-ngx extra

Source: <https://docs.paperless-ngx.com/>.

This modules deploys the paperless-ngx document management system. To make it work,
it requires the mariadb-operator to be deployed in the same cluster.

To prepare for installation, do the following:

- add secrets to all the `*yaml.tpl` files and encrypt them with `sops`
- edit the [paperless-helmrelease.yaml](./paperless-helmrelease.yaml) file to set the correct values for the domain (replace `[YOUR-HOST]` placeholder); also tune the environment variables `PAPERLESS_OCR_LANGUAGE`, `PAPERLESS_OCR_LANGUAGES` and `PAPERLESS_TIME_ZONE` to your regional preferences

Then, to deploy paperless-ngx, add the following line to the `resources` section of the `flux/extras/kustomization.yaml` file:

```txt
  - ../../flux-modules/extras/paperless/
```
