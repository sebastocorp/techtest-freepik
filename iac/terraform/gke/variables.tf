variable "project" {
  description = "Project in GCP"
  type = object({
    name : string,
    region : string,
    zone : string
  })
  default = {
    name   = "changeme",
    region = "changeme",
    zone   = "changeme"
  }
}
