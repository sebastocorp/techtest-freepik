terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "5.22"
    }
    google-beta = {
      source = "hashicorp/google-beta"
      version = "5.22"
    }
  }
}

provider "google" {
  project = var.project.name
  region  = var.project.region
  zone    = var.project.zone

  default_labels = {
    environment = "techtest",
    provider = "google",
    region = var.project.region
    manager = "terraform"
  }
}

provider "google-beta" {
  project = var.project.name
  region  = var.project.region
  zone    = var.project.zone

  default_labels = {
    environment = "techtest",
    provider = "google-beta",
    region = var.project.region
    manager = "terraform"
  }
}