apiVersion: v1
kind: Secret
metadata:
  name: paperless-secret-key
type: Opaque
data:
  pass: [BASE64_ENCODED_PASSWORD]
