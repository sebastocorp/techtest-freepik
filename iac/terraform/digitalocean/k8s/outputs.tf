###############################################################
## K8S CLUSTER
###############################################################
output "k8s_kubeconfig" {
  value     = digitalocean_kubernetes_cluster.freepik_k8s_cluster.kube_config[0].raw_config
  sensitive = true
}

output "k8s_host" {
  value = digitalocean_kubernetes_cluster.freepik_k8s_cluster.endpoint
}

output "k8s_token" {
  value     = digitalocean_kubernetes_cluster.freepik_k8s_cluster.kube_config[0].token
  sensitive = true
}

output "k8s_ca_certificate" {
  value     = digitalocean_kubernetes_cluster.freepik_k8s_cluster.kube_config[0].cluster_ca_certificate
  sensitive = true
}

output "freepik_bucket" {
  value = digitalocean_spaces_bucket.freepik_buckets[*]
}
