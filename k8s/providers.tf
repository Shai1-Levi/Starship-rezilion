# terraform {
  
#   required_version = ">= 0.13"

#   required_providers {
#     google = {
#       source  = "hashicorp/google"
#       version = "~> 4.10.0"
#     }
#     kubernetes = {
#       source  = "hashicorp/kubernetes"
#       version = "~> 2.11.0"
#     }
#   }
  
# }


# Google Cloud Platform Provider
provider "google" {
 credentials = "${file(var.gcp_credentials)}"
 project     = var.gcp_project_id
 region      = var.gcp_region 
}

data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}

provider "tls" {}
