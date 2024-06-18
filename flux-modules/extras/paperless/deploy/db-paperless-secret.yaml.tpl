apiVersion: v1
kind: Secret
data:
  pass: [BASE64_ENCODED_PASSWORD]
metadata:
  name: db-paperless-user-pass
type: Opaque
