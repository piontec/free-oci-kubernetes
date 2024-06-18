apiVersion: v1
kind: Secret
metadata:
  name: paperless-admin-password
type: Opaque
data:
  pass: [BASE64_ENCODED_PASSWORD]
