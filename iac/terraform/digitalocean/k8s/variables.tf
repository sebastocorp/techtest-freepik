variable "project" {
  description = "Project in DO"
  type = object({
    name : string,
    common_tags = map(string)
  })
  default = {
    name = "changeme",
    common_tags = {
      "key" : "value",
    }
  }
}

variable "bucket_list" {
  description = "Minimum k8s node pool"
  type = list(object({
    name   = string,
    region = string,
  }))
  default = [
    {
      name   = "changeme",
      region = "changeme",
    }
  ]
}

variable "k8s_cluster" {
  description = "Minimum k8s cluster"
  type = object({
    name        = string,
    region      = string,
    k8s_version = string,
    ha          = bool,
    node_pool = object({
      name  = string,
      size  = string,
      count = number,
      taint = object({
        key    = string,
        value  = string,
        effect = string,
      }),
      labels = map(string)
    })
  })
  default = {
    name        = "changeme",
    region      = "changeme",
    k8s_version = "changeme",
    ha          = false,
    node_pool = {
      name  = "changeme",
      size  = "changeme",
      count = 1,
      taint = {
        key    = "",
        value  = "",
        effect = "",
      },
      labels = {
        "key" : "value",
      }
    }
  }
}

variable "k8s_node_pools" {
  description = "Minimum k8s node pool"
  type = list(object({
    name  = string,
    size  = string,
    count = number,
    taint = object({
      key    = string,
      value  = string,
      effect = string,
    }),
    labels = map(string)
  }))
  default = [
    {
      name  = "changeme",
      size  = "changeme",
      count = 1,
      taint = {
        key    = "key",
        value  = "value",
        effect = "effect",
      }
      labels = {
        "key" : "value",
      }
    }
  ]
}
