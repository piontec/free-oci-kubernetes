# Wireguard extra

Wireguard is a cryptographic VPN. You can use it to connect your devices - any device connected to the wireguard
service will be able to talk to each other device, even if they are behind NAT.

To use `wireguard`, add the following line to the `resources` section of the `flux/extras/kustomization.yaml` file:

```txt
  - ../../flux-modules/extras/wireguard/
```

Then, check the settings in [`flux-modules/extras/wireguard/deploy/user-settings-patch.yaml`](./flux-modules/extras/wireguard/deploy/user-settings-patch.yaml). Edit the values as described in the comments, commit and push.
