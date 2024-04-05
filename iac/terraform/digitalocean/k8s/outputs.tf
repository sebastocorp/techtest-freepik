###############################################################
## K8S CLUSTER KUBECONFIG
###############################################################
output "k8s_kubeconfig" {
  value = {
    kubeconfig : digitalocean_kubernetes_cluster.freepik_k8s_cluster.kube_config.0
  }
  sensitive = true
}

output "freepik_bucket" {
  value = digitalocean_spaces_bucket.freepik_buckets[*]
}
