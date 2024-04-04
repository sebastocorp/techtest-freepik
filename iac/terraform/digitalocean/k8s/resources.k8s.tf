########################################################################################################################
## K8S CLUSTER
########################################################################################################################
resource "digitalocean_kubernetes_cluster" "freepik_k8s_cluster" {
  name    = var.k8s_cluster.name
  region  = var.k8s_cluster.region
  version = var.k8s_cluster.k8s_version

  vpc_uuid = digitalocean_vpc.freepik_k8s_cluster_vpc.id

  node_pool {
    name       = var.k8s_cluster.node_pool.name
    size       = var.k8s_cluster.node_pool.size
    node_count = var.k8s_cluster.node_pool.count
    labels     = var.k8s_cluster.node_pool.labels
  }
}

########################################################################################################################
## K8S NODES
########################################################################################################################
locals {
  # Transform the node_poll list into a map
  node_pools_map = {
    for v in var.k8s_node_pools :
    v.name => {
      name : v.name
      size : v.size
      count : v.count
    }
  }
}

resource "digitalocean_kubernetes_node_pool" "freepik_k8s_node_pools" {
  for_each   = local.node_pools_map
  cluster_id = digitalocean_kubernetes_cluster.freepik_k8s_cluster.id
  name       = each.value.name
  size       = each.value.size
  node_count = each.value.count
}
