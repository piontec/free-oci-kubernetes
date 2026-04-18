resource "null_resource" "remove_kube_proxy" {
  depends_on = [local_file.kube_config]

  # Always run to ensure kube-proxy is removed (OCI can recreate it)
  triggers = {
    always = timestamp()
  }

  provisioner "local-exec" {
    command = <<-EOT
      set -e
      echo "Checking for kube-proxy DaemonSet in kube-system..."
      if kubectl --kubeconfig=.kube.config get daemonset kube-proxy -n kube-system &>/dev/null; then
        echo "Deleting kube-proxy DaemonSet..."
        kubectl --kubeconfig=.kube.config delete daemonset kube-proxy -n kube-system --ignore-not-found=true
        echo "Deleted kube-proxy DaemonSet"
      else
        echo "kube-proxy DaemonSet not found, skipping"
      fi

      echo "Checking for kube-proxy pods..."
      if kubectl --kubeconfig=.kube.config get pods -l k8s-app=kube-proxy -n kube-system &>/dev/null; then
        echo "Deleting kube-proxy pods..."
        kubectl --kubeconfig=.kube.config delete pods -l k8s-app=kube-proxy -n kube-system --ignore-not-found=true
        echo "Deleted kube-proxy pods"
      else
        echo "No kube-proxy pods found"
      fi

      echo "Checking for kube-proxy service account..."
      if kubectl --kubeconfig=.kube.config get serviceaccount kube-proxy -n kube-system &>/dev/null; then
        echo "Deleting kube-proxy service account..."
        kubectl --kubeconfig=.kube.config delete serviceaccount kube-proxy -n kube-system --ignore-not-found=true
        echo "Deleted kube-proxy service account"
      else
        echo "kube-proxy service account not found"
      fi

      echo "Checking for kube-proxy configmap..."
      if kubectl --kubeconfig=.kube.config get configmap kube-proxy -n kube-system &>/dev/null; then
        echo "Deleting kube-proxy configmap..."
        kubectl --kubeconfig=.kube.config delete configmap kube-proxy -n kube-system --ignore-not-found=true
        echo "Deleted kube-proxy configmap"
      else
        echo "kube-proxy configmap not found"
      fi

      echo "kube-proxy cleanup completed"
    EOT
  }
}

resource "null_resource" "remove_flannel" {
  depends_on = [local_file.kube_config]

  provisioner "local-exec" {
    command = <<-EOT
      if kubectl --kubeconfig=.kube.config get daemonset flannel -n kube-system &>/dev/null; then
        kubectl --kubeconfig=.kube.config delete daemonset flannel -n kube-system
        echo "Deleted flannel DaemonSet"
      else
        echo "flannel DaemonSet not found, skipping"
      fi
    EOT
  }
}
