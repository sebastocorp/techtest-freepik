########################################################################################################################
## K8S VPC
########################################################################################################################
resource "digitalocean_vpc" "freepik_k8s_cluster_vpc" {
  name   = "k8s-cluster-vpc"
  region = var.k8s_cluster.region
}
