apiVersion: v1
kind: Secret
metadata:
  name: mariadb-password
type: Opaque
data:
  root-password: [BASE64_ENCODED_PASSWORD]
