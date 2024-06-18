apiVersion: v1
kind: Secret
data:
  pass: [BASE64_ENCODED_PASSWORD]
type: Opaque
metadata:
  name: redis-pass
