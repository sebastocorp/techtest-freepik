########################################################################################################################
## BUCKET
########################################################################################################################
locals {
  # Transform the node_poll list into a map
  buckets_map = {
    for v in var.bucket_list :
    v.name => {
      name : v.name
      region : v.region
    }
  }
}

resource "digitalocean_spaces_bucket" "freepik_buckets" {
  for_each = local.buckets_map
  name     = each.value.name
  region   = each.value.region
}
