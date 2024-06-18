apiVersion: v1
kind: Secret
metadata:
  name: wp-admin-pass
  namespace: wordpress-${wp_name}
data:
  wordpressPassword: [UTF8-ENCODED-PASSWORD]
