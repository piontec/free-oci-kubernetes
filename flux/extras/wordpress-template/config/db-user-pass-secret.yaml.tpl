apiVersion: v1
kind: Secret
metadata:
  name: db-user-pass
  namespace: wordpress-${wp_name}
data:
  pass: [UTF8-ENCODED-PASSWORD]
