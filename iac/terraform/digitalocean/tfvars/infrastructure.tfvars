project = {
    name = "freepik",
    common_tags = {
        environment = "techtest",
        provider = "digitalocean",
        region = "fra1"
        manager = "terraform"
    }
}

k8s_cluster = {
    name = "freepik-k8s-cluster",
    region = "fra1",
    k8s_version = "1.29.1-do.0",
    ha = false
    node_pool = {
        name = "services",
        size = "s-2vcpu-2gb",
        count = 1,
        taint = {
            key = "",
            value = "",
            effect = "",
        }
        labels = {
            "node-type": "general-propose",
        }
    }
}

k8s_node_pools = [
    {
        name = "data",
        size = "s-2vcpu-2gb"
        count = 1,
        taint = {
            key = "data"
            value = "dedicated"
            effect = "NoSchedule"
        }
        labels = {
            "node-type": "data",
        }
    }
]
